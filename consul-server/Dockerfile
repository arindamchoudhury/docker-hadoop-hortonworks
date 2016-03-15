FROM arindamchoudhury/consul

MAINTAINER Arindam Choudhury <arindam@live.com>

COPY config/server.json /usr/local/consul/config/server.json

COPY files/bootstrap.sh /etc/bootstrap.sh
RUN chmod +x /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]