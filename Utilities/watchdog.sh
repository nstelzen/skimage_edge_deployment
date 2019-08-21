#!/usr/bin/env bash

# docker-compose start_watchdog

# Setup functions to monitor semphore directory and run skimage
function monitor_semaphore {
  inotifywait \
        -e modify,create \
        ${semaphore_dir}
}

# run skimage, then restart skimage if there are any changes to the semaphore file
# docker-compose start_skimage

# Start monitoring the semphore file
semaphore_dir="/home/odroid/skimage_edge_deployment/data/semaphore"
mkdir -p ${semaphore_dir}
echo "Monitoring semaphore file $semaphore_dir"

while monitor_semaphore
do
    echo "Semaphore received, restarting Skimage container"
    # docker-compose start_skimage
done

