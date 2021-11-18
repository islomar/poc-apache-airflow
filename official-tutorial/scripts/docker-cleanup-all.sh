#!/usr/bin/env sh

# To stop and delete containers, delete volumes with database data and download images
cd ..
docker-compose down --volumes --rmi all