#!/usr/bin/env bash

# Add docker to authorized xhost list
xhost +local:docker

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# Set access to GUI
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Start docker container and run skimage
docker run \
    --net=host \
    --ipc=host \
    -it \
    -e DISPLAY=$DISPLAY \
    -e "TZ=Asia/Kolkata" \
    -v $XSOCK:$XSOCK \
    -v $XAUTH:$XAUTH \
    -e XAUTHORITY=$XAUTH \
    -v /home/odroid/skimage_edge_deployment:/home \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --rm \
    --workdir /home \
    nickstelzenmuller/skimage:ARM_prod \
    bash

xhost -local:docker

