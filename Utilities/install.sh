#!/usr/bin/env bash
root_dir="/home/odroid"
skimage_docker_image="nickstelzenmuller/skimage:ARM_prod"

echo "Attempting to remove ${root_dir}/skimage_edge_deployment"
cd 
sudo rm -rf ${root_dir}/skimage_edge_deployment

# clone Github repo
git clone https://github.com/nstelzen/skimage_edge_deployment.git

# Allow watchdog.sh to be executable 
chmod +x ${root_dir}/skimage_edge_deployment/skimage.sh

# Set time zone
sudo timedatectl set-timezone Europe/Paris

# Install docker
sudo apt-get -y remove docker docker-engine docker.io containerd runc

sudo apt-get -y update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=armhf] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get -y update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io

sudo groupadd docker

sudo usermod -aG docker $USER



# Remove all docker images
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images)

# Pull Docker image
docker pull ${skimage_docker_image}

# Install docker-compose
sudo apt-get -y install docker-compose

# Install inotify-tools (Necessary for monitoring of semaphore file by watchdog)
sudo apt-get -y install inotify-tools

# Set up link to skimage logs folder
mkdir -p /home/odroid/skimage_edge_deployment/Logs_SKIMAGE 
sudo ln -s /home/odroid/skimage_edge_deployment/Logs_SKIMAGE /home/odroid/Logs_SKIMAGE

# Copy skimage_watchdog.service to /lib/systemd/system
sudo cp /home/odroid/skimage_edge_deployment/Utilities/skimage_watchdog.service /lib/systemd/system

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable skimage_watchdog.service

# Reboot
sudo reboot