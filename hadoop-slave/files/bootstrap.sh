#!/usr/bin/env bash

source /etc/profile

#service ssh start

service ntp start

nohup /usr/local/consul/bin/consul agent -config-dir /usr/local/consul/config --domain=$CONSUL_DOMAIN_NAME -join $CONSUL_SERVER_ADDR >>/var/log/consul.log 2>&1 &

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8500/v1/kv/hadoop/namenode)
  if [ $STATUS -eq 200 ]; then
    break
  fi
  sleep 3
done

DFS_DATANODE_DATA_DIR=$(curl -s http://localhost:8500/v1/kv/DFS_DATANODE_DATA_DIR?raw)
HADOOP_CONF_DIR=$(curl -s http://localhost:8500/v1/kv/HADOOP_CONF_DIR?raw)


#make data dir
DATADIRS=$(echo $DFS_DATANODE_DATA_DIR | tr "," "\n")

for DIR in $DATADIRS
do
  mkdir -p $DIR
  chown -R hdfs:hadoop $DIR
done

#create log dirs
LOG_DIR=$(curl -s http://localhost:8500/v1/kv/LOG_DIR?raw)

mkdir -p $LOG_DIR
chgrp -R hadoop $LOG_DIR
chmod -R g+rwxs $LOG_DIR

consul-template -template "/tmp/core-site.xml.ctmpl:$HADOOP_CONF_DIR/core-site.xml" -once
consul-template -template "/tmp/hdfs-site.xml.ctmpl:$HADOOP_CONF_DIR/hdfs-site.xml" -once
consul-template -template "/tmp/mapred-site.xml.ctmpl:$HADOOP_CONF_DIR/mapred-site.xml" -once
consul-template -template "/tmp/yarn-site.xml.ctmpl:$HADOOP_CONF_DIR/yarn-site.xml" -once

consul-template -template "/tmp/hadoop-env.sh.ctmpl:$HADOOP_CONF_DIR/hadoop-env.sh" -once
consul-template -template "/tmp/yarn-env.sh.ctmpl:$HADOOP_CONF_DIR/yarn-env.sh" -once
consul-template -template "/tmp/mapred-env.sh.ctmpl:$HADOOP_CONF_DIR/mapred-env.sh" -once

python /etc/memory_config.py

chown -R hdfs:hadoop $HADOOP_CONF_DIR
chmod -R 755 $HADOOP_CONF_DIR

chgrp -R hadoop $HADOOP_PREFIX
chmod -R g+rwxs $HADOOP_PREFIX

sudo -E -u hdfs /usr/local/hadoop-2.7.2/sbin/hadoop-daemon.sh start datanode

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8500/v1/kv/hadoop/resourcemanager)
  if [ $STATUS -eq 200 ]; then
    break
  fi
  sleep 3
done

sudo -E -u yarn /usr/local/hadoop-2.7.2/sbin/yarn-daemon.sh start nodemanager

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
