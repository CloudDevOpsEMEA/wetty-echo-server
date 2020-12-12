#!/usr/bin/dumb-init /bin/sh

npm start --prefix /echo-servers/tcp &
npm start --prefix /echo-servers/udp &

npm start --prefix /app -p ${WETTY_PORT} 
