FROM node:5

EXPOSE 3000

WORKDIR /opt/src

ADD . /opt/src

RUN npm install

CMD ["node", "./app.js"]