import importlib.util
import io
import sys
import tempfile
import warnings
from contextlib import redirect_stdout
from itertools import combinations
from pathlib import Path
from unittest import mock


MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "generate_challenge.py"
# Load the generator script directly so CI can gate on this file alone.
SPEC = importlib.util.spec_from_file_location("generate_challenge", MODULE_PATH)
generate_challenge = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(generate_challenge)


def run():
    expected_counts = {"easy": 1, "medium": 2, "hard": 3}
    all_faults = list(generate_challenge.FAULTS)
    failures = []

    for difficulty, expected_count in expected_counts.items():
        # Check every valid fault combination for the current difficulty.
        for combo in combinations(all_faults, expected_count):
            forced_faults = list(combo)
            with tempfile.TemporaryDirectory() as tmpdir:
                output_dir = Path(tmpdir)
                with mock.patch.object(generate_challenge, "OUT", output_dir):
                    with mock.patch.object(
                        generate_challenge,
                        "pick_faults",
                        return_value=forced_faults,
                    ):
                        with mock.patch.object(
                            sys,
                            "argv",
                            [
                                "generate_challenge.py",
                                "--seed",
                                "123",
                                "--difficulty",
                                difficulty,
                            ],
                        ):
                            with warnings.catch_warnings():
                                warnings.simplefilter("ignore", ResourceWarning)
                                warnings.simplefilter("ignore", DeprecationWarning)
                                with redirect_stdout(io.StringIO()):
                                    generate_challenge.main()

                brief = (output_dir / "BRIEF.md").read_text()
                actual_faults = [
                    fault_name
                    for fault_name, objective in generate_challenge.OBJECTIVES.items()
                    if objective in brief
                ]
                actual_count = len(actual_faults)
                actual_unique_count = len(set(actual_faults))
                ok = (
                    actual_count == expected_count
                    and actual_unique_count == actual_count
                    and set(actual_faults) == set(forced_faults)
                )
                status = "PASS" if ok else "FAIL"
                print(
                    f"{status} {difficulty}: expected faults={forced_faults}; "
                    f"expected fault_count={expected_count}, unique_count={expected_count}; "
                    f"actual fault_count={actual_count}, unique_count={actual_unique_count}; "
                    f"actual faults={actual_faults}"
                )
                if not ok:
                    failures.append(
                        {
                            "difficulty": difficulty,
                            "expected_faults": forced_faults,
                            "expected_fault_count": expected_count,
                            "actual_faults": actual_faults,
                            "actual_fault_count": actual_count,
                            "actual_unique_count": actual_unique_count,
                        }
                    )

    # Non-zero exit lets CI fail fast if any generated combo is wrong.
    if failures:
        print(f"FAIL duplicate-or-mismatched fault combinations={len(failures)}")
        return 1

    print("PASS all generated fault combinations are unique")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
