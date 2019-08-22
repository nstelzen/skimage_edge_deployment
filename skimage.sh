#!/bin/bash



# Setup function to monitor semphore directory
function monitor_semaphore {
  # This function returns True when a file is created or 
  # modified in the semaphore directory    
  inotifywait \
        -e modify,create \
        ${semaphore_dir}
}

if [ "$USER" == "odroid" ]
  then echo "Please run as root"
  exit
fi

# Remove any containers left by a forced shutdown
docker-compose \
    -f /home/odroid/skimage_edge_deployment/Utilities/docker-compose.yml \
    down


# Or just docker-compose up?

# Start watchdog
# docker-compose start_watchdog

# Start Skimage
# xhost +local:root
# xhost +local:docker
# XSOCK=/tmp/.X11-unix

XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker-compose \
    -f /home/odroid/skimage_edge_deployment/Utilities/docker-compose.yml \
    run --rm prod_ARM python python_src/skimage_edge.py

# Start monitoring the semphore file
semaphore_dir="/home/odroid/skimage_edge_deployment/data/semaphore"
mkdir -p ${semaphore_dir}
echo "Monitoring semaphore file $semaphore_dir"

# While loop in bash calls "monitor_semaphore", then goes through the loop
# if "monitor_semaphore" returns TRUE. Monitor semaphore returns TRUE only
# when a semphore is created or modified, otherwise it simply efficiently monitors
# the semaphore directory. Thus "monitor_semaphore" never returns false, and the
# while loop never exits.
while monitor_semaphore
do
    echo "Semaphore received, restarting Skimage container"
    # docker-compose stop skimage
    # docker-compose start skimage
done

