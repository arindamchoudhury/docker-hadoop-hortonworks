
build:
    make -C centos-systemd
	make -C consul
	make -C consul-agent
	make -C consul-server
	make -C hadoop-base
	make -C hadoop-master
	make -C hadoop-slave