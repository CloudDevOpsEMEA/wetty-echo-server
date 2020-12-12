FROM node:carbon-alpine as builder
RUN apk add -U build-base python git
WORKDIR /app
#COPY . /app
RUN git clone https://github.com/butlerx/wetty /app && \
	git checkout d0aaa35dbfcb30d8739c22cb3226238ad23a6d7d && \
    yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline

FROM node:carbon-alpine
LABEL maintainer="Bart Van Bos <bartvanbos@gmail.com>"
WORKDIR /app
ENV NODE_ENV=production
EXPOSE 3000
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/index.js /app/index.js
RUN apk add -U dumb-init bash openssh-client sshpass tree iputils curl wget httpie net-tools netcat-openbsd socat tcpdump bind-tools iproute2
RUN adduser -D -h /home/admin -s /bin/sh admin && ( echo "admin:admin" | chpasswd ) && adduser admin root
ADD run.sh /

COPY echo-servers /echo-servers
RUN npm --prefix /echo-servers/tcp install
RUN npm --prefix /echo-servers/udp install

# Default ENV params used by wetty
ENV REMOTE_SSH_SERVER=127.0.0.1 \
    REMOTE_SSH_PORT=22 \
    WETTY_PORT=3000

EXPOSE 3000
EXPOSE 3001/tcp
EXPOSE 3002/udp

WORKDIR /
ENTRYPOINT "./run.sh"