FROM node:argon

# Create app directory
RUN mkdir -p /usr/src/ip-app
WORKDIR /usr/src/ip-app

# Install app dependencies
COPY package.json /usr/src/ip-app/
RUN npm install

# Bundle app source
COPY . /usr/src/ip-app

EXPOSE 8080
CMD [ "npm", "start" ]