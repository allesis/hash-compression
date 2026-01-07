# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "wandb",
# ]
# ///

# loading variables from .env file
import sys
import csv
from os import getenv, path
from dotenv import load_dotenv
from pathlib import Path
import wandb
import itertools


def main() -> None:
    wandb.login()
    load_dotenv()
    video_name: str
    results_path_str: str
    results_path: path
    results: [(str, [float])]

    if len(sys.argv) != 3:
        usage()
        exit(-1)

    video_name = sys.argv[1]
    results_path_str = sys.argv[2]

    results_path = Path(results_path_str)

    with open(path.join(results_path, "vqmcli_results.csv")) as file:
        results = []
        for line in file:
            # HACK: This pattern does not spark joy...
            # But the alternative is mutating in place instead of reassigning
            # So we go with this
            if len(results) == 0:
                results = process_result_labels(line)
            else:
                results = process_result_line(line, results)

    if getenv("DISABLE_VQMCLI_WANDB_RECORDING") == None:
        log_results_to_wandb(results)


def process_result_labels(line: str) -> [(str, [float])]:
    labels: [str]
    results: [(str, [float])]
    labels = line.strip("\n").split(",")
    results = list(map(lambda label: (label, []), labels))
    return results


def process_result_line(line: str, results: [(str, [float])]) -> [(str, [float])]:
    values: [float]
    values = line.strip("\n").split(",")
    for result, value in zip(results, values):
        result[1].append(float(value))

    return results


def log_results_to_wandb(results_tuples: [(str, [float])]) -> None:
    results_dictionary: dict
    project_name: str
    results_dictionary = {}

    project_name = getenv("VQMCLI_WANDB_PROJECT_NAME")

    if project_name == None:
        explain_environment_issues()
        exit(-1)

    with wandb.init(project=project_name) as run:
        while True:
            for name, results in results_tuples:
                # HACK: This is a bad way to do things
                # But there isn't a cleaner way that's as simple
                if len(results) == 0:
                    return

                results_dictionary[name] = results.pop()

            run.log(results_dictionary)


def usage() -> None:
    print("Script called with invalid parameters")
    print("Usage: `uv run upload.py <name> <path>`")


def explain_environment_issues() -> None:
    print("Required environment variables were not found in the environment")
    print("Please ensure the following environment variables are set before retrying:")
    print("\tVQMCLI_WANDB_PROJECT_NAME")


if __name__ == "__main__":
    main()
