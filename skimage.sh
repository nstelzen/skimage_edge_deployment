#!/bin/bash



# Setup function to monitor semphore directory
function monitor_semaphore {
  # This function returns True when a file is created or 
  # modified in the semaphore directory    
  inotifywait \
        -e modify,create \
        ${semaphore_dir}
}

# Start monitoring the semphore file
semaphore_dir="/home/odroid/skimage_edge_deployment/data/semaphore"
mkdir -p --mode=0777 ${semaphore_dir}
touch "${semaphore_dir}/RESET"

running_skimage_pids=($(pgrep -f skimage.sh))
echo ${running_skimage_pids}
for pid_skimage in ${running_skimage_pids}
do
    if [ ${pid_skimage} != ${PPID} ]
    then
        echo "Waiting for previously started skimage.sh to terminate . . ."
        wait ${pid_skimage}
    else
        echo "Self PID ${PPID} is ${pid_skimage}"
    fi
done
echo "All previously started instances of Skimage have stopped, Skimage will now start"

echo "Resetting semaphore directory"
rm -r ${semaphore_dir}
mkdir -p ${semaphore_dir}

# Remove any containers left by a forced shutdown
docker-compose \
    -f /home/odroid/skimage_edge_deployment/Utilities/docker-compose.yml \
    down


# Start watchdog
# docker-compose start_watchdog

XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker-compose \
    -f /home/odroid/skimage_edge_deployment/Utilities/docker-compose.yml \
    run --rm prod_ARM python python_src/skimage_edge.py



# While loop in bash calls "monitor_semaphore", then goes through the loop
# if "monitor_semaphore" returns TRUE. Monitor semaphore returns TRUE only
# when a semphore is created or modified, otherwise it simply efficiently monitors
# the semaphore directory. Thus "monitor_semaphore" never returns false, and the
# while loop never exits.
while monitor_semaphore
do  
    echo "Semaphore received, stopping Skimage"
    # docker-compose stop skimage
    
    if [! -f ${semaphore_dir}/RESET]
    then
        # docker-compose start skimage
        echo "Restarting Skimage"
    fi
    
done

