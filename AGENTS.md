# AGENTS.md

> Use this file as the fast-path operating guide for AI coding agents.
> Prefer repository truth over assumptions — check the files referenced below.

## Project Overview

Companion repository for the blog post *"Pimp your Charts with the fancy XKCD Style"*.
It is a **Python / Jupyter data-science project**: XKCD-styled matplotlib charts plus
scikit-learn ML examples (regression, classification, clustering, dimensionality
reduction), delivered as notebooks. There is no application to build — the deliverable
is the notebooks under `work/` and the charts they render.

## Architecture

- **`work/`** — all notebooks (mounted into the container at `/home/jovyan/work`).
  Top level holds chart/reporting examples (`Bar Chart.ipynb`, `Pie Chart example.ipynb`,
  `Management Report.ipynb`, `Custom Font example.ipynb`); subfolders group ML topics:
  `linear-classifiers/`, `supervised-learning/`, `unsupervised-learning/`.
- **`work/datasets/`** — local data (gitignored). Notebooks also read from S3/MinIO via
  boto3/smart_open (see the `Covid 19 Data Lake.ipynb` notebook).
- **`Dockerfile`** — extends `quay.io/jupyter/scipy-notebook`, adding `fonts-humor-sans`
  (the XKCD font), `graphviz`, `boto3`, `smart_open`, and `pyhive` (trino/Hive).
- **`docker-compose.yaml`** — runs the notebook lab plus a MinIO S3 service with
  `raw-data` and `processed-data` buckets.
- **`k8s/`** — Kubernetes deployment for running the same image on Minikube.

## Development Workflow

Task automation lives in the `justfile` — run `just --list` to see every recipe.
There is no test suite or linter; `just validate` is the closest thing to a check.

- **Start the environment (Docker Compose):** `just up` (detached).
  Lab is at http://localhost:8888/ — JupyterHub token is `xkcd`. MinIO console at :9001.
  `just open` opens the Lab with the token pre-filled.
- **Stop:** `just down`.
- **Rebuild after changing `Dockerfile`:** `just build` (or `just rebuild` to build + restart).
- **Validate a change:** `just validate` runs the sailing logbook end-to-end in the image
  (headless restart-kernel-run-all); `just execute <work/….ipynb>` does the same for any
  notebook. Confirm every cell runs clean and the chart renders.
- **Minikube path:** `just minikube-build`, `just minikube-deploy`, then `just minikube-forward`
  — see `README.md` for the `.aws/credentials` prerequisite.

## Key Conventions

- **The XKCD look** comes from matplotlib's `plt.xkcd()` context plus a hand-drawn font
  installed in the image. matplotlib 3.11+ looks for **Comic Neue** (`fonts-comic-neue`);
  it dropped "Humor Sans" from `plt.xkcd()`'s font list, so a missing Comic Neue silently
  falls back to DejaVu (sketch wiggle stays, but the lettering isn't hand-drawn). The
  font must be present in the container, not just referenced.
- **New examples go in the topic subfolder** under `work/` (e.g. a new classifier demo
  belongs in `work/linear-classifiers/`), not at the top level.
- **Secrets are container env, not code:** the JupyterHub token, MinIO keys, and AWS
  credentials are supplied via `docker-compose.yaml` / mounted `.aws/credentials` — never
  hardcode them in a notebook.
- **When editing a notebook, change only the target cells.** Avoid re-running and
  re-saving every cell, which rewrites all `execution_count` values and output blobs and
  buries the real change in diff noise.

## Coding Principles

- **State assumptions** before starting. If a task has multiple valid interpretations, present them rather than picking silently. Data terms like "average", "growth", and "significant" are ambiguous — confirm the intended meaning.
- **Simplicity first.** Minimum code that solves the problem. No features beyond what was asked. No abstractions for single-use code. No error handling for impossible scenarios.
- **Surgical changes.** Touch only what the task requires. Do not improve adjacent code, comments, or formatting. Every changed line should trace directly to the user's request.
- When your changes create orphans (unused imports, variables, functions), remove them. Do not remove pre-existing dead code unless asked.

## Important Files

- `justfile` — task automation (environment up/down, image build, notebook validation, Minikube); `just --list`.
- `README.md` — how to run the environment (Docker Compose and Minikube) and the extra tooling (graphviz, boto3, Spark, scikit-learn).
- `Dockerfile` — the exact Python/system stack every notebook can rely on.
- `docker-compose.yaml` — services, ports, tokens, and MinIO bucket setup.
- `work/` — the notebooks themselves; read the one you are changing before editing.
