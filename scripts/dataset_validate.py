import time
import sys
from pathlib import Path
import tomli
from run_agent import run_final_validation

if __name__ == "__main__":
    task_path = sys.argv[1]

    # Final validation with fresh containers per stage
    print("\nFinal validation - fresh container per stage...")
    validation_start = time.time()

    data_path = Path("./data/projects") / task_path
    script_path = Path("./projects") / task_path
    config = tomli.loads((script_path / "../project.toml").read_text())
    config.update(tomli.loads((script_path / "config.toml").read_text()))
    build_image = config.get(
        "build_image",
        "gcr.io/oss-fuzz-base/base-builder@sha256:8eda74a11e800aead5a041ee479a65b33dab3150d6e89e5694e2b6eb27be98fc",
    )

    results = run_final_validation(
        poc_path=data_path / "poc.bin",
        patch_path=script_path / "patch.diff",
        data_path=data_path,
        script_path=script_path,
        build_image=build_image,
        mode="e2e",
    )
    validation_time = time.time() - validation_start
    print(f"  Validation: {validation_time:.1f}s")
    print(f"  Results: {results}")
