#!/bin/bash

# remover containers anteriores
sudo docker rm -f client server router
sudo docker network rm client_net server_net

# adicionar 2 redes no Proxmox
sudo ip l set ens19 up
sudo ip l set ens20 up

# Networks
sudo docker network create -d macvlan --subnet=10.0.1.0/24 --gateway=10.0.1.1 -o parent=ens19 client_net
sudo docker network create -d macvlan --subnet=10.0.2.0/24 --gateway=10.0.2.1 -o parent=ens20 server_net

# Client and server
sudo docker run -d --net client_net --ip 10.0.1.100 --cap-add=NET_ADMIN --name client netubuntu
sudo docker run -d --net server_net --ip 10.0.2.100 --cap-add=NET_ADMIN --name server netubuntu

# Router
sudo docker run -d --net client_net --ip 10.0.1.254 --cap-add=NET_ADMIN --name router netubuntu
sudo docker network connect server_net router --ip 10.0.2.254

# Routing on client and server
sudo docker exec client /bin/bash -c 'ip r del default via 10.0.1.1'
sudo docker exec client /bin/bash -c 'ip r a 10.0.2.0/24 via 10.0.1.254'
sudo docker exec server /bin/bash -c 'ip r del default via 10.0.2.1'
sudo docker exec server /bin/bash -c 'ip r a 10.0.1.0/24 via 10.0.2.254'