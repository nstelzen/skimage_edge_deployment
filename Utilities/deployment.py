# Python script to install and/or update Skimage 

# Options:
#   1) Full install from scratch
#   2) Update docker image
#   3) Update all source code
#   4) Update parameter files only

# The selected option will be performed on all the Odroids listed in the parameter file

# All Odroids in network should have hard-coded login:password "odroid:odroid"
import urllib.request
import git
import sys
import subprocess
import paramiko
import logging 

import python_src.parameter_parser as parameter_parser
from python_src.startup_checks import check_ping

logging.basicConfig(level=logging.INFO)

def test_internet_connection():
    # Test internet connection, warn that we can't pull latest Docker
    # image or source code from repos w/o internet
    try:
        logging.info('Testing internet connection . . . ')
        response = urllib.request.urlopen('https://www.google.com/', timeout=1)
        logging.info('Internet connection found')
        return True

    except:
        logging.warning('No internet connection found! '
        + 'Proceeding with to do the update with local files '
        + 'Remember to synchronize the source code with the Github repo as soon as possible') 
        return False

def pull_source_code(source_folder):
    # Attempt to pull source code from Github, warn if not possible
    try:
        logging.info('Pulling latest version of source code from github . . . ')
        git_repo = git.Repo(source_folder)
        git_repo.remotes.origin.pull()
        logging.info('Pull successful, source code is synchronized with github')
    except:
        logging.warning('Unable to pull latest version of code from the github repository')
    return

def pull_docker_image(docker_image_name):
    # Attempt to pull Docker image, warn if not possible
    try:
        subprocess.run('docker pull ' + docker_image_name, check=True, shell=True)
    except:
        logging.warning('Unable to pull latest version of the docker image from the repository')

    return 

def create_docker_tarball(docker_image_name):
    # Create compressed docker image file from local docker image
    try:
        subprocess.run('docker save -o ~/docker_image.tar ' + docker_image_name, check=True, shell=True)
    except:
        logging.critical('Unable to compress and save docker image! Check docker_image_name and try again')
        sys.exit(0)

def get_list_of_odroids():
    # Load parameter file and get list of odroid's ip address
    # ping each ip and report results
    try:
        logging.info('Loading parameter file . . . ')
        parameters_all = parameter_parser.get_parameters(param_filename = 'data/skimage_parameters.xlsx',
                                                         get_all_params = True)
    except:
        logging.critical('Unable to load parameter file!')
        sys.exit(0)

    list_of_odroids = []
    for params in parameters_all:
        if not params['Sensor_Label']:
            sensor_label = params['Sensor_Label']
            ip_address = params['Odroid_Path']
            ping_status = check_ping(ip_address)
            if ping_status:
                list_of_odroids.append(ip_address)
                logging.info('Odroid: ' +  sensor_label 
                                     + '   IP address: ' + ip_address 
                                     + '   Connection status: Found on network') 
            else:
                logging.error('Odroid: ' +  sensor_label 
                                      + '   IP address: ' + ip_address 
                                      + '   Connection status: NOT found on network')

    return list_of_odroids

def connect_to_remote_odroid(ip_address, user, password ):
    try:
        logging.info('Establishing SSH connection to ' + user + '@' + ip_address + ' . . . ')
        ssh_client =paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(hostname=ip_address,username=user,password=password)
        logging.info('SSH connection established')
        return ssh_client
    except:
        logging.warning('Unable to connect to ' + ip_address + ' via SSH')
        return None

def copy_parameter_file(ssh_client, source_folder, password):
    # Copy parameter file to remote Odroid
    parameter_filepath = source_folder + '/data/skimage_parameters.xlsx'
    parameter_pickle_filepath = source_folder + '/data/skimage_parameters.pickle'
    stdin, stdout, stderr = ssh.exec_command('sudo rm -f ' + parameter_filepath 
                                             + ' ' + parameter_pickle_filepath)
    stdin.write(password + '\n')
    print(stdout.readlines())
    return

def write_my_id(ssh_client):
    # Check if my_id.txt file exists
    # If it doesn't exist, create it. Contains the last three numbers of ip address
    pass

def update_source_code(ssh_client):
    # Delete source code folder on remote, preserving log folders
    # Copy local source code file to remote
    # Change permission to +x on "skimage.sh"
    pass

def setup_systemd(ssh_client):
    # After an update of the source code this resets the systemd service
    # Copy the skimage_watchdog.service file to correct location
    # Reload systemd daemon
    # Enable systemd service
    pass

def confirm_skimage_logs_folder(ssh_client):
    # Check that Logs_SKIMAGE folder exists, if not, create it
    # Check that soft link to home/odroid/Logs_SKIMAGE, if not, create it
    pass

def compare_time(ssh_client):
    # set timezone
    # Compare date/time local and remote, warn if difference is too great
    pass

def update_docker_image(ssh_client):
    # Copy zipped docker image to remote
    # Load docker image on remote
    pass

def reboot_remote(ssh_client):
    # Reboot remote odroid
    pass

def fresh_install(ssh_client):
    # A fresh install means the remote odroid has simply the factory OS
    # We require that the remote odroid have an internet connection to 
    # do a fresh install

    # Check internet connection
    # Run pre-setup.sh to install the docker engine, pull the source code from github, etc.
    pass

def deploy_skimage(**args):
    # Main update script
    user = 'odroid'
    password = 'odroid'
    source_folder = '/home'
    docker_image_name = 'nickstelzenmuller/skimage:ARM_prod'

    logging.info('''Options:
    1 : Full install from scratch 
    2 : Update docker image
    3 : Update all source code
    4 : Update parameter files only''')
    if not args:
        option = input('Please select and option (1-4) :')

    # Select option
    if option == '1':
        # Do a fresh install. This will pull the latest docker image and source folder
        do_fresh_install = True
        do_update_docker_image = False
        do_update_source_folder = False
        do_update_parameters = False

    elif option == '2':
        # Update Docker image. Do a source folder update as well
        do_fresh_install = False
        do_update_docker_image = True
        do_update_source_folder = True
        do_update_parameters = False

    elif option == '3':
        # Update source folder. This includes the parameter file 
        do_fresh_install = False
        do_update_docker_image = False
        do_update_source_folder = True
        do_update_parameters = False

    elif option == '4':
        # Update the parameter file only
        do_fresh_install = False
        do_update_docker_image = False
        do_update_source_folder = False
        do_update_parameters = True

    else:
        logging.info('The valid options are 1, 2, 3, or 4. Please choose a valid option')
        deploy_skimage()

    internet_connection = test_internet_connection()

    if internet_connection:
        pull_source_code(source_folder)
        pull_docker_image(docker_image_name)

    if do_fresh_install:
        if not internet_connection:
            logging.info('The "fresh installation" option requires an internet connection ' +
                  'but one was not found. Exiting now')
            return None
    
    if do_update_docker_image:
        docker_tarball = create_docker_tarball(docker_image_name)

    list_of_odroids = get_list_of_odroids()

    bad_connections = []
    for ip_address in list_of_odroids:
        ssh_client = connect_to_remote_odroid(ip_address, user, password)
        if not ssh_client:
            logging.Warning('Unable to update Odroid at ' + ip_address)
            bad_connections.append(ip_address)

        if do_fresh_install:
            fresh_install(ip_address)

        if do_update_docker_image:
            update_docker_image(ip_address)

        if do_update_source_folder:
            update_source_code(ip_address)
            setup_systemd(ip_address)
            compare_time(ip_address)
            write_my_id(ip_address)
            confirm_skimage_logs_folder(ip_address)
            reboot_remote(ip_address)

        if do_update_parameters:
            copy_parameter_file(ip_address)
            compare_time(ip_address)
            write_my_id(ip_address)
            confirm_skimage_logs_folder(ip_address)
            reboot_remote(ip_address)
        


if __name__ == "__main__":
    deploy_skimage()

    
