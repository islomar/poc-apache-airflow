#!/usr/bin/env sh


docker-compose down --volumes --remove-orphans
rm -rf ./dags/* ./logs/* ./plugins/*