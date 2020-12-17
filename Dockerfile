FROM node:carbon-alpine as builder
LABEL maintainer="Bart Van Bos <bartvanbos@gmail.com>"
RUN apk add -U --no-cache build-base python git
WORKDIR /wetty-app
RUN git clone https://github.com/butlerx/wetty /wetty-app && \
	  git checkout d0aaa35dbfcb30d8739c22cb3226238ad23a6d7d && \
    yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline

COPY echo-servers /echo-servers
RUN npm --prefix /echo-servers/tcp install
RUN npm --prefix /echo-servers/udp install
RUN npm --prefix /echo-servers/http install


FROM node:carbon-alpine
LABEL maintainer="Bart Van Bos <bartvanbos@gmail.com>"
ENV NODE_ENV=production
ARG DEBUG_TOOLS
ARG DEBUG_TOOL_LIST

COPY --from=builder /wetty-app/dist /wetty-app/dist
COPY --from=builder /wetty-app/node_modules /wetty-app/node_modules
COPY --from=builder /wetty-app/package.json /wetty-app/package.json
COPY --from=builder /wetty-app/index.js /wetty-app/index.js
COPY --from=builder /echo-servers /echo-servers
RUN apk add -U --no-cache dumb-init openssh-client sshpass curl netcat-openbsd && \
    if [ "$DEBUG_TOOLS" = "true" ] ; then apk add -U --no-cache ${DEBUG_TOOL_LIST} ; fi && \
    adduser -D -h /home/admin -s /bin/sh admin && ( echo "admin:admin" | chpasswd ) && adduser admin root

ADD run.sh /

# Wetty ENV params
ENV WETTY_ENABLED=true \
    REMOTE_SSH_SERVER=0.0.0.0 \
    REMOTE_SSH_PORT=22 \
    WETTY_PORT=3000 

# TCP Echo Server ENV params
ENV TCP_ECHO_ENABLED=true \
    TCP_ECHO_HOST=0.0.0.0 \
    TCP_ECHO_PORT=3001

# UDP Echo Server ENV params
ENV UDP_ECHO_ENABLED=true \
    UDP_ECHO_HOST=0.0.0.0 \
    UDP_ECHO_PORT=3002

# HTTP Echo Server ENV params
ENV HTTP_ECHO_ENABLED=true \
    HTTP_ECHO_HOST=0.0.0.0 \
    HTTP_ECHO_PORT=3003

EXPOSE 3000
EXPOSE 3001
EXPOSE 3002/udp
EXPOSE 3003

WORKDIR /
ENTRYPOINT "./run.sh"
