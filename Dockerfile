# https://quay.io/repository/jupyter/scipy-notebook?tab=tags
FROM quay.io/jupyter/scipy-notebook:aarch64-lab-4.0.8

USER root

RUN apt-get update
RUN apt-get install -y apt-utils fonts-humor-sans

# Add graphviz (system package)
RUN apt-get install -y graphviz

# 'local' Python environment
USER jovyan

# Add graphviz (Python package)
RUN pip install graphviz

# Add support to connect to S3 buckets (e.g. from AWS or MinIO)
RUN pip install boto3
RUN pip install smart_open

# Add support for trino/Hive
RUN pip install pyhive

RUN rm -rf /home/jovyan/.cache/matplotlib/
