FROM arindamchoudhury/hadoop-slave:latest

MAINTAINER Arindam Choudhury <arindam@live.com>

WORKDIR /home/hdfs

COPY files/bootstrap.sh /etc/bootstrap.sh
RUN chmod +x /etc/bootstrap.sh

COPY files/tez-0.8.2-minimal.tar.gz /tmp/tez-0.8.2-minimal.tar.gz

RUN mkdir -p /usr/local/tez-0.8.2-minimal && \
tar zxf /tmp/tez-0.8.2-minimal.tar.gz -C /usr/local/tez-0.8.2-minimal && \
rm /tmp/tez-0.8.2-minimal.tar.gz

COPY files/mapred-site.xml /usr/local/hadoop-2.7.2/etc/hadoop/mapred-site.xml
COPY files/tez-site.xml /usr/local/hadoop-2.7.2/etc/hadoop/tez-site.xml
COPY files/tez.sh /etc/profile.d/tez.sh

CMD ["/etc/bootstrap.sh", "-d"]
