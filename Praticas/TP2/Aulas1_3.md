# Resumo configuração das máquinas aula2

## Reconfigruação das máquinas da aula passada

- Criar a pasta `~/.ssh`
- cd `~/.ssh`
- Criar o ficheiro config
- Configurar o ficheiro config

```
Host vma
    HostName 192.168.109.158
    IdentityFile g.rsa
    IdentitiesOnly yes
    User theuser

Host vmb
    HostName 192.168.88.101
    IdentityFile gors-2122-2s-target.rsa
    IdentitiesOnly yes
    User theuser
    ProxyCommand ssh vma nc %h %p

Host vmc
    HostName 192.168.88.102
    IdentityFile gors-2122-2s-target.rsa
    IdentitiesOnly yes
    User theuser
    ProxyCommand ssh vma nc %h %p
```

- Copiar as chaves para a pasta `~/.ssh`
- `chmod 700` ás chaves privadas
- Usar comando `ssh` para aceder ás VM
    - `ssh vma` - Máquina host inicial para configuração
    - `ssh vmb` - Máquina cliente na qual vamos instalar containers
    - `ssh vmc`

- Remover fingerprint: ssh -keygen -f "/home/pedrovponte/.ssh/known_hosts" -R "192.168.88.101"

## Configurar a net na vmb
- Uso dos seguintes comandos para verificar se existe acesso á internet
    - `ping google.com`
    - ip route
- Configuração da vmb 
    - Comandos na vma:
        - `sudo sysctl -w net.ipv4.ip_forward=1`
        - `sudo iptables -t nat -A POSTROUTING -s 192.168.88.101 -o eth0 -j MASQUERADE`
        - `sudo iptables -A FORWARD -i eth0 -j ACCEPT`
        - `sudo iptables -A FORWARD -i eth1 -j ACCEPT`
    - Comandos na vmb
        - `sudo ip route del default`
        - `ip r a default via 192.168.88.100`

## Criação de containers na vmb

- Instalar docker e docker-compose se não estiver instalado
- Geração de um container
    - `sudo docker network create -d macvlan --subnet=10.10.10.0/24 -o parent=eth0 pub_net`
- Correr um container
    - `docker run --net pub_net --ip 10.10.10.3 ...` (substituir ... pelo container a correr no futuro)

- Instalar *nginx* • https://hub.docker.com/_/nginx
    - `sudo docker run --name some-nginx -v /some/content:/usr/share/nginx/html:ro -d nginx`
- Instalar *brosertime* • https://hub.docker.com/r/sitespeedio/browsertime/
    - `sudo docker run --rm -v "$(pwd)":/browsertime sitespeedio/browsertime:15.3.0 --video --visualMetrics https://www.sitespeed.io/` (o segundo funcionou melhor)
    - `sudo docker run --rm -v "$(pwd):/sitespeed.io" sitespeedio/sitespeed.io:23.5.0 https://www.sitespeed.io/` 
    - Estes restantes não percebi se eram necessários ou não:
        - Ver neste site os comandos NPM - https://www.sitespeed.io/

- Agora é suposto criar um dockerfile para facilitar o inicio dos containers
- Meter flags como -t ou -tty ou até correr um comando para criar uma consola bash para que os containers não fechem após abrir

## Aula 3

- Create netubuntu container (os slides 13 e 14 estão na ordem errada lol)

- Fazer o turorial do slide 14, criar os 2 ficheiros no path baseimage e dar build á imagem
    - Não esquecer de fazer chmod ao sleep

- Setup
    - vmb
        - remover containers anteriores
            - `sudo docker rm -f client server router`
            - `sudo docker network rm client_net server_net`
        - Adicionar 2 redes no ProxMox
            - `sudo ip l set ens19 up`
            - `sudo ip l set ens20 up`
            - `ip a` (Para verificar se as portas foram adicionadas)
        
- Networks
    - `sudo docker network create -d macvlan --subnet=10.0.1.0/24 --gateway=10.0.1.1 -o parent=ens19 client_net`
    - `sudo docker network create -d macvlan --subnet=10.0.2.0/24 --gateway=10.0.2.1 -o parent=ens20 server_net`

- Client and Server
    - `sudo docker run -d --net client_net --ip 10.0.1.100 --cap-add=NET_ADMIN --name client netubuntu`
    - `sudo docker run -d --net server_net --ip 10.0.2.100 --cap-add=NET_ADMIN --name server netubuntu`

- Router
    - `sudo docker run -d --net client_net --ip 10.0.1.254 --cap-add=NET_ADMIN --name router netubuntu`
    - `sudo docker network connect server_net router --ip 10.0.2.254`

- Routing on client and server
    - `sudo docker exec client /bin/bash -c 'ip r del default via 10.0.1.1'`
    - `sudo docker exec client /bin/bash -c 'ip r a 10.0.2.0/24 via 10.0.1.254'`
    - `sudo docker exec server /bin/bash -c 'ip r del default via 10.0.2.1'`
    - `sudo docker exec server /bin/bash -c 'ip r a 10.0.1.0/24 via 10.0.2.254'`

- Test
    - `docker exec -it client ping 10.0.2.100`


## Todo (load balancing)

- Criar mais servidores em diferentes ips 
    - Ex: 10.0.1.101 e 10.0.1.102 (seguindo os passos anteriores)

- Fazer o turorial de [NGINX](https://towardsdatascience.com/sample-load-balancing-solution-with-docker-and-nginx-cf1ffc60e644)
    - Seguir os passos finais (só depois dos requirements)