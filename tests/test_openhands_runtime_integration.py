from __future__ import annotations

import importlib.metadata
import importlib.util
from pathlib import Path
from typing import Any

import pytest

try:
    from litellm import ModelResponse
    from openhands.agenthub.codeact_agent.function_calling import (
        response_to_actions,
    )
    from openhands.core.config import LLMConfig
    from openhands.core.config.openhands_config import OpenHandsConfig
    from openhands.core.config.utils import load_from_env
    from openhands.events.event import EventSource
    from openhands.llm import llm as llm_module
    from openhands.memory.conversation_memory import ConversationMemory
except ModuleNotFoundError:
    pytest.skip("OpenHands is not installed", allow_module_level=True)

RUN_OPENHANDS_PATH = (
    Path(__file__).resolve().parents[1] / "scripts" / "run_openhands.py"
)


def _load_runtime_module() -> Any:
    spec = importlib.util.spec_from_file_location(
        "cybergym_run_openhands_integration", RUN_OPENHANDS_PATH
    )
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_pinned_openhands_preserves_reasoning_and_tool_linkage() -> None:
    assert importlib.metadata.version("openhands-ai") == "1.0.0"
    assert importlib.metadata.version("litellm") == "1.80.7"
    assert importlib.metadata.version("openai") == "2.8.0"
    runtime_module = _load_runtime_module()
    response = ModelResponse(
        id="response_123",
        model="openai/kimi-k3",
        choices=[
            {
                "index": 0,
                "finish_reason": "tool_calls",
                "message": {
                    "role": "assistant",
                    "content": None,
                    "reasoning_content": "Inspect the workspace before editing.",
                    "tool_calls": [
                        {
                            "id": "call_123",
                            "type": "function",
                            "function": {
                                "name": "execute_bash",
                                "arguments": '{"command":"pwd"}',
                            },
                        }
                    ],
                },
            }
        ],
    )
    action = response_to_actions(response)[0]
    action._source = EventSource.AGENT
    pending_messages = {}
    original_process_action = ConversationMemory._process_action

    try:
        assert runtime_module.install_reasoning_content_patch(
            {"LLM_NATIVE_TOOL_CALLING": "true"}
        )
        memory = ConversationMemory.__new__(ConversationMemory)
        memory._process_action(action, pending_messages)
        serialized_message = pending_messages[response.id].model_dump()
    finally:
        ConversationMemory._process_action = original_process_action

    assert serialized_message["reasoning_content"] == (
        "Inspect the workspace before editing."
    )
    assert serialized_message["tool_calls"][0]["id"] == "call_123"
    assert action.tool_call_metadata.tool_call_id == "call_123"


def test_pinned_openhands_loads_forwarded_configuration() -> None:
    config = OpenHandsConfig()

    load_from_env(
        config,
        {
            "LLM_MODEL": "openai/kimi-k3",
            "LLM_API_KEY": "sanitized-test-key",
            "LLM_BASE_URL": "https://example.invalid/v1",
            "LLM_NATIVE_TOOL_CALLING": "true",
            "LLM_TEMPERATURE": "1.0",
            "LLM_TOP_P": "0.95",
            "LLM_MAX_OUTPUT_TOKENS": "262144",
        },
    )

    llm_config = config.get_llm_config()
    assert llm_config.model == "openai/kimi-k3"
    assert llm_config.base_url == "https://example.invalid/v1"
    assert llm_config.native_tool_calling is True
    assert llm_config.temperature == 1.0
    assert llm_config.top_p == 0.95
    assert llm_config.max_output_tokens == 262144


def test_pinned_openhands_sends_configured_sampling_values(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    captured_kwargs: list[dict[str, Any]] = []

    def fake_litellm_completion(*_: Any, **kwargs: Any) -> ModelResponse:
        captured_kwargs.append(kwargs)
        return ModelResponse(
            id="response_mock",
            model="openai/kimi-k3",
            choices=[
                {
                    "index": 0,
                    "finish_reason": "stop",
                    "message": {"role": "assistant", "content": "ok"},
                }
            ],
            usage={
                "prompt_tokens": 1,
                "completion_tokens": 1,
                "total_tokens": 2,
            },
        )

    monkeypatch.setattr(
        llm_module,
        "litellm_completion",
        fake_litellm_completion,
    )
    config = LLMConfig(
        model="openai/kimi-k3",
        api_key="sanitized-test-key",
        base_url="https://example.invalid/v1",
        temperature=1.0,
        top_p=0.95,
        max_output_tokens=262144,
        native_tool_calling=True,
        disable_vision=True,
    )
    llm = llm_module.LLM(config=config, service_id="transport-test")

    llm.completion(
        messages=[{"role": "user", "content": "transport test"}],
        tools=[
            {
                "type": "function",
                "function": {
                    "name": "noop",
                    "description": "noop",
                    "parameters": {"type": "object", "properties": {}},
                },
            }
        ],
    )

    assert len(captured_kwargs) == 1
    assert captured_kwargs[0]["temperature"] == 1.0
    assert captured_kwargs[0]["top_p"] == 0.95
    assert captured_kwargs[0]["max_completion_tokens"] == 262144
    assert len(captured_kwargs[0]["tools"]) == 1
