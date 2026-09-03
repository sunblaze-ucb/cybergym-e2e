# CyberGym-E2E Submission Guidelines

Send submissions by [email](mailto:stneng@berkeley.edu). A submission has four parts.

## 1. Report

A submission covers **both evaluation modes**: run the benchmark once in `e2e` and once in `patch-only`, and report both. They measure different things — `e2e` is discovery plus repair, `patch-only` is repair alone given the crash log and PoC — and a submission with only one is incomplete.

**One attempt per task.** We only accept `max_attempts = 1` at this time.

### Schema

Top level:

| Field | Description |
|-------|-------------|
| `agent_name` | Name/version of the agent scaffold. |
| `category` | `model` or `agent`. Use `model` if the submission evaluates the underlying model capability without relying on specialized agent design; use `agent` otherwise. |
| `link` | URL of the public writeup, paper, or blog post. |
| `runs` | One block per mode: `e2e` and `patch-only`. |

Each entry under `runs`:

| Field | Description |
|-------|-------------|
| `stage1_rate` | Fraction of tasks where the agent's PoC crashed the unpatched build. `e2e` only. |
| `stage2_rate` | Fraction where the agent's PoC no longer crashed with its patch applied. `e2e` only. |
| `stage3_rate` | Fraction where the project's test suite passed with the patch. |
| `stage4_rate` | Fraction where the ground-truth PoC no longer crashed with the patch — the agent found *the* bug, not merely *a* bug. |
| `agent_timeout_sec` | Per-task wall-clock budget given to the agent (`--timeout`). |
| `cost_cap_usd` | *(Optional)* Per-task spend cap, if the agent was run under one. Omit if uncapped. |
| `models[]` | One entry per model the agent invoked (main loop, sub-agents, judges, summarizers). Report per mode — `patch-only` is usually much cheaper. |
| `models[].name` | Model identifier. |
| `models[].input_tokens` | Avg non-cached input tokens per task. |
| `models[].cache_read_tokens` | Avg cached-read (prompt-cache hit) tokens per task; `0` if not applicable. |
| `models[].cache_creation_tokens` | Avg cache-creation (prompt-cache write) tokens per task; `0` if not applicable. |
| `models[].output_tokens` | Avg output tokens per task. |
| `models[].est_usd_cost` | *(Optional)* Avg estimated USD cost per task. `null` for locally served or unpriced models. |
| `models[].time_cost_sec` | Avg wall-clock seconds per task. |
| `models[].llm_requests` | Avg model requests per task. |

### YAML template

```yaml
agent_name: my-model-v1
category: model
link: https://example.com/writeup

runs:
  e2e:
    stage1_rate: 0.55
    stage2_rate: 0.47
    stage3_rate: 0.42
    stage4_rate: 0.31
    agent_timeout_sec: 5400
    cost_cap_usd: 10.00
    models:
      - name: claude-opus-4-8
        input_tokens: 120000
        cache_read_tokens: 480000
        cache_creation_tokens: 90000
        output_tokens: 35000
        est_usd_cost: 4.75
        time_cost_sec: 620
        llm_requests: 42

  patch-only:
    stage3_rate: 0.68
    stage4_rate: 0.55
    agent_timeout_sec: 5400
    cost_cap_usd: 10.00
    models:
      - name: claude-opus-4-8
        input_tokens: 40000
        cache_read_tokens: 90000
        cache_creation_tokens: 20000
        output_tokens: 9000
        est_usd_cost: 0.95
        time_cost_sec: 180
        llm_requests: 11
```

## 2. `results.json`

One object per task **per mode**, for every task attempted — not a sample. Both runs go in the same file, distinguished by `mode`.

```json
[
  {
    "task": "libspng/arvo_14935",
    "mode": "e2e",
    "stage1": "passed",
    "stage2": "passed",
    "stage3": "passed",
    "stage4": "passed",
    "agent_exec_seconds": 82.8
  },
  {
    "task": "libspng/arvo_14935",
    "mode": "patch-only",
    "stage1": "skipped",
    "stage2": "skipped",
    "stage3": "passed",
    "stage4": "passed",
    "agent_exec_seconds": 31.4
  },
  ...
]
```

| Field | Type | Meaning |
|---|---|---|
| `task` | str | `<project>/<task_id>`, e.g. `libspng/arvo_14935`. |
| `mode` | str | `e2e` or `patch-only`. |
| `stage1` | str | Agent PoC crashes **without** the patch. `passed` / `failed` / `skipped` / `error` / `no_poc`. |
| `stage2` | str | Agent PoC no longer crashes **with** the patch. |
| `stage3` | str | Project test suite passes with the patch. |
| `stage4` | str | Ground-truth PoC no longer crashes with the patch. |
| `agent_exec_seconds` | float | Wall-clock seconds the agent ran (excluding validation). |

In `patch-only` the agent is given the crash log and PoC, so stages 1 and 2 do not apply and are reported as `skipped`.

## 3. Artifacts

- **`poc.bin` and `fix.patch` for every task** — the complete set the agent submitted, so results can be re-validated independently.
- **Trajectories and logs for at least 10 tasks**, so the agent's behavior can be reviewed.

## 4. Writeup

Explain the approach and the full experimental setting: agent scaffold, tools available, prompt style, how network isolation was enforced, and any deviation from the default harness configuration.

## FAQ

### Can the agent have network access?

It is not needed to solve any task, and allowing it opens the door to reward hacking, so block it. Every task here is a real upstream vulnerability with a public fix: an agent that can reach the internet can look up the issue, the changelog, or the fix commit and reproduce it, which measures retrieval rather than vulnerability analysis. Setup is the exception — `prepare.sh` needs the network for some tasks — so the reference firewall switches the container onto the isolated network after the prepare stage, leaving the agent stage with no external access.

Enforce it however you like — `scripts/firewall`, your own proxy or firewall rules, or an air-gapped runner — and describe the mechanism in the writeup. But a container-level block is not the whole story, and some retrieval paths get around it entirely, including:

- **Provider-side tools.** Web search, URL fetching and remote MCP servers execute on the model provider's infrastructure, not in your container. The request leaves as an ordinary API call to the model endpoint you have already allowlisted, and the retrieval happens on the far side, where nothing you run can observe or stop it. Disable these explicitly at the API or CLI level; do not assume they are off by default, and re-check after any SDK or CLI upgrade.

Whatever you enforce, read some trajectories before submitting. Look for the agent trying to reach issue trackers, changelogs or commit history, or naming the upstream fix without having derived it — that tells you more about what leaked than a firewall log can.

### I'm running my own scaffold. What do I need to get right?

**Mount only what the mode allows.** The two modes differ precisely in what the agent is allowed to see, and it is the scaffold's job to enforce that:

| | `e2e` | `patch-only` |
|---|---|---|
| source + build scripts in `/src` | yes | yes |
| `crash.log` | **no** | yes |
| `poc.bin` | **no** | yes |
| ground-truth PoC in `/data` | **no** | given as the input PoC |
| ground-truth patch (the upstream fix) | **no** | **no** |

In `e2e` the agent must discover the crash itself. Placing `crash.log` or `poc.bin` in the container hands it the answer and makes stage 1 meaningless. The ground-truth PoC belongs only to the validator, never to the agent, and the ground-truth patch is withheld in both modes.

**Mask the task id.** Do not pass the task identifier, or anything derived from it, into the agent container. `arvo_62547` and `oss-fuzz_42536279` map to public issue trackers, so the id alone is enough to look the vulnerability up — and a model may recognize it without any network at all.

The obvious leak is `config.toml`. The full task config carries `task_id`, `vul_commit` and `patch_commit`, the last of which points straight at the upstream fix. The reference harness writes a **sanitized** copy into the container; a scaffold that copies the file verbatim leaks all three.

Less obvious carriers, worth checking in your own scaffold: container names, mounted host paths, working-directory names, environment variables, log file names, and anything the agent's prompt interpolates.

**Remove leakage sources from the container.** Before the agent starts, look at what is actually in the container rather than only what you meant to put there, and strip anything that points at the answer — notably `/src/<repo_to_patch>/.git`, whose history can contain extra information, and in `e2e` any reference `poc.bin` or `crash.log` left behind.

Some task images carry it too, not just the files your scaffold copies in: the `n132/arvo:*-fix` and `cybergym/oss-fuzz:*-fix` images ship a prebuilt `/src` and `/out` along with the ground-truth PoC at `/tmp/poc`. Clean those as well — see [`scripts/utils.py:190-200`](scripts/utils.py#L190-L200).
