# clone Github repo
git clone https://github.com/nstelzen/skimage_edge_deployment.git

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



# Set up link to skimage logs folder
sudo ln -s /home/odroid/skimage_edge_deployment/Logs_SKIMAGE /home/odroid/Logs_SKIMAGE