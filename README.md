# htpc

# Post Install

    $ sudo raspi-config #change hostname, user password, memory split to 16mb cause no gui and update, SSH is already allowed
    $ sudo passwd root #set the root password
    $ sudo nano /etc/ssh/sshd_config #change ssh port/listen adress
    $ sudo adduser <user>
    $ sudo visudo

    <user>  ALL=(ALL:ALL) ALL

    $ sudo apt update && sudo apt upgrade -y #update, upgrade
    $ sudo exit #login to the new user

    $ sudo deluser -remove-home pirate # pirate is the default user on hypriot
    $ sudo usermod -a -G docker $USER
    $ sudo reboot #need reboot after add <user> to docker group

# GlusterFS

## Disk Format

    $ sudo blkid -o list
    $ sudo fdisk /dev/sda
   
    d : delete all partitions
    n : create new partition
    w : make change and exit
    
    $ sudo mkfs.ext4 /dev/sda1
    
## Mount

    $ sudo mkdir -p /data/brick1
    $ sudo mount -t ext4 -o defaults /dev/sda1 /data/brick1
    
Auto-mount at each boot :

    $ sudo blkid -o list # => UUID : ...
    $ sudo nano /etc/fstab
    
    UUID=... /data/brick1 ext4 defaults 0

Set the permissions :

    $ sudo chown $USER:$USER -R /data/brick1

Safely eject disks and reboot to test :

    $ sudo apt-get install udisks -y
    $ sudo udisks --unmount /dev/sda1
    $ sudo umount -l /data/brick1 ## if the disk is busy
    $ sudo udisks --detach /dev/sda

## GlusterFS

    node05$ sudo apt install glusterfs-server -y
    node06$ sudo apt install glusterfs-server -y

    node05$ sudo nano /etc/hosts ## On Hypriot the file to modifie is in /etc/cloud/templates
    
    127.0.1.1       node05.storage node05
    192.168.0.215   node06.storage node06

    node06$ sudo nano /etc/hosts
    
    127.0.1.1       node06.storage node06
    192.168.0.214   node05.storage node05

    node05$ sudo gluster peer probe node06
    node06$ sudo gluster peer probe node05
    
    node05$ sudo gluster peer status # => State: Peer in Cluster (Connected)
    node06$ sudo gluster peer status # => State: Peer in Cluster (Connected)

    node05$ mkdir /data/brick1/gv0
    node06$ mkdir /data/brick1/gv0

    node05$ sudo gluster volume create gv0 replica 2 node05:/data/brick1/gv0 node06:/data/brick1/gv0
    node05$ sudo gluster volume start gv0 # start/stop/status/delete
    node05$ sudo gluster volume info # => Status : started

    node05$ sudo gluster volume set gv0 auth.allow 192.168.0.210,192.168.0.211,192.168.0.212,192.168.0.213,192.168.0.214,192.168.0.215

Some tests on the Gluster Hosts :

    node05$ sudo mount -t glusterfs node05:/gv0 /mnt
    node05$ sudo su
    node05# echo "Hello World" > /mnt/hello.txt && exit
    node06$ sudo mount -t glusterfs node06:/gv0 /mnt
    node06$ cat /mnt/hello.txt # => Hello World
    
Automount volumes on boot on the Gluster hosts :

    node05+06$ sudo nano /etc/fstab

    localhost:/gv0 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0

If the disk is not mounting on restart try this line instead in fstab :

    localhost:/gv0 /mnt glusterfs defaults,_netdev,noauto,x-systemd.automount,backupvolfile-server=localhost 0 0

Now to setup each Client :

    node0x$ sudo apt-get install glusterfs-client -y
    node0x$ sudo nano /etc/hosts
    
    192.168.0.214  node05.storage node05
    192.168.0.215  node06.storage node06
    
    node0x$ sudo nano /etc/fstab
    
    node05:/gv0 /mnt glusterfs defaults,_netdev,backupvolfile-server=node06 0 0
 
If the disk is not mounted on the client on reboot try this line instead :

    node05:/gv0 /mnt glusterfs defaults,_netdev,noauto,x-systemd.automount,backupvolfile-server=node06 0 0

Some tests Client+Server :
 
    node05$ sudo udisks --unmount /dev/sda1
    node05$ sudo umount -l /data/brick1 ## if the disk is busy
    node05$ sudo udisks --detach /dev/sda
    node01$ cd /mnt
    node01$ sudo mkdir hello
    node02$ cd /mnt && ls # => hello
    node06$ cd /data/brick1/gv0 && ls => hello
    node05$ sudo reboot
    node05$ cd /data/brick1/gv0 && ls => hello

Here it's like the first disk, actually mounted on all node, was disconnected, we see that we can continue to read/write on the /mnt dir and it's the same for all the rest of the servers. When the disk is reconnected, all the data are restored. To cleanly stop the service before umount the disk :

    $ sudo service glusterfs-server stop

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

