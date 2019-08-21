#!/bin/bash

# docker-compose start_watchdog
echo "hello"
# Setup functions to monitor semphore directory and run skimage
function monitor_semaphore {
  inotifywait \
        -e modify,create \
        ${semaphore_dir}
}

# run skimage, then restart skimage if there are any changes to the semaphore file
xhost +local:root
docker-compose \
    -f /home/odroid/skimage_edge_deployment/Utilities/docker-compose.yml \
    run --rm prod_ARM python python_src/skimage_edge.py

# Start monitoring the semphore file
semaphore_dir="/home/odroid/skimage_edge_deployment/data/semaphore"
mkdir -p ${semaphore_dir}
echo "Monitoring semaphore file $semaphore_dir"

while monitor_semaphore
do
    echo "Semaphore received, restarting Skimage container"
    # docker-compose start_skimage
done

