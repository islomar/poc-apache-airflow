#!/usr/bin/env sh

echo $1

PARENT_DIR="$(dirname "$PWD")"

docker run -it --rm --name my-running-script -v "$PARENT_DIR":/usr/src/myapp -w /usr/src/myapp apache/airflow:2.2.2 python $1