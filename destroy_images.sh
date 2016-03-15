#!/usr/bin/env bash

docker rmi arindamchoudhury/hadoop-master arindamchoudhury/hadoop-slave arindamchoudhury/hadoop-base
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

docker images

