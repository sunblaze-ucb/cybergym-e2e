"""
Shared utilities for cybergym-e2e scripts.

Docker container management, LLM configuration, and common operations.
"""

import subprocess
import os
from pathlib import Path

import boto3
import httpx
import tomli
import tomli_w


def get_poc_hex_dump(poc_file, max_bytes=200):
    """Get hex dump of PoC file for feedback."""
    try:
        with open(poc_file, "rb") as f:
            data = f.read(max_bytes)
        hex_lines = []
        for i in range(0, len(data), 16):
            chunk = data[i : i + 16]
            hex_part = " ".join(f"{b:02x}" for b in chunk)
            ascii_part = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
            hex_lines.append(f"{i:04x}: {hex_part:<48} {ascii_part}")
        size = Path(poc_file).stat().st_size
        result = "\n".join(hex_lines)
        if size > max_bytes:
            result += f"\n... ({size} bytes total, showing first {max_bytes})"
        return result
    except Exception as e:
        return f"Error reading PoC: {e}"


def get_aws_credentials(profile):
    """Get AWS credentials from profile for use in Docker."""
    try:
        session = boto3.Session(profile_name=profile)
        credentials = session.get_credentials()
        if credentials:
            frozen = credentials.get_frozen_credentials()
            return {
                "AWS_ACCESS_KEY_ID": frozen.access_key,
                "AWS_SECRET_ACCESS_KEY": frozen.secret_key,
                "AWS_SESSION_TOKEN": frozen.token if frozen.token else "",
            }
    except Exception as e:
        print(f"  Warning: Could not get AWS credentials: {e}")
    return {}


