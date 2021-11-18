#!/usr/bin/env sh

# If enough memory is not allocated, it might lead to airflow webserver continuously restarting.
# You should at least allocate 4GB memory for the Docker Engine (ideally 8GB)
docker run --rm "debian:buster-slim" bash -c 'numfmt --to iec $(echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE))))'