#!/usr/bin/env bash

source /etc/profile

nohup /usr/local/consul/bin/consul agent  -server -config-dir /usr/local/consul/config --domain=$CONSUL_DOMAIN_NAME  -client=0.0.0.0 -data-dir=/usr/local/consul/data -bootstrap >>/var/log/consul.log 2>&1 &

sleep 5

#core-site.xml
curl -X PUT -d $IO_FILE_BUFFER_SIZE http://localhost:8500/v1/kv/IO_FILE_BUFFER_SIZE
curl -X PUT -d $DFS_BLOCKSIZE http://localhost:8500/v1/kv/DFS_BLOCKSIZE
curl -X PUT -d $DFS_NAMENODE_HANDLER_COUNT http://localhost:8500/v1/kv/DFS_NAMENODE_HANDLER_COUNT

#hdfs-site.xml
curl -X PUT -d $DFS_REPLICATION http://localhost:8500/v1/kv/DFS_REPLICATION
curl -X PUT -d $DFS_NAMEDIR http://localhost:8500/v1/kv/DFS_NAMEDIR
curl -X PUT -d $FS_CHECKPOINT_DIR http://localhost:8500/v1/kv/FS_CHECKPOINT_DIR
curl -X PUT -d $DFS_DATANODE_DATA_DIR http://localhost:8500/v1/kv/DFS_DATANODE_DATA_DIR


#hadoop-env
curl -X PUT -d $JAVA_HOME http://localhost:8500/v1/kv/JAVA_HOME
curl -X PUT -d $HADOOP_CONF_DIR http://localhost:8500/v1/kv/HADOOP_CONF_DIR
curl -X PUT -d $LOG_DIR http://localhost:8500/v1/kv/LOG_DIR
curl -X PUT -d $HADOOP_HEAPSIZE http://localhost:8500/v1/kv/HADOOP_HEAPSIZE
curl -X PUT -d $HADOOP_NAMENODE_INIT_HEAPSIZE http://localhost:8500/v1/kv/HADOOP_NAMENODE_INIT_HEAPSIZE

#yarn-env
curl -X PUT -d $YARN_HEAPSIZE http://localhost:8500/v1/kv/YARN_HEAPSIZE
curl -X PUT -d $YARN_RESOURCEMANAGER_HEAPSIZE http://localhost:8500/v1/kv/YARN_RESOURCEMANAGER_HEAPSIZE
curl -X PUT -d $YARN_NODEMANAGER_HEAPSIZE http://localhost:8500/v1/kv/YARN_NODEMANAGER_HEAPSIZE

#mapred-env
curl -X PUT -d $HADOOP_JOB_HISTORYSERVER_HEAPSIZE http://localhost:8500/v1/kv/HADOOP_JOB_HISTORYSERVER_HEAPSIZE

#hive-env
curl -X PUT -d $ http://localhost:8500/v1/kv/
curl -X PUT -d $HIVE_CONF_DIR http://localhost:8500/v1/kv/HIVE_CONF_DIR

#curl -X PUT -d $ http://localhost:8500/v1/kv/

curl -X PUT -d 'done' http://localhost:8500/v1/kv/hadoop/hadoopconfiguration

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
