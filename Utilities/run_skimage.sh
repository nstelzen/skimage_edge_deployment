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
    -e DISPLAY=$DISPLAY \
    -e TZ="Europe/Paris" \
    -v $XSOCK:$XSOCK \
    -v $XAUTH:$XAUTH \
    -e XAUTHORITY=$XAUTH \
    -v /home/odroid/skimage_edge_deployment:/home \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    --rm \
    nickstelzenmuller/skimage:ARM_prod \
    python3 \
    python_src/skimage_edge.py

xhost -local:docker