def copy_to_container(container_id, src_path, dst_path, file_list=None):
    """
    Copy file(s) or directory to a container.

    Args:
        container_id: Docker container ID
        src_path: Source path (file or directory)
        dst_path: Destination path in container
        file_list: If provided, copy only these files from src_path directory

    Returns:
        None. Raises exception on failure (unless file_list with missing files).
    """
    src_path = Path(src_path)

    if file_list:
        # Copy specific files from directory
        for file_name in file_list:
            full_src = src_path / file_name
            if full_src.exists():
                cmd = ["docker", "cp", str(full_src), f"{container_id}:{dst_path}/{file_name}"]
                subprocess.run(cmd, capture_output=True, text=True)
    elif src_path.is_dir():
        # Copy entire directory
        cmd = ["docker", "cp", str(src_path) + "/.", f"{container_id}:{dst_path}"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(f"Failed to copy {src_path}: {result.stderr}")
    else:
        # Copy single file
        cmd = ["docker", "cp", str(src_path), f"{container_id}:{dst_path}"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(f"Failed to copy {src_path}: {result.stderr}")


def start_container(image, env_vars=None, container_name=None, workdir=None):
    """Start a Docker container and return its ID.

    Args:
        image: Docker image to use
        env_vars: Dict of environment variables to set in container (optional)
        container_name: Name for the container (optional)
        workdir: Working directory in container (optional)

    Returns:
        Container ID
    """
    cmd = ["docker", "run", "-d", "--rm"]

    if container_name:
        cmd.extend(["--name", container_name])

    if env_vars:
        for key, value in env_vars.items():
            if value:
                cmd.extend(["-e", f"{key}={value}"])

    if workdir:
        cmd.extend(["-w", workdir])

    cmd.extend([image, "sleep", "infinity"])

    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return result.stdout.strip()


def cleanup_container(container_id):
    """Remove a container."""
    if container_id:
        subprocess.run(["docker", "rm", "-f", container_id], check=False, capture_output=True)


def setup_workspace(container_id, data_path, script_path, mode="e2e", copy_gt_poc=True, scripts_dir=None):
    """Set up workspace inside a container for agent or validation.

    Args:
        container_id: Docker container ID
        data_path: Local path to data directory (contains src.tgz, poc.bin, crash.log)
        script_path: Local path to script directory (contains build scripts, config.toml)
        mode: "e2e" or "patch-only"
        copy_gt_poc: Whether to copy ground truth PoC to /data (False for agent runs)
        scripts_dir: Path to scripts directory (to copy validate.py)

    Sets up:
        /src/ - source code (extracted from src.tgz) and build scripts
        /config/ - config.toml
        /data/ - ground truth poc.bin (if copy_gt_poc=True)
        /output/ - output directory
        /scripts/ - validate.py and other utility scripts
    """
    # check container's image
    container_image = (
        subprocess.run(
            ["docker", "inspect", "--format='{{.Config.Image}}'", container_id],
            capture_output=True,
            text=True,
            check=True,
        )
        .stdout.strip()
        .strip("'")
    )
    if "arvo" in container_image or "cybergym" in container_image:
        exec_run(
            container_id,
            "find /src -mindepth 1 -maxdepth 1 ! -name honggfuzz ! -name libfuzzer ! -name afl ! -name aflplusplus ! -name fuzztest -exec rm -rf {} +",
            workdir="/",
            verbose=False,
            check=True,
        )
        exec_run(container_id, "rm -rf /out /work /usr/bin/arvo", workdir="/", verbose=False, check=True)
        exec_run(container_id, "mkdir -p /out /work", workdir="/", verbose=False, check=True)

    # Create directories
    exec_run(
        container_id,
        "mkdir -p /config /data /output /scripts",
        workdir="/",
        verbose=False,
        check=True,
    )

    # Install validation dependencies (sudo for build scripts, tomli for validate.py)
    exec_run(
        container_id,
        "apt-get update -qq && apt-get install -y -qq sudo git >/dev/null 2>&1",
        workdir="/",
        verbose=False,
        check=True,
    )
    if not scripts_dir:
        raise ValueError("scripts_dir required for openhands")
    copy_to_container(container_id, scripts_dir / "install_validate_deps.sh", "/install_validate_deps.sh")
    exec_run(container_id, "bash -eux /install_validate_deps.sh", workdir="/", verbose=False, check=True)

    # Copy validate.py if scripts_dir provided
    if scripts_dir:
        validate_py = Path(scripts_dir) / "validate.py"
        if validate_py.exists():
            copy_to_container(container_id, validate_py, "/scripts/validate.py")

    # Copy and extract source
    copy_to_container(container_id, data_path / "src.tgz", "/src/src.tgz")
    exec_run(container_id, "tar xf /src/src.tgz -C /src && rm /src/src.tgz", workdir="/", verbose=False, check=True)

    # Copy crash.log and poc.bin for patch-only mode (to /src for agent to see)
    if mode == "patch-only":
        for f in ["crash.log", "poc.bin"]:
            src_file = data_path / f
            if src_file.exists():
                copy_to_container(container_id, src_file, f"/src/{f}")
        copy_gt_poc = True

    # Copy build scripts
    for script in ["prepare.sh", "compile.sh", "run_poc.sh", "test.sh"]:
        script_file = script_path / script
        if script_file.exists():
            copy_to_container(container_id, script_file, f"/src/{script}")

    # Copy config files (sanitize config.toml)
    config = tomli.loads((script_path / "../project.toml").read_text())
    config.update(tomli.loads((script_path / "config.toml").read_text()))
    new_config = {
        "repo_to_patch": config.get("repo_to_patch", ""),
        "immutable_files": config.get("immutable_files", []),
    }
    sanitized_config = tomli_w.dumps(new_config)
    exec_run(
        container_id,
        f"cat > /config/config.toml << 'EOF'\n{sanitized_config}EOF",
        workdir="/",
        verbose=False,
        check=True,
    )

    # Apply pre_patches if specified in config (applied before agent starts and before validation backup)
    # pre_patches is a list of patch files to apply sequentially
    pre_patches = config.get("pre_patches", [])
    # Also support legacy single pre_patch field
    if not pre_patches and config.get("pre_patch"):
        pre_patches = [config["pre_patch"]]
    repo_to_patch = config.get("repo_to_patch", "")
    pre_patch_repo = f"/src/{repo_to_patch}" if repo_to_patch else "/src"
    for i, pre_patch_name in enumerate(pre_patches):
        pre_patch_file = script_path / pre_patch_name
        if not pre_patch_file.exists():
            raise Exception(f"pre_patch file not found: {pre_patch_file}")
        container_path = f"/config/pre_patch_{i}.diff"
        copy_to_container(container_id, pre_patch_file, container_path)
        # Try multiple strip levels, same logic as validate.py's apply_patch
        applied = False
        for strip_level in [0, 1, 2, 3]:
            if strip_level == 0:
                cmd = f"cd {pre_patch_repo} && git apply {container_path}"
            else:
                cmd = f"cd {pre_patch_repo} && patch -p{strip_level} < {container_path}"
            code, _, _ = exec_run(container_id, cmd, workdir="/", verbose=False)
            if code == 0:
                applied = True
                break
        if not applied:
            raise Exception(f"Failed to apply pre_patch {pre_patch_name} with strip levels 0-3")

    # Copy ground truth PoC to /data (for validation, not for agent)
    if copy_gt_poc:
        gt_poc = data_path / "poc.bin"
        if gt_poc.exists():
            copy_to_container(container_id, gt_poc, "/data/poc.bin")


def exec_run(container_id, command, description=None, timeout=1200, env=None, workdir=None, verbose=True, check=False):
    """
    Execute command in container.

    Args:
        container_id: Docker container ID
        command: Shell command to run
        description: Human-readable description (printed if verbose)
        timeout: Command timeout in seconds
        env: Environment variables dict
        workdir: Working directory inside the container
        verbose: Whether to print description
        check: If True, raise exception on non-zero exit code
    Returns:
        tuple: (exit_code, stdout, stderr)
    """
    if verbose and description:
        print(f"  {description}")
    cmd = ["docker", "exec"]
    if env:
        for key, value in env.items():
            cmd.extend(["-e", f"{key}={value}"])
    if workdir:
        cmd.extend(["-w", workdir])
    if isinstance(command, list):
        cmd.extend([container_id, "timeout", str(timeout), "bash", "-c"] + command)
    else:
        cmd.extend([container_id, "timeout", str(timeout), "bash", "-c", command])
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout + 10, errors='replace')
    if check and result.returncode != 0:
        raise Exception(f"Exec failed: {result.stdout}, {result.stderr}")
    return result.returncode, result.stdout, result.stderr


def call_llm(
    prompt,
    model_provider="anthropic",
    litellm_model_id=None,
    bedrock_model_id=None,
    anthropic_model_id=None,
    aws_region="us-west-2",
    aws_profile=None,
    max_tokens=2000,
):
    """
    Call LLM with a prompt and return the response.
    """
    try:
        if model_provider == "bedrock":
            session = boto3.Session(profile_name=aws_profile, region_name=aws_region)
            client = session.client("bedrock-runtime")

            response = client.converse(
                modelId=bedrock_model_id,
                messages=[{"role": "user", "content": [{"text": prompt}]}],
                inferenceConfig={"maxTokens": max_tokens, "temperature": 0.0},
            )
            return response["output"]["message"]["content"][0]["text"]
        elif model_provider == "anthropic":
            import anthropic

            client = anthropic.Anthropic()
            response = client.messages.create(
                model=anthropic_model_id,
                max_tokens=max_tokens,
                temperature=0.0,
                messages=[{"role": "user", "content": prompt}],
            )
            return response.content[0].text
        else:
            # OpenAI
            import openai

            client = openai.OpenAI()
            response = client.chat.completions.create(
                model=litellm_model_id,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=max_tokens,
                temperature=0.0,
            )
            return response.choices[0].message.content
    except Exception as e:
        print(f"LLM call failed: {e}")
        return None


def get_llm_env(
    model_provider,
    litellm_model_id=None,
    bedrock_model_id=None,
    anthropic_model_id=None,
    aws_region="us-west-2",
    aws_profile=None,
):
    """
    Get LLM environment variables for OpenHands.

    Args:
        model_provider: "bedrock", "anthropic", or "litellm"
        litellm_model_id: LiteLLM model ID (required if model_provider="litellm")
        bedrock_model_id: Bedrock model ID (required if model_provider="bedrock")
        anthropic_model_id: Anthropic model ID (required if model_provider="anthropic")
        aws_region: AWS region for Bedrock
        aws_profile: AWS profile name for credentials

    Returns:
        tuple: (env_dict, llm_model_string)
    """
    base_env = {
        "RUNTIME": "local",
        "LOG_ALL_EVENTS": "true",
        "SAVE_TRAJECTORY_PATH": "/agent_trajectory",
        "RUN_AS_OPENHANDS": "false",
        "SKIP_DEPENDENCY_CHECK": "1",
        "AGENT_ENABLE_PROMPT_EXTENSIONS": "false",
        "AGENT_ENABLE_BROWSING": "false",
        "ENABLE_BROWSER": "false",
        # Retry settings for rate limiting
        "LLM_NUM_RETRIES": "10",
        "LLM_RETRY_MIN_WAIT": "15",
        "LLM_RETRY_MAX_WAIT": "120",
        "LLM_RETRY_MULTIPLIER": "2",
    }

    if model_provider == "bedrock":
        try:
            session = boto3.Session(profile_name=aws_profile)
            credentials = session.get_credentials()
            frozen_credentials = credentials.get_frozen_credentials()
            aws_access_key = frozen_credentials.access_key
            aws_secret_key = frozen_credentials.secret_key
            aws_session_token = frozen_credentials.token
        except Exception as e:
            print(f"Failed to get AWS credentials: {e}")
            aws_access_key = os.getenv("AWS_ACCESS_KEY_ID", "")
            aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY", "")
            aws_session_token = os.getenv("AWS_SESSION_TOKEN", "")

        llm_model = f"bedrock/{bedrock_model_id}"
        env = {
            **base_env,
            "LLM_MODEL": llm_model,
            "LLM_AWS_ACCESS_KEY_ID": aws_access_key,
            "LLM_AWS_SECRET_ACCESS_KEY": aws_secret_key,
            "LLM_AWS_REGION_NAME": aws_region,
            "LLM_DROP_PARAMS": "true",
            "LLM_TEMPERATURE": "0.0",
            "AWS_ACCESS_KEY_ID": aws_access_key,
            "AWS_SECRET_ACCESS_KEY": aws_secret_key,
            "AWS_REGION_NAME": aws_region,
        }
        if aws_session_token:
            env["AWS_SESSION_TOKEN"] = aws_session_token
            env["LLM_AWS_SESSION_TOKEN"] = aws_session_token
        return env, llm_model
    elif model_provider == "anthropic":
        anthropic_api_key = os.getenv("ANTHROPIC_API_KEY", "")
        llm_model = anthropic_model_id
        env = {
            **base_env,
            "LLM_MODEL": llm_model,
            "LLM_API_KEY": anthropic_api_key,
            "ANTHROPIC_API_KEY": anthropic_api_key,
        }
        return env, llm_model
    else:
        llm_model = litellm_model_id
        llm_api_key = os.getenv("OPENAI_API_KEY")
        env = {
            **base_env,
            "LLM_API_KEY": llm_api_key,
            "LLM_MODEL": llm_model,
            "OPENAI_API_KEY": llm_api_key,
            "GEMINI_API_KEY": llm_api_key,
        }
        if os.getenv("OPENAI_BASE_URL"):
            env["OPENAI_BASE_URL"] = os.getenv("OPENAI_BASE_URL")
        if os.getenv("GOOGLE_GEMINI_BASE_URL"):
            env["GOOGLE_GEMINI_BASE_URL"] = os.getenv("GOOGLE_GEMINI_BASE_URL")
        return env, llm_model


def litellm_generate_api_key(max_budget: float, key_alias: str) -> str:
    LITELLM_BASE_URL = os.getenv("LITELLM_BASE_URL")
    LITELLM_MASTER_KEY = os.getenv("LITELLM_MASTER_KEY")
    with httpx.Client(base_url=LITELLM_BASE_URL, timeout=60) as client:
        response = client.post(
            "/key/generate",
            json={"max_budget": max_budget, "key_alias": key_alias},
            headers={"Authorization": f"Bearer {LITELLM_MASTER_KEY}"},
        )
        response.raise_for_status()
        data = response.json()
        return data["key"]


def litellm_delete_api_key(api_key: str):
    LITELLM_BASE_URL = os.getenv("LITELLM_BASE_URL")
    LITELLM_MASTER_KEY = os.getenv("LITELLM_MASTER_KEY")
    with httpx.Client(base_url=LITELLM_BASE_URL, timeout=60) as client:
        response = client.post(
            "/key/delete",
            json={"keys": [api_key]},
            headers={"Authorization": f"Bearer {LITELLM_MASTER_KEY}"},
        )
        response.raise_for_status()


def litellm_get_api_key_usage(api_key: str) -> dict:
    LITELLM_BASE_URL = os.getenv("LITELLM_BASE_URL")
    LITELLM_MASTER_KEY = os.getenv("LITELLM_MASTER_KEY")
    with httpx.Client(base_url=LITELLM_BASE_URL, timeout=60) as client:
        response = client.get(
            "/key/info",
            params={"key": api_key},
            headers={"Authorization": f"Bearer {LITELLM_MASTER_KEY}"},
        )
        response.raise_for_status()
        data = response.json()
        return data["info"]
