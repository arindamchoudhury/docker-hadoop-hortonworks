FROM arindamchoudhury/consul
COPY config/agent.json /usr/local/consul/config/agent.json
RUN source /etc/profile
#ENTRYPOINT ["/usr/local/consul/bin/consul", "agent", "-config-dir=/usr/local/consul/config"]