#!/usr/bin/env bash

source /etc/profile

#service ssh start
#sed -i '/^#export HADOOP_HEAPSIZE=/ s:.*:export HADOOP_HEAPSIZE==500:' /usr/local/hadoop-2.7.2/etc/hadoop/hadoop-env.sh
#sed -i '/^export HADOOP_JOB_HISTORYSERVER_HEAPSIZE/ s:.*:export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=500:' /usr/local/hadoop-2.7.2/etc/hadoop/mapred-env.sh

service ntp start

nohup /usr/local/consul/bin/consul agent -config-dir /usr/local/consul/config --domain=$CONSUL_DOMAIN_NAME -join $CONSUL_SERVER_ADDR >>/var/log/consul.log 2>&1 &

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8500/v1/kv/hadoop/hadoopconfiguration)
  if [ $STATUS -eq 200 ]; then
    break
  fi
  sleep 3
done

curl -X PUT -d $HOSTNAME http://localhost:8500/v1/kv/NAMENODE_ADDR
curl -X PUT -d $HOSTNAME http://localhost:8500/v1/kv/JOBHISTORY_ADDR
curl -X PUT -d $HOSTNAME http://localhost:8500/v1/kv/YARN_RESOURCEMANGER_HOSTNAME

DFS_NAMEDIR=$(curl -s http://localhost:8500/v1/kv/DFS_NAMEDIR?raw)
FS_CHECKPOINT_DIR=$(curl -s http://localhost:8500/v1/kv/FS_CHECKPOINT_DIR?raw)
FS_CHECKPOINT_EDITS_DIR=$(curl -s http://localhost:8500/v1/kv/FS_CHECKPOINT_EDITS_DIR?raw)

HADOOP_CONF_DIR=$(curl -s http://localhost:8500/v1/kv/HADOOP_CONF_DIR?raw)
#export =$(curl -s http://localhost:8500/v1/kv/?raw)

#make name dir
NAMEDIRS=$(echo $DFS_NAMEDIR | tr "," "\n")

for DIR in $NAMEDIRS
do
  mkdir -p $DIR
  chown -R hdfs:hadoop $DIR
done

#make checkpoints dir
CHECKPOINTDIRS=$(echo $FS_CHECKPOINT_DIR | tr "," "\n")

for DIR in $CHECKPOINTDIRS
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

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs namenode -format

curl -X PUT -d 'formatted' http://localhost:8500/v1/kv/hadoop/namenodeformat

sudo -E -u hdfs /usr/local/hadoop-2.7.2/sbin/hadoop-daemon.sh start namenode
sudo -E -u hdfs /usr/local/hadoop-2.7.2/sbin/hadoop-daemon.sh start secondarynamenode

curl -X PUT -d 'started' http://localhost:8500/v1/kv/hadoop/namenode

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /user/hdfs
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown hdfs:hadoop /user/hdfs

sudo -E -u yarn /usr/local/hadoop-2.7.2/sbin/yarn-daemon.sh start resourcemanager
curl -X PUT -d 'started' http://localhost:8500/v1/kv/hadoop/resourcemanager

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /mr-history/tmp
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 1777 /mr-history/tmp

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /mr-history/done
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 1777 /mr-history/done
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown -R yarn:hdfs /mr-history

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /app-logs
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chmod -R 1777 /app-logs

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown yarn:hdfs /app-logs

sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -mkdir -p /tmp/hadoop-yarn
sudo -E -u hdfs /usr/local/hadoop-2.7.2/bin/hdfs dfs -chown yarn:hadoop /tmp/hadoop-yarn

sudo -E -u yarn /usr/local/hadoop-2.7.2/sbin/mr-jobhistory-daemon.sh start historyserver

curl -X PUT -d 'started' http://localhost:8500/v1/kv/hadoop/historyserver

curl -X PUT -d 'started' http://localhost:8500/v1/kv/hadoop/finished


if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
