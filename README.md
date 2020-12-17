# Wetty Echo Server

## Introduction

This docker container is created for demo purposes. It contains a TCP, UDP and HTTP based echo server and provides Web based terminal access into the container. The 4 different services offered, can be enabled or disabled at preference. The contiainer is based on Alpine Linux and has two flavors: a slim version without extra debug tools and a fat version with debug tools.

This container is useful for demoing and or debugging service mesh or other intra service network communication scenario's, without having to deploy a full blown microservice based application. The container can act both as the client (netcat for tcp/udp/http or curl for http) and a server. The servers are written in Javascript. 

The web based terminal is based on [wetty](https://github.com/butlerx/wetty). A user account **admin** with password **admin** has been created for terminal access.

In order to provide proper container support for multiple processes running, [dumb-init](https://github.com/Yelp/dumb-init) is used as a simple process supervisor and init system designed to run as PID 1 inside minimal container.


### Github & dockerhub

The source code and docker containers are available at the following locations.

- Github: https://github.com/boeboe/wetty-echo-server
- Dockerhub: https://hub.docker.com/r/boeboe/wetty-echo-server 

## Usage

### Environment variables

The following docker ENV variables can be used to tweak the behavior of this container.

| ENV Variable      | Default | Usage                   |
|-------------------|---------|-------------------------|
| WETTY_ENABLED     | true    | enable web terminal     |
| WETTY_PORT        | 3000    | web terminal port       |
| TCP_ECHO_ENABLED  | true    | enable tcp echo server  |
| TCP_ECHO_HOST     | 0.0.0.0 | tcp echo server host    |
| TCP_ECHO_PORT     | 3001    | tcp echo server port    |
| UDP_ECHO_ENABLED  | true    | enable udp echo server  |
| UDP_ECHO_HOST     | 0.0.0.0 | udp echo server host    |
| UDP_ECHO_PORT     | 3002    | udp echo server port    |
| HTTP_ECHO_ENABLED | true    | enable http echo server |
| HTTP_ECHO_HOST    | 0.0.0.0 | http echo server host   |
| HTTP_ECHO_PORT    | 3003    | http echo server port   |


### Docker run

In order to run this container with the defaults (all services enabled):

```sh
$ docker run -i -t --rm -p=18080:3000 -p=18081:3001 -p=18082:3002/udp -p=18083:3003 --name="wetty-echo-server" boeboe/wetty-echo-server
```

To run the container with only wetty and http echo enabled:

```sh
$ docker run -i -t --rm -p=18080:3000 -p=18083:3003 -e TCP_ECHO_ENABLED=false -e UDP_ECHO_ENABLED=false --name="wetty-echo-server" boeboe/wetty-echo-server
```


### Termanal usage

The user credentials for the web based terminal access method are:

```properties
username: admin
password: admin
```

The terminal is accessible on the following url:

```properties
url_terminal: http://<host>:18080/wetty
```

An example on on how to use the container as both client and server.

![screeshot wetty terminal](imgs/screenshot.png "Wetty terminal usage")


### Installed tooling

There are two versions of this docker container. A slim and a fat version, the latter containing extra debugging and demo tooling.

Current version is 1.0.0.

| Version tag                        | Tools installed |
|-----------|-----------------|
| 1.0.0     | dumb-init openssh-client sshpass curl netcat-openbsd jq |
| 1.0.0-dbg | bash tree vim nano strace iputils wget httpie net-tools socat tcpdump bind-tools iproute2 tcptraceroute iperf3 |


Extra [Alpine packages](https://pkgs.alpinelinux.org/packages) can be installed on the fly with the package manager apk.

```sh
$ apk add -U zsh 
```


## Note

This container is purely used for demo purposes and not meant for production environments at all.

