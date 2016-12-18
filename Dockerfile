FROM centos:latest
MAINTAINER Ed Sealing <ed.sealing@sealingtech.org>

RUN yum -y update && \
	yum -y install cmake make gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig zlib-devel GeoIP-devel libpcap gperftools vim-minimal wget kernel-headers kernel-devel && \
	wget https://www.bro.org/downloads/bro-2.5.tar.gz && \
	tar xzf bro-2.5.tar.gz && \
	cd bro-2.5 && \
	./configure && \
	make install && \
	cd / && \
	wget https://github.com/bro/bro-plugins/archive/release.tar.gz && \
	tar xzf release.tar.gz && \
	cd bro-plugins-release/af_packet && \
	./configure --bro-dist=../../bro-2.5 &&\
	make && \
	make install &&\
	yum -y erase libpcap-devel openssl-devel python-devel zlib-devel GeoIP-devel wget kernel-devel libstdc++-devel gperftools-devel glibc-devel && \
	rm -rf /{release,bro-2.5}.tar.gz && \
	rm -rf /{bro-2.5,bro-plugins-release} && \
	yum -y clean all

