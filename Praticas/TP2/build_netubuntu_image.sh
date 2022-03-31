#!/bin/bash

mkdir baseimage
cd baseimage
touch Dockerfile
echo 'FROM ubuntu:20.04' >> Dockerfile
echo 'RUN apt update && apt install -y vim iproute2 iputils-ping tcpdump iptables dnsutils curl' >> Dockerfile
echo 'COPY sleep.sh /root/sleep.sh' >> Dockerfile
echo 'CMD /root/sleep.sh' >> Dockerfile

touch sleep.sh
echo '#!/bin/bash' >> sleep.sh
echo 'while true ; do /bin/sleep 5m; done' >> sleep.sh

chmod 777 sleep.sh

sudo docker build --tag netubuntu:latest ~/baseimage
cd ..
