# Pimp your Charts with the fancy XKCD Style

You like the cool [XKCD](http://xkcdgraphs.com/) Look and Feel of the teaser chart?
Then this repo/post is what you are looking for!

![Woo Hoo!!! example](https://devops.datenkollektiv.de/assets/images/2018/11/xkcd-teaser.svg)

This repo is a companion of the post [Pimp your Charts with the fancy XKCD Style](https://devops.datenkollektiv.de/pimp-your-charts-with-the-fancy-xkcd-style.html).

Please check the post mentioned above for more details.

## For the Impatient

> [jupyterhub](https://jupyter.org/hub) - A multi-user version of the notebook designed for companies, classrooms and research labs

### With Docker Compose

```shell
docker compose up
xkcd_1  | Executing the command: jupyter lab
xkcd_1  | [I 16:44:48.348 LabApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
```

> Note: The token of this setup is `xkcd`!

Visit your local jupyterhub [http://localhost:8888/](http://localhost:8888/).

### With Minikube

Build the container in `docker-env`:

```shell
eval $(minikube docker-env)
docker build -t xkcd-notebook .
```

...once the image is successfully built and tagged...

```shell
kubectl create namespace xkcd
kubectl -n xkcd create secret generic aws-credentials --from-file=.aws/credentials
kubectl -n xkcd apply -f k8s/xkcd-notebook-deployment.yaml
NOTEBOOK_POD_NAME=$(kubectl get pods -n xkcd -l app=xkcd-notebook -o json | jq -r '.items[0].metadata.name')
kubectl -n xkcd port-forward ${NOTEBOOK_POD_NAME} 8888:8888
```

> Note: The token of this setup is `xkcd`!

Visit your local jupyterhub [http://localhost:8888/](http://localhost:8888/).

## Kick-off Graphviz

Empower the setup with [graphviz](https://graphviz.org/)

```Dockerfile
RUN apt-get install graphviz
RUN pip install graphviz
```

Check the [Introduction to Graphviz in Jupyter Notebook](https://h1ros.github.io/posts/introduction-to-graphviz-in-jupyter-notebook/) for more in-depth information. 

## Read data from an S3 bucket

We use [boto3](https://pypi.org/project/boto3/) to interact with an S3 bucket.

```Dockerfile
RUN pip install boto3
```

Link your `.aws/credentials` into the container like follows:

```yaml
services:
  xkcd-jupyterhub:
    volumes:
     - .aws/credentials:/home/jovyan/.aws/credentials
```

[](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#bucket)

## Tap into Apache Spark with Jupyter

Pimp the current setup:

```Dockerfile
RUN pip install findspark
```

Inside your Jupyter notebook:

```Python
import findspark
```
