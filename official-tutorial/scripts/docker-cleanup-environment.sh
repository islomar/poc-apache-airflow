#!/usr/bin/env sh

cd ..
docker-compose down --volumes --remove-orphans
rm -rf ./dags/* ./logs/* ./plugins/*