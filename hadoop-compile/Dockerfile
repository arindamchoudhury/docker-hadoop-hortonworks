#@IgnoreInspection BashAddShebang
FROM ubuntu:14.04

MAINTAINER Arindam Choudhury <arindam@live.com>

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && \
apt-get -y install maven && \
apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev && \
apt-get -y install libprotobuf-dev protobuf-compiler && \
apt-get -y install snappy libsnappy-dev && \
apt-get -y install bzip2 libbz2-dev && \
apt-get -y install libjansson-dev && \
apt-get -y install fuse libfuse-dev && \
apt-get -y install wget

#Download findbugs
RUN wget -c -O "findbugs-3.0.1.tar.gz" "http://downloads.sourceforge.net/project/findbugs/findbugs/3.0.1/findbugs-3.0.1.tar.gz" && \
tar zxf findbugs-3.0.1.tar.gz -C /usr/local/ && \
rm findbugs-3.0.1.tar.gz
#Setup findbugs environment
RUN touch /etc/profile.d/findbugs.sh && \
echo '#!/bin/bash' >> /etc/profile.d/findbugs.sh && \
echo 'FINDBUGS_HOME=/usr/local/findbugs-3.0.1/' >> /etc/profile.d/findbugs.sh && \
chmod +x /etc/profile.d/findbugs.sh

#Download jdk-7u79 and extract to /usr/local/
RUN wget -c -O "jdk-7u80-linux-x64.tar.gz" --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz" && \
tar zxf jdk-7u80-linux-x64.tar.gz -C /usr/local/ && \
rm jdk-7u80-linux-x64.tar.gz
#Setup Java environment
RUN touch /etc/profile.d/java.sh && \
echo '#!/bin/bash' >> /etc/profile.d/java.sh && \
echo 'JAVA_HOME=/usr/local/jdk1.7.0_80/' >> /etc/profile.d/java.sh && \
echo 'PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh && \
echo 'export JAVA_HOME PATH' >> /etc/profile.d/java.sh && \
chmod +x /etc/profile.d/java.sh && \
source /etc/profile

ENV JAVA_HOME /usr/local/jdk1.7.0_80
ENV PATH $JAVA_HOME/bin:$PATH
ENV FINDBUGS_HOME /usr/local/findbugs-3.0.1

# Download hadoop-2.7.2-src and compile
RUN wget -c -O "hadoop-2.7.2-src.tar.gz" "http://apache.rediris.es/hadoop/common/hadoop-2.7.2/hadoop-2.7.2-src.tar.gz" && \
tar zxf hadoop-2.7.2-src.tar.gz -C /usr/local/ && \
cd /usr/local/hadoop-2.7.2-src && \
mvn package -Pdist,native,docs,src -DskipTests -Dtar -Drequire.snappy -Drequire.openssl