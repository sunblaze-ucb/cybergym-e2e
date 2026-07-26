from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from types import ModuleType, SimpleNamespace
from typing import Any

import pytest

RUN_OPENHANDS_PATH = (
    Path(__file__).resolve().parents[1] / "scripts" / "run_openhands.py"
)


class _Message:
    def __init__(
        self,
        *,
        role: str,
        content: list[Any],
        cache_enabled: bool = False,
        vision_enabled: bool = False,
        function_calling_enabled: bool = False,
        tool_calls: list[Any] | None = None,
        tool_call_id: str | None = None,
        name: str | None = None,
        force_string_serializer: bool = False,
        reasoning_content: str | None = None,
    ) -> None:
        self.role = role
        self.content = content
        self.cache_enabled = cache_enabled
        self.vision_enabled = vision_enabled
        self.function_calling_enabled = function_calling_enabled
        self.tool_calls = tool_calls
        self.tool_call_id = tool_call_id
        self.name = name
        self.force_string_serializer = force_string_serializer
        self.reasoning_content = reasoning_content

    def _add_tool_call_keys(self, message_dict: dict[str, Any]) -> dict[str, Any]:
        if self.tool_calls is not None:
            message_dict["tool_calls"] = [
                {
                    "id": tool_call.id,
                    "type": "function",
                    "function": {
                        "name": tool_call.function.name,
                        "arguments": tool_call.function.arguments,
                    },
                }
                for tool_call in self.tool_calls
            ]
        return message_dict

    def model_dump(self) -> dict[str, Any]:
        return self._add_tool_call_keys({"role": self.role, "content": self.content})


class _ConversationMemory:
    def _process_action(
        self,
        action: _Action,
        pending_tool_call_action_messages: dict[str, _Message],
        vision_is_active: bool = False,
    ) -> list[_Message]:
        del vision_is_active
        model_response = action.tool_call_metadata.model_response
        assistant_message = model_response.choices[0].message
        pending_tool_call_action_messages[model_response.id] = _Message(
            role=assistant_message.role,
            content=[],
            tool_calls=assistant_message.tool_calls,
        )
        return []


class _Action:
    def __init__(self, tool_call_metadata: Any) -> None:
        self.tool_call_metadata = tool_call_metadata


class _AssistantMessage:
    def __init__(
        self,
        *,
        tool_calls: list[Any],
        reasoning_content: str,
    ) -> None:
        self.role = "assistant"
        self.tool_calls = tool_calls
        self.reasoning_content = reasoning_content

    def get(self, key: str, default: Any = None) -> Any:
        return self.__dict__.get(key, default)


_ORIGINAL_PROCESS_ACTION = _ConversationMemory._process_action


def _stub_openhands_modules(monkeypatch: pytest.MonkeyPatch) -> None:
    modules = {
        "openhands": ModuleType("openhands"),
        "openhands.core": ModuleType("openhands.core"),
        "openhands.core.message": ModuleType("openhands.core.message"),
        "openhands.events": ModuleType("openhands.events"),
        "openhands.events.action": ModuleType("openhands.events.action"),
        "openhands.memory": ModuleType("openhands.memory"),
        "openhands.memory.conversation_memory": ModuleType(
            "openhands.memory.conversation_memory"
        ),
    }
    modules["openhands.core.message"].Message = _Message
    modules["openhands.events.action"].Action = _Action
    modules["openhands.memory.conversation_memory"].ConversationMemory = (
        _ConversationMemory
    )
    for name, module in modules.items():
        monkeypatch.setitem(sys.modules, name, module)


@pytest.fixture
def runtime_module(monkeypatch: pytest.MonkeyPatch) -> Any:
    monkeypatch.setattr(
        _ConversationMemory, "_process_action", _ORIGINAL_PROCESS_ACTION
    )
    _stub_openhands_modules(monkeypatch)
    spec = importlib.util.spec_from_file_location(
        "cybergym_run_openhands_for_tests", RUN_OPENHANDS_PATH
    )
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _tool_action(
    response_id: str,
    tool_call_id: str,
    reasoning_content: str,
) -> _Action:
    tool_call = SimpleNamespace(
        id=tool_call_id,
        function=SimpleNamespace(
            name="execute_bash",
            arguments='{"command":"pwd"}',
        ),
    )
    assistant_message = _AssistantMessage(
        tool_calls=[tool_call],
        reasoning_content=reasoning_content,
    )
    model_response = SimpleNamespace(
        id=response_id,
        choices=[SimpleNamespace(message=assistant_message)],
    )
    return _Action(
        SimpleNamespace(
            model_response=model_response,
            tool_call_id=tool_call_id,
        )
    )


def test_multi_turn_native_tool_replay_preserves_reasoning_and_linkage(
    runtime_module: Any,
) -> None:
    first_action = _tool_action("response_1", "call_1", "Inspect the workspace.")
    second_action = _tool_action("response_2", "call_2", "Read the relevant source.")
    pending_messages: dict[str, _Message] = {}

    assert runtime_module.install_reasoning_content_patch(
        {"LLM_NATIVE_TOOL_CALLING": "true"}
    )
    memory = _ConversationMemory()
    memory._process_action(first_action, pending_messages)
    memory._process_action(second_action, pending_messages)

    first_message = pending_messages["response_1"].model_dump()
    second_message = pending_messages["response_2"].model_dump()
    replay = [
        first_message,
        {"role": "tool", "tool_call_id": "call_1", "content": "/src"},
        second_message,
        {"role": "tool", "tool_call_id": "call_2", "content": "source"},
    ]

    assert [
        replay[0]["reasoning_content"],
        replay[2]["reasoning_content"],
    ] == [
        "Inspect the workspace.",
        "Read the relevant source.",
    ]
    assert replay[0]["tool_calls"][0]["id"] == replay[1]["tool_call_id"]
    assert replay[2]["tool_calls"][0]["id"] == replay[3]["tool_call_id"]


def test_prompted_tool_calling_path_is_not_patched(
    runtime_module: Any,
) -> None:
    original_process_action = _ConversationMemory._process_action

    assert not runtime_module.install_reasoning_content_patch(
        {"LLM_NATIVE_TOOL_CALLING": "false"}
    )
    assert _ConversationMemory._process_action is original_process_action
