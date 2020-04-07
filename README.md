# deploy-rails-with-docker
Docker-compose script so that you can easily deploy to an AWS instance that has docker and git installed.

# Requirements:
  You need to have an ssh connection to an AWS EC2 instance, which is running a version of Linux Ubuntu x86 16.04 or higher. Ports (22 and 80) need to be released in the Security Group.

# In the SSH terminal of your instance run:
   - sudo su

# Then copy and paste line by line the commands:
   - apt-get update
   - apt-get install git-core
   - git clone https://github.com/davidleandro/deploy-rails-with-docker
   - cd deploy-rails-with-docker

# Start the script from the following commands:
    - chmod 777 install_docker.sh
    - bash ./install_docker.sh
