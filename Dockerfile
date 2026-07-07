# https://quay.io/repository/jupyter/scipy-notebook?tab=tags
# Multi-arch tag (no aarch64- prefix) so the image also builds on amd64.
FROM quay.io/jupyter/scipy-notebook:lab-4.6.1

USER root

RUN apt-get update
# fonts-humor-sans: the classic XKCD font. fonts-comic-neue: what matplotlib's
# plt.xkcd() looks for since v3.11 (it dropped "Humor Sans" from its font list),
# so the hand-drawn lettering renders instead of a silent DejaVu fallback.
RUN apt-get install -y apt-utils fonts-humor-sans fonts-comic-neue

# Add graphviz (system package)
RUN apt-get install -y graphviz

# 'local' Python environment
USER jovyan

# Add graphviz (Python package)
RUN pip install graphviz==0.21

# Add support to connect to S3 buckets (e.g. from AWS or MinIO)
RUN pip install boto3==1.43.41
RUN pip install smart_open==8.0.0

# Add support for trino/Hive
RUN pip install pyhive==0.7.0

# Add mapping libraries for the GPX sailing logbook (work/logbook/)
RUN pip install folium==0.20.0
RUN pip install shapely==2.1.2

RUN rm -rf /home/jovyan/.cache/matplotlib/
