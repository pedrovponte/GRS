#!/bin/bash

# install docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# install docker-compose
sudo apt install -y docker-compose

# run nginx
sudo docker pull nginx
sudo docker run --name my-nginx -v /home/gors/html:/usr/share/nginx/html:ro -d nginx

# run browsertime
sudo docker pull sitespeedio/browsertime
sudo docker run --shm-size=1g --rm -v "$(pwd)":/browsertime sitespeedio/browsertime https://sitespeed.io/