#!/usr/bin/dumb-init /bin/sh

if [ "$TCP_ECHO_ENABLED" = true ] ; then
  npm start --prefix /echo-servers/tcp &
fi

if [ "$UDP_ECHO_ENABLED" = true ] ; then
  npm start --prefix /echo-servers/udp &
fi

if [ "$WETTY_ENABLED" = true ] ; then
  npm start --prefix /wetty-app -p ${WETTY_PORT} &
fi
