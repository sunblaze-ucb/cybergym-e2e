"""Run OpenHands with native-tool reasoning replay compatibility."""

from __future__ import annotations

import os
import runpy
from collections.abc import Mapping
from importlib.metadata import version
from typing import Any

from openhands.core.message import Message
from openhands.events.action import Action
from openhands.memory.conversation_memory import ConversationMemory

_SUPPORTED_OPENHANDS_VERSION = "1.0.0"
_ORIGINAL_PROCESS_ACTION = ConversationMemory._process_action


class _ReasoningMessage(Message):
    """OpenHands message that retains provider-native reasoning."""

    reasoning_content: str | None = None

    def _add_tool_call_keys(self, message_dict: dict[str, Any]) -> dict[str, Any]:
        message_dict = super()._add_tool_call_keys(message_dict)
        if (
            self.role == "assistant"
            and self.tool_calls is not None
            and self.reasoning_content
        ):
            message_dict["reasoning_content"] = self.reasoning_content
        return message_dict


def _message_with_reasoning(
    message: Message, reasoning_content: str
) -> _ReasoningMessage:
    return _ReasoningMessage(
        role=message.role,
        content=message.content,
        cache_enabled=message.cache_enabled,
        vision_enabled=message.vision_enabled,
        function_calling_enabled=message.function_calling_enabled,
        tool_calls=message.tool_calls,
        tool_call_id=message.tool_call_id,
        name=message.name,
        force_string_serializer=message.force_string_serializer,
        reasoning_content=reasoning_content,
    )


def _process_action_with_reasoning(
    self: ConversationMemory,
    action: Action,
    pending_tool_call_action_messages: dict[str, Message],
    vision_is_active: bool = False,
) -> list[Message]:
    messages = _ORIGINAL_PROCESS_ACTION(
        self,
        action=action,
        pending_tool_call_action_messages=pending_tool_call_action_messages,
        vision_is_active=vision_is_active,
    )

    tool_metadata = action.tool_call_metadata
    if tool_metadata is None:
        return messages

    model_response = tool_metadata.model_response
    assistant_message = model_response.choices[0].message
    reasoning_content = assistant_message.get("reasoning_content")
    if not isinstance(reasoning_content, str) or not reasoning_content:
        return messages

    pending_message = pending_tool_call_action_messages.get(model_response.id)
    if pending_message is None or pending_message.tool_calls is None:
        return messages

    pending_tool_call_action_messages[model_response.id] = _message_with_reasoning(
        pending_message, reasoning_content
    )
    return messages


def _native_tool_calling_enabled(env: Mapping[str, str]) -> bool:
    return env.get("LLM_NATIVE_TOOL_CALLING", "").lower() in ("1", "true")


def install_reasoning_content_patch(
    env: Mapping[str, str] = os.environ,
) -> bool:
    """Preserve reasoning only when native tool calling is enabled."""
    if not _native_tool_calling_enabled(env):
        return False
    if ConversationMemory._process_action is _process_action_with_reasoning:
        return True
    if ConversationMemory._process_action is not _ORIGINAL_PROCESS_ACTION:
        raise RuntimeError(
            "OpenHands ConversationMemory._process_action was already patched"
        )

    ConversationMemory._process_action = _process_action_with_reasoning
    return True


def _ensure_supported_openhands_version() -> None:
    installed_version = version("openhands-ai")
    if installed_version != _SUPPORTED_OPENHANDS_VERSION:
        raise RuntimeError(
            "CyberGym's reasoning replay adapter supports "
            f"openhands-ai=={_SUPPORTED_OPENHANDS_VERSION}; "
            f"found {installed_version}"
        )


def main() -> None:
    _ensure_supported_openhands_version()
    install_reasoning_content_patch()
    runpy.run_module("openhands.core.main", run_name="__main__")


if __name__ == "__main__":
    main()
