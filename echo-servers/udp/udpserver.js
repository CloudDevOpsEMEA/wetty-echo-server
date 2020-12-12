const udp = require('dgram');
const conf = require('./config');
const { log } = require('./loggertool');

const serverHost =  process.env.UDP_ECHO_HOST || config.host;
const serverPort =  process.env.UDP_ECHO_PORT || config.port;

const server = udp.createSocket('udp4');

server.on('error', (error) => {
    log("udp_server", "error", error)
    server.close()
});

server.on('message', (msg,info) => {
    log("udp_server", "info", msg.toString() + ` | Received ${msg.length} bytes from ${info.address}:${info.port}`)

    let timestp = new Date()
    const response = {
        description: 'UDP PORT RESPONSE',
        serverPort: serverPort,
        serverHost: serverHost,
        timestamp: timestp.toJSON(),
        received: {
            message: msg.toString(),
            fromIP: info.address,
            fromPort: info.port
        }
    }
    const data = Buffer.from(JSON.stringify(response))

    server.send(data, info.port, info.address, (error, bytes) => {
        if(error){
            log("udp_server", "error", error)
            client.close()
        } else {
            log("udp_server", "info", 'Data sent !!!')
        }    
    })
});

server.on('listening', () => {
    const address = server.address()
    const port = address.port
    const family = address.family
    const ipaddr = address.address

    log("udp_server", "info", 'Server is listening at port ' + port)
    log("udp_server", "info", 'Server ip :' + ipaddr)
    log("udp_server", "info", 'Server is IP4/IP6 : ' + family)
});

server.on('close', () => {
    log("udp_server", "info", 'Socket is closed !')
});

server.bind(serverPort, serverHost);