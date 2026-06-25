# CyberGym-E2E: Scalable Real-World Benchmark for AI Agents' End-to-End Cybersecurity Capabilities

[![Website](https://img.shields.io/badge/Website-cybergym.io-0a9396?style=flat&logo=Google-Chrome&logoColor=white)](https://www.cybergym.io/cybergym-e2e/)
[![ArXiv](https://img.shields.io/badge/arXiv-2606.04460-b31b1b?style=flat&logo=arxiv&logoColor=white)](https://arxiv.org/abs/2606.04460)
[![Hugging Face](https://img.shields.io/badge/HuggingFace-cybergym--e2e-orange?logo=huggingface&logoColor=white)](https://huggingface.co/datasets/sunblaze-ucb/cybergym-e2e)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

CyberGym-E2E is a large-scale benchmark built from real-world vulnerabilities in widely used open-source projects to evaluate AI agents' end-to-end cybersecurity capabilities, from discovering vulnerabilities to generating proof-of-concept to writing patches.

## Evaluation Modes

- **End-to-end (`e2e`):** The agent receives only source code, and must find the vulnerability, generate a proof-of-concept (`poc.bin`), and produce a patch (`fix.patch`).
- **Patch-only (`patch-only`):** The agent receives source code along with a crash log and PoC, and must produce a patch.

Validation runs in four stages:
1. Agent PoC triggers a crash without the patch
2. Agent PoC does not crash with the patch applied
3. Project test suite passes with the patch applied
4. Ground-truth PoC does not crash with the patch applied

## Setup

Install Python dependencies:
```bash
pip install tomli tomli_w anthropic openai boto3 httpx huggingface_hub docker
```

Download the benchmark data from HuggingFace:
```bash
export HF_TOKEN=...
hf download sunblaze-ucb/cybergym-e2e --repo-type dataset --local-dir data/
```

Download the Docker images:
```bash
python scripts/pull_images.py
```

Set ASLR entropy for sanitizer compatibility:
```bash
sudo sysctl -w vm.mmap_rnd_bits=28
```

## Running the Agent

### Single Task

```bash
# End-to-end mode
python scripts/run_agent.py curl/arvo_66012 --mode e2e

# Patch-only mode
python scripts/run_agent.py curl/arvo_66012 --mode patch-only
```

### Batch Run

```bash
# Run all tasks in a task file
MODE=e2e MAX_PARALLEL=4 bash scripts/batch_run.sh scripts/tasks.txt
```

## Citation

If you use this project in your research, please cite:

```bibtex
@inproceedings{shi2026cybergyme2e,
  title={CyberGym-E2E: Scalable Real-World Benchmark for {AI} Agents' End-to-End Cybersecurity Capabilities},
  author={Shi, Tianneng and Rheem, Robin and Jiang, Dongwei and Wang, Mona and De La Riega, Francisco and Wang, Zhun and Jiang, Jingzhi and Cheung, Alexander and Tai, Sean and Cha, Jonah and Tu, Jianhong and Han, Gabriel and Wang, Chenguang and He, Jingxuan and Guo, Wenbo and Song, Dawn},
  booktitle={Proceedings of the 43rd International Conference on Machine Learning},
  year={2026},
  url={https://arxiv.org/abs/2606.04460},
}
```

## License

This project is licensed under the [Apache License 2.0](LICENSE).
