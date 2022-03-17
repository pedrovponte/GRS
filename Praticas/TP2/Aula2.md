## Resumo configuração das máquinas aula2

### Reconfigruação das máquinas da aula passada
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

### Configurar a net na vmb
- Uso dos seguintes comandos para verificar se existe acesso á internet
    - `ping google.com`
    - ip route
- Configuração da vmb 
    - Comandos na vma:
        - `sysctl -w net.ipv4.ip_forward=1`
        - `iptables -t nat -A POSTROUTING -s 192.168.88.101 -o eth0 -j MASQUERADE`
        - `sudo iptables -A FORWARD -i eth0 -j ACCEPT`
        - `sudo iptables -A FORWARD -i eth1 -j ACCEPT`
    - Comandos na vmb
        - `ip r a default via 192.168.88.100`

### Criação de containers na vmb

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





 

