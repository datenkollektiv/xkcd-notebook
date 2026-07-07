# xkcd-notebook — development tasks
#
# XKCD-styled matplotlib + scikit-learn Jupyter notebooks, served from a
# scipy-notebook image (JupyterLab on :8888, token 'xkcd') alongside MinIO.
# Prerequisites: Docker (+ Compose v2). Minikube + kubectl for the k8s path.

compose := "docker compose"
service := "xkcd-scipy-notebook-lab"
port    := "8888"
token   := "xkcd"
lab_url := "http://localhost:" + port + "/lab?token=" + token

# Notebook run by `just validate` (repo-relative). Override: `just execute work/....ipynb`
notebook := "work/logbook/navionics_logbook.ipynb"

# Minikube / Kubernetes
image     := "xkcd-notebook"
namespace := "xkcd"

# List available recipes
default:
    @just --list

# ── Environment (Docker Compose) ─────────────────────────────

# Start JupyterLab (:8888, token 'xkcd') + MinIO, detached
up:
    {{compose}} up -d

# Stop and remove the containers
down:
    {{compose}} down

# (Re)build the notebook image — run after editing the Dockerfile
build:
    {{compose}} build

# Rebuild the image and (re)start the stack
rebuild: build up

# Follow the JupyterLab container logs
logs:
    {{compose}} logs -f {{service}}

# Open JupyterLab in the browser (token pre-filled)
open:
    open "{{lab_url}}"

# ── Notebooks ────────────────────────────────────────────────

# Run a notebook end-to-end in the container, headless (restart-kernel-run-all); defaults to the logbook
execute notebook=notebook: up
    {{compose}} exec -T {{service}} \
        jupyter nbconvert --to notebook --execute --inplace \
        --ExecutePreprocessor.timeout=600 \
        "/home/jovyan/{{notebook}}"

# Validate the sailing logbook end-to-end (the default `execute` target)
validate: execute

# ── Minikube / Kubernetes ────────────────────────────────────

# Build the image into Minikube's docker-env
minikube-build:
    eval "$(minikube docker-env)" && docker build -t {{image}} .

# Create namespace + AWS-credentials secret and apply the deployment (needs .aws/credentials — see README)
minikube-deploy:
    -kubectl create namespace {{namespace}}
    kubectl -n {{namespace}} create secret generic aws-credentials --from-file=.aws/credentials
    kubectl -n {{namespace}} apply -f k8s/xkcd-notebook-deployment.yaml

# Port-forward the notebook pod to http://localhost:8888 (token 'xkcd')
minikube-forward:
    #!/usr/bin/env bash
    set -euo pipefail
    POD=$(kubectl get pods -n {{namespace}} -l app={{image}} -o jsonpath='{.items[0].metadata.name}')
    kubectl -n {{namespace}} port-forward "$POD" {{port}}:{{port}}
