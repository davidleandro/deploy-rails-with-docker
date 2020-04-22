#!/bin/bash
clear

# Account access
read -p 'Ruby Version: ' ruby
read -p 'Git Username: ' uservar
read -sp 'Git Password: ' passvar
echo
read -p 'URL Project: ' project

# Remove https
URL="${project/'https://'/''}"
CUSTOMURL="https://${uservar}:${passvar}@${URL}"
WORKDIR="myapp"

cat <<EOT >> Dockerfile
    # Base image:
    FROM ruby:${ruby}

    # Install dependencies
    RUN apt-get update
    RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
    RUN apt-get install -qq -y \
      git \
      nodejs \
      cron \
      memcached

    # Create project directory
    RUN mkdir /${WORKDIR}

    # Set our working directory inside the image
    WORKDIR /${WORKDIR}

    # Clone remote repository
    RUN git clone ${CUSTOMURL} .

    # Copy the Rails application into place
    COPY application.yml /${WORKDIR}/config/application.yml
    COPY . /${WORKDIR}

    # Define where our application will live inside the image
    ENV BUNDLE_PATH /bundle
    ENV RAILS_ENV production
    ENV RACK_ENV production

    # Finish establishing our Ruby enviornment
    RUN bundle install

    # It allows the dynamic visualization, lines are displayed on the screen as they are generated
    CMD tail -f /dev/null

    # Create crontab schedules
    RUN bundle exec whenever --update-crontab
    RUN crontab -l

    EXPOSE 3000
    EXPOSE 11211

    CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
    RUN echo 'INSTALL FINISHED!'
EOT

cat <<EOT >> docker-compose.yml
version: "3.3"
services:
  app:
    build: .
    restart: always
    command: bash -c "cron && RAILS_ENV=production bundle exec puma -C config/puma.rb && /usr/bin/memcached -u root"
    environment:
      - BUNDLE_PATH=/bundle
    ports:
      - 80:3000
      - 443:3000
    volumes:
      - .:/var/${WORKDIR}
volumes:
  bundle:
EOT

# clear

# Stop current running docker and build a new one
docker-compose stop
docker-compose build

# Delete Dockerfile with developer user login/password
rm -f Dockerfile

# clear bash
# clear

# Run the new build of Docker
docker-compose up
