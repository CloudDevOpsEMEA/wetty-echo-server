#!/usr/bin/dumb-init /bin/sh

set -x
echo "Running /run.sh with the following ENV"
echo $(env)

if [ "$TCP_ECHO_ENABLED" = true ] ; then
  echo "Starting TCP echo server on ${TCP_ECHO_HOST}:${TCP_ECHO_PORT}"
  npm start --prefix /echo-servers/tcp &
fi

if [ "$UDP_ECHO_ENABLED" = true ] ; then
  echo "Starting UDP echo server on ${UDP_ECHO_HOST}:${UDP_ECHO_PORT}"
  npm start --prefix /echo-servers/udp &
fi

if [ "$HTTP_ECHO_ENABLED" = true ] ; then
  echo "Starting HTTP echo server on ${HTTP_ECHO_HOST}:${HTTP_ECHO_PORT}"
  npm start --prefix /echo-servers/http &
fi

if [ "$WETTY_ENABLED" = true ] ; then
  echo "Starting Wetty server on ${REMOTE_SSH_SERVER}:${WETTY_PORT}"
  npm start --prefix /wetty-app -p ${WETTY_PORT} &
fi

tail -f /dev/null
