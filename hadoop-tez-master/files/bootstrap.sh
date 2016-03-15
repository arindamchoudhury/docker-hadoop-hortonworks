#!/usr/bin/env bash

source /etc/profile

python /etc/memory_config.py

chgrp -R hadoop $HADOOP_PREFIX
chmod -R g+rwxs $HADOOP_PREFIX

#service ssh start

service ntp start

nohup /usr/local/consul/bin/consul agent -config-dir /usr/local/consul/config --domain=$CONSUL_DOMAIN_NAME -join $CONSUL_SERVER_ADDR >>/var/log/consul.log 2>&1 &

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs namenode -format

sudo -E -u hdfs /usr/local/hadoop-2.7.2/sbin/hadoop-daemon.sh start namenode

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /user/hdfs
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown hdfs:hadoop /user/hdfs

sudo -E -u yarn /usr/local/hadoop-2.7.2/sbin/yarn-daemon.sh start resourcemanager

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /mr-history/tmp
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 1777 /mr-history/tmp

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /mr-history/done
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 1777 /mr-history/done
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown -R mapred:hdfs /mr-history

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /app-logs
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 1777 /app-logs

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown yarn:hdfs /app-logs

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /tmp/hadoop-yarn
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown yarn:hadoop /tmp/hadoop-yarn

sudo -E -u yarn /usr/local/hadoop-2.7.2/sbin/mr-jobhistory-daemon.sh start historyserver

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /apps/tez-0.8.2
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -put /tmp/tez-0.8.2.tar.gz /apps/tez-0.8.2
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown -R hdfs:hadoop /hdp
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 555 /apps/tez-0.8.2
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 444 /apps/tez-0.8.2/tez-0.8.2.tar.gz

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
