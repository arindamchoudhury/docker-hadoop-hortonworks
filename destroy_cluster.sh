#!/usr/bin/env bash

docker rm -f consul-server master slave1 slave2 slave3

docker ps -a
