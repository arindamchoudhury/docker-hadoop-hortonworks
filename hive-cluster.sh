#!/usr/bin/env bash
# run N slave containers
N=$1
DOMAIN=${2:-'hadoop-cluster.local'}
DNS_SEARCH="node.dc1.$DOMAIN"


# the defaut node number is 3
if [ $# = 0 ]
then
	N=3
fi

docker rm -f consul-server &> /dev/null
echo "start consul-server container..."
docker run -e CONSUL_DOMAIN_NAME=$DOMAIN --name=consul-server -d -h server --dns-search $DNS_SEARCH --dns 127.0.0.1 --env-file hadoop-configurations.list arindamchoudhury/consul-server &> /dev/null

SERVER_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" consul-server)

# delete old master container and start new master container
docker rm -f master &> /dev/null
echo "start master container..."
docker run -e CONSUL_DOMAIN_NAME=$DOMAIN -e CONSUL_SERVER_ADDR=$SERVER_IP -d -h master --name=master --dns-search $DNS_SEARCH --dns 127.0.0.1 arindamchoudhury/hadoop-hive &> /dev/null

# get the IP address of master container
# delete old slave containers and start new slave containers
i=1
N=$((N+1))
while [ $i -lt $N ]
do
	docker rm -f slave$i &> /dev/null
	echo "start slave$i container..."
	docker run -e CONSUL_DOMAIN_NAME=$DOMAIN -e CONSUL_SERVER_ADDR=$SERVER_IP -d -h slave$i --name=slave$i --dns-search $DNS_SEARCH --dns 127.0.0.1 arindamchoudhury/hadoop-slave  &> /dev/null
	((i++))
done


# create a new Bash session in the master container

echo "please wait till your hadoop cluster is getting configured..."

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://$SERVER_IP:8500/v1/kv/hadoop/finished)
  if [ $STATUS -eq 200 ]; then
    break
  fi
  sleep 3
done

docker exec -it -u hdfs master bash
