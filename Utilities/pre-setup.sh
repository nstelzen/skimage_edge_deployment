# clone Github repo
git clone https://github.com/nstelzen/skimage_edge_deployment.git

# Allow watchdog.sh to be executable 
chmod +x /home/odroid/skimage_edge_deployment/skimage.sh

# Set time zone
sudo timedatectl set-timezone Europe/Paris

# Install docker
sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update

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

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo groupadd docker

sudo usermod -aG docker $USER

newgrp docker 

# Pull Docker image

# Install docker-compose
sudo apt install docker-compose

# Install inotify-tools
sudo apt install inotify-tools

# Set up link to skimage logs folder
mkdir -p /home/odroid/skimage_edge_deployment/Logs_SKIMAGE 
sudo ln -s /home/odroid/skimage_edge_deployment/Logs_SKIMAGE /home/odroid/Logs_SKIMAGE

# Copy skimage_watchdog.service to /lib/systemd/system
sudo cp /home/odroid/skimage_edge_deployment/Utilities/skimage_watchdog.service /lib/systemd/system

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable skimage_watchdog.service
sudo systemctl start skimage_watchdog.service


# Reboot
sudo reboot