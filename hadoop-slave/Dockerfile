FROM arindamchoudhury/hadoop-base:latest

MAINTAINER Arindam Choudhury <arindam@live.com>

WORKDIR /home/hdfs

COPY files/bootstrap.sh /etc/bootstrap.sh
RUN chmod +x /etc/bootstrap.sh

EXPOSE 22 7373 7946 9000 50010 50020 50070 50075 50090 50475 8030 8031 8032 8033 8040 8042 8060 8088 50060

COPY /config/service.json /usr/local/consul/config/service.json

CMD ["/etc/bootstrap.sh", "-d"]
