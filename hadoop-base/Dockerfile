FROM arindamchoudhury/consul-agent:latest

MAINTAINER Arindam Choudhury <arindam@live.com>

# configure hortonworks repo
wget -nv http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.4.0.0/hdp.repo -O /etc/yum.repos.d/hdp.repo

# install required packages
RUN yum update -y && \
yum install -y ntp hadoop hadoop-hdfs hadoop-libhdfs hadoop-yarn hadoop-mapreduce hadoop-client openssl snappy snappy-devel lzo lzo-devel hadooplzo hadooplzo-native
#openssh-server

COPY tars/jdk-7u80-linux-x64.tar.gz /tmp/jdk-7u80-linux-x64.tar.gz

RUN yum remove java-1.8.0-openjdk-headless-1.8.0.71-2.b15.el7_2.x86_64 -y
#Download jdk-7u79 and extract to /usr/local/
#RUN wget -c -O "jdk-7u80-linux-x64.tar.gz" --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz" && \
RUN tar zxf /tmp/jdk-7u80-linux-x64.tar.gz -C /usr/local/ && \
rm /tmp/jdk-7u80-linux-x64.tar.gz
#Setup Java environment
COPY files/java.sh /etc/profile.d/java.sh

# Setup hadoop environment
COPY files/hadoop.sh /etc/profile.d/hadoop.sh

# move all configuration files into container
#COPY files/ssh_config ~/.ssh/config/ssh_config

#configure ssh free key access
#RUN mkdir /var/run/sshd && \
#ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
#cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
#sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#create users and groups
RUN groupadd hadoop && \
useradd -g hadoop -m -s /bin/bash yarn && \
useradd -g hadoop -m -s /bin/bash hdfs && \
useradd -g hadoop -m -s /bin/bash mapred && \
useradd -g hadoop -m -s /bin/bash hive

COPY files/hdfs-site.xml.ctmpl /tmp/hdfs-site.xml.ctmpl
COPY files/core-site.xml.ctmpl /tmp/core-site.xml.ctmpl
COPY files/mapred-site.xml.ctmpl /tmp/mapred-site.xml.ctmpl
COPY files/yarn-site.xml.ctmpl /tmp/yarn-site.xml.ctmpl

COPY files/hadoop-env.sh.ctmpl /tmp/hadoop-env.sh.ctmpl
COPY files/yarn-env.sh.ctmpl /tmp/yarn-env.sh.ctmpl
COPY files/mapred-env.sh.ctmpl /tmp/mapred-env.sh.ctmpl

COPY files/memory_config.py /etc/memory_config.py
RUN chmod +x /etc/memory_config.py