from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from types import SimpleNamespace
from typing import Any

import pytest

SCRIPTS_DIR = Path(__file__).resolve().parents[1] / "scripts"
RUN_AGENT_PATH = SCRIPTS_DIR / "run_agent.py"


def _load_run_agent() -> Any:
    sys.path.insert(0, str(SCRIPTS_DIR))
    spec = importlib.util.spec_from_file_location(
        "cybergym_run_agent_for_tests", RUN_AGENT_PATH
    )
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@pytest.fixture(scope="module")
def run_agent_module() -> Any:
    return _load_run_agent()


def test_openai_compatible_env_enables_native_tools(
    run_agent_module: Any,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("OPENAI_API_KEY", "sanitized-test-key")
    monkeypatch.setenv("OPENAI_BASE_URL", "https://example.invalid/v1")
    monkeypatch.delenv("LLM_NATIVE_TOOL_CALLING", raising=False)

    env, model = run_agent_module.get_llm_env(
        model_provider="openai",
        litellm_model_id="kimi-k3",
    )

    assert model == "openai/kimi-k3"
    assert env["LLM_MODEL"] == "openai/kimi-k3"
    assert env["LLM_API_KEY"] == "sanitized-test-key"
    assert env["LLM_BASE_URL"] == "https://example.invalid/v1"
    assert env["LLM_NATIVE_TOOL_CALLING"] == "true"


def test_openai_compatible_native_tools_can_be_disabled(
    run_agent_module: Any,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("OPENAI_API_KEY", "sanitized-test-key")
    monkeypatch.setenv("OPENAI_BASE_URL", "https://example.invalid/v1")
    monkeypatch.setenv("LLM_NATIVE_TOOL_CALLING", "false")

    env, _ = run_agent_module.get_llm_env(
        model_provider="openai",
        litellm_model_id="openai/kimi-k3",
    )

    assert env["LLM_NATIVE_TOOL_CALLING"] == "false"


def test_openhands_sampling_inputs_map_to_exact_env_names(
    run_agent_module: Any,
) -> None:
    base_env = {"LLM_MODEL": "openai/kimi-k3"}

    configured_env = run_agent_module._configure_openhands_llm_env(
        base_env,
        temperature=1.0,
        top_p=0.95,
        max_tokens=262144,
    )

    assert configured_env == {
        "LLM_MODEL": "openai/kimi-k3",
        "LLM_TEMPERATURE": "1.0",
        "LLM_TOP_P": "0.95",
        "LLM_MAX_OUTPUT_TOKENS": "262144",
    }
    assert base_env == {"LLM_MODEL": "openai/kimi-k3"}


def test_openhands_sampling_inputs_remain_unset_when_omitted(
    run_agent_module: Any,
) -> None:
    configured_env = run_agent_module._configure_openhands_llm_env(
        {"LLM_MODEL": "openai/kimi-k3"},
        temperature=None,
        top_p=None,
        max_tokens=None,
    )

    assert configured_env == {"LLM_MODEL": "openai/kimi-k3"}


def test_execute_openhands_uses_runtime_adapter_and_sampling_env(
    run_agent_module: Any,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    calls: list[dict[str, Any]] = []

    def fake_get_llm_env(**_: Any) -> tuple[dict[str, str], str]:
        return {
            "LLM_MODEL": "openai/kimi-k3",
            "LLM_NATIVE_TOOL_CALLING": "true",
        }, "openai/kimi-k3"

    def fake_exec_run(
        container_id: str,
        command: str,
        description: str | None = None,
        timeout: int = 1200,
        env: dict[str, str] | None = None,
        **_: Any,
    ) -> tuple[int, str, str]:
        calls.append(
            {
                "container_id": container_id,
                "command": command,
                "description": description,
                "timeout": timeout,
                "env": env,
            }
        )
        return 0, "", ""

    monkeypatch.setattr(run_agent_module, "get_llm_env", fake_get_llm_env)
    monkeypatch.setattr(run_agent_module, "exec_run", fake_exec_run)
    args = SimpleNamespace(
        model_provider="openai",
        litellm_model_id="kimi-k3",
        bedrock_model_id=None,
        anthropic_model_id=None,
        aws_region="us-west-2",
        aws_profile=None,
        temperature=1.0,
        top_p=0.95,
        max_tokens=262144,
        timeout=90,
    )

    exit_code, _, _ = run_agent_module._execute_openhands(
        "container-id",
        "solve the task",
        args,
    )

    assert exit_code == 0
    run_call = calls[-1]
    assert "/scripts/run_openhands.py --task" in run_call["command"]
    assert run_call["env"] == {
        "LLM_MODEL": "openai/kimi-k3",
        "LLM_NATIVE_TOOL_CALLING": "true",
        "LLM_TEMPERATURE": "1.0",
        "LLM_TOP_P": "0.95",
        "LLM_MAX_OUTPUT_TOKENS": "262144",
    }


def test_install_openhands_copies_runtime_adapter(
    run_agent_module: Any,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    copied_files: list[tuple[Path, str]] = []

    def fake_copy_to_container(
        container_id: str,
        src_path: Path,
        dst_path: str,
    ) -> None:
        assert container_id == "container-id"
        copied_files.append((src_path, dst_path))

    def fake_exec_run(*_: Any, **__: Any) -> tuple[int, str, str]:
        return 0, "", ""

    monkeypatch.setattr(run_agent_module, "copy_to_container", fake_copy_to_container)
    monkeypatch.setattr(run_agent_module, "exec_run", fake_exec_run)

    scripts_dir = Path("/bundle/scripts")
    run_agent_module.install(
        "container-id",
        "openhands",
        scripts_dir=scripts_dir,
    )

    assert (
        scripts_dir / "run_openhands.py",
        "/scripts/run_openhands.py",
    ) in copied_files
