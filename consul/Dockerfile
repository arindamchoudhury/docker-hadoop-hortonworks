FROM arindamchoudhury/centos-systemd:latest

MAINTAINER Arindam Choudhury <arindam@live.com>

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp


RUN yum update -y && \
yum install -y unzip wget curl vim


# Download and extract consul
#RUN wget -c -O "consul_0.6.3_linux_amd64.zip" "https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip" && \
COPY tars/consul_0.6.3_linux_amd64.zip /tmp/consul_0.6.3_linux_amd64.zip
RUN mkdir -p /usr/local/consul/bin && \
mkdir -p /usr/local/consul/logs && \
unzip /tmp/consul_0.6.3_linux_amd64.zip -d /usr/local/consul/bin && \
rm /tmp/consul_0.6.3_linux_amd64.zip

# Download and extract consul-template
#RUN wget -c -O "consul-template_0.13.0_linux_amd64.zip" "https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip" && \
COPY tars/consul-template_0.13.0_linux_amd64.zip /tmp/consul-template_0.13.0_linux_amd64.zip
RUN unzip /tmp/consul-template_0.13.0_linux_amd64.zip -d /usr/local/consul/bin && \
rm /tmp/consul-template_0.13.0_linux_amd64.zip

##Setup Consul environment
COPY files/consul.sh /etc/profile.d/consul.sh





