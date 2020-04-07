#!/bin/bash
clear
# Account access
read -p 'Ruby Version: ' ruby
read -p 'Git Username: ' uservar
read -sp 'Git Password: ' passvar
echo
read -p 'URL Project: ' project
read -p 'Project name (without spaces): ' WORKDIR

# Remove https
URL="${project/'https://'/''}"
CUSTOMURL="https://${uservar}:${passvar}@${URL}"

cat <<EOT >> Dockerfile
    # Base image:
    FROM ruby:${ruby}

    # Install dependencies
    RUN apt-get update
    RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
    RUN apt-get apt-get install -qq -y \
      git \
      nodejs \
      cron

    # Create project directory
    RUN mkdir /${WORKDIR}

    # Set our working directory inside the image
    WORKDIR /${WORKDIR}

    # Clone remote repository
    RUN git clone ${CUSTOMURL} .

    # Copy the Rails application into place
    COPY . /${WORKDIR}

    # Define where our application will live inside the image
    ENV BUNDLE_PATH /bundle

    # Define the enviroment that will be rolling
    ENV RAILS_ENV production

    # Finish establishing our Ruby enviornment
    RUN bundle install

    # It allows the dynamic visualization, lines are displayed on the screen as they are generated
    CMD tail -f /dev/null

    # Create crontab schedules
    RUN bundle exec whenever --update-crontab
    RUN crontab -l

    RUN echo 'INSTALL FINISHED!'
EOT

cat <<EOT >> docker-compose.yml
version: "3.3"
services:
  app:
    build: .
    restart: always
    command: cron && bundle exec rails s -b 0.0.0.0
    environment:
      - BUNDLE_PATH=/bundle
    ports:
      - 80:3000
    volumes:
      - .:/var/${WORKDIR}
volumes:
  bundle:
EOT

clear

# Stop current running docker and build a new one
docker-compose stop
docker-compose build

# Delete Dockerfile with developer user login/password
rm -f Dockerfile

# clear bash
clear

# Run the new build of Docker
docker-compose up
