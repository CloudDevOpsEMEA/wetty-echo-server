const net = require('net');
const { config } = require('process');
const conf = require('./config');
const { log } = require('./loggertool');

const serverHost =  process.env.TCP_ECHO_HOST || config.host;
const serverPort =  process.env.TCP_ECHO_PORT || config.port;

const server = net.createServer();

server.on('error', (error) => {
    log("tcp_server", "error", error)
    server.close()
});

const sockets = [];
server.on('connection', sock => {
	log("tcp_server", "info", `Connected at ${sock.remoteAddress}:${sock.remotePort}`)

	sockets.push(sock)

	sock.on('data', data => {
		
		log("tcp_server", "info", data.toString() + ` | Received ${sock.bytesRead} bytes from ${sock.remoteAddress}:${sock.remotePort}`)

		let timestp = new Date()
		const response = {
			description: 'TCP ECHO SERVER RESPONSE',
			serverPort: serverPort,
			serverHost: serverHost,
			timestamp: timestp.toJSON(),
			received: {
				message: data.toString(),
				fromIP: sock.remoteAddress,
				fromPort: sock.remotePort
			}
		}
		const dataBuffer = Buffer.from(JSON.stringify(response))

		// Write the data back to all the connected, the client will receive it as data from the server
		sockets.forEach((sock, index, array) => {
			sock.write(dataBuffer)	
		})
	})

	sock.on('close', data => {
		let index = sockets.findIndex( o => {
			return o.remoteAddress === sock.remoteAddress && o.remotePort === sock.remotePort
		})

		if (index !== -1) { 
			sockets.splice(index, 1) 
		}
		log("tcp_server", "info", `Socket closed with ${sock.remoteAddress}:${sock.remotePort}`)
	})
});


server.listen(serverPort, serverHost, () => {
	const address = server.address()
	const port = address.port
  const family = address.family
  const ipaddr = address.address
    
	log("tcp_server", "info", "TCP Echo Server started")
	log("tcp_server", "info", `TCP Echo Server port     : ${port}`)
  log("tcp_server", "info", `TCP Echo Server ip       : ${ipaddr}`)
  log("tcp_server", "info", `TCP Echo Server protocol : ${family}`)
});