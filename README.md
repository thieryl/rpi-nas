# re

# Post Install

https://gist.github.com/adann0/9eff3e831e514988579337dc11492570

# GlusterFS

https://gist.github.com/adann0/4aad4526145044aceb40d8caf26524d1

# Docker Swarm

On the master :

    $ docker swarm init 
    
We have in return a command to enter on the workers instances :
    
    $ docker swarm join --token SWMTKN-1-17fw99pvvhyf8og91i09ujgy3upzg0nnce3hav0ecjylr2anr3-c7xgby5qequwa0w679q9gx5it 192.168.0.210:2377

To verify, on the master :

    $ docker node ls
    
Set more masters :

    $ docker node promote <node_id>

Set a Network for the Project and linked Containers :

    $ docker network create -d overlay --attachable rev3
    
# Let's Encrypt

   https://github.com/adann0/docker-nginx-letsencrypt
   + LDAP Certificates
   + Samba

# Deploy

J'ai un problème en déployant Nextcloud, les fichiers ne sont pas générés sur GlusterFS dans /mnt/config/cloud. La solution : faire en premier lieu un docker-compose up -d sur le master pour générer le fichier de configuration dans le dossier /home/$USER/$project/mnt, docker-compose down, deplacer tout les fichier dans mnt dans /mnt et docker stack deploy.

    $ docker service create --name registry --publish published=5000,target=5000 registry:2

    $ docker-compose up -d
    $ docker-compose ps
    
    $ cd mnt/config/cloud && ls #wait for nextcloud config files...
    
    $ docker-compose down
    $ sudo mv mnt/* /mnt
    $ sed -i 's/.\/mnt/\/mnt/g' docker-compose.yml
    
    $ #docker-compose push

    $ docker stack deploy -c docker-compose.yml rev3tk
    $ docker stack services rev3tk

# Sources :

- GlusterFS :
  - https://medium.com/running-a-software-factory/setup-3-node-high-availability-cluster-with-glusterfs-and-docker-swarm-b4ff80c6b5c3
  - http://banoffeepiserver.com/glusterfs/set-up-glusterfs-on-two-nodes.html
  - https://docs.gluster.org/en/v3/Administrator%20Guide/Managing%20Volumes/
  - GlusterFS Fail to Mount on Boot with Fstab : https://serverfault.com/a/823582
  
- Let's Encrypt + Nginx + Docker + Swarm :
  - https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx
  - https://medium.com/@rhrn/setup-front-docker-machine-in-swarm-mode-with-letsencrypt-and-registry-890a4a1df090

- Scaling :
  - https://medium.com/brian-anstett-things-i-learned/high-availability-and-horizontal-scaling-with-docker-swarm-76e69845825e

- Enable Docker Experimental Features : https://github.com/docker/docker-ce/blob/master/components/cli/experimental/README.md

# Three

    /mnt/
    ├── config/
    │   ├── samba/
    │   ├── cloud/
    │   ├── nginx/
    │   ├── letsencrypt/
    │   └── .../
    ├── data/
    │   ├── portainer/
    │   ├── mysql/
    │   ├── openldap/
    │   │   ├── slapd/
    │   │   └── ldap/
    │   ├── media/
    │   │   ├── movie/
    │   │   └── music/
    │   └── cloud/
    └── www/
        ├── mediaserver.tk/
        │   ├── cloud/
        │   └── .../
        ├── radio.xyz/
        └── .../
        
 # Images Armv7
 
    https://github.com/adann0/samba-ldap-armv7
    https://github.com/adann0/mariadb-armv7
    https://github.com/adann0/openldap-armv7
    https://github.com/adann0/docker-images-armv7

