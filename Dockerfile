FROM ubuntu:14.04
RUN apt-get -y update
RUN apt-get -y install nodejs
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN apt-get -y install npm
RUN mkdir commodore
COPY . commodore
WORKDIR commodore
RUN npm install -g grunt-cli
RUN npm install
RUN grunt build
EXPOSE 3050
CMD ["nodejs", "./private/server.js"]
