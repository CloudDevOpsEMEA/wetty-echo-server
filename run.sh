#!/usr/bin/dumb-init /bin/sh


# Login mode, no SSH_SERVER
npm start --prefix /app -p ${WETTY_PORT} 
