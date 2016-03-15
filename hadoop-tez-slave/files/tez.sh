#!/usr/bin/env bash

TEZ_JARS=/usr/local/tez-0.8.2-minimal
TEZ_CONF_DIR=/usr/local/hadoop-2.7.2/etc/hadoop/
export TEZ_JARS TEZ_CONF_DIR
export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*
