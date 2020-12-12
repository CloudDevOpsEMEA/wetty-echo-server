const http = require('http');
const url = require('url');
const { config } = require('process');
const conf = require('./config');
const { log } = require('./loggertool');

const serverHost =  process.env.HTTP_ECHO_HOST || config.host;
const serverPort =  process.env.HTTP_ECHO_PORT || config.port;
 
const server = http.createServer(function (req, res) {
  log("http_server", "info", `Connected at ${req.connection.remoteAddress}:${req.connection.remotePort}`)
  log("http_server", "info", `HTTP Method ${req.method} on URL ${req.url}`)
  
  const parsedURL = url.parse(req.url, true)
  res.setHeader('Cache-control', 'no-cache')
  res.setHeader("Content-Type", "application/json")

  let data = '';
  req.on('data', chunk => {
    data += chunk;
  })

  req.on('end', () => {
    let timestp = new Date()
    const response = {
			description: 'HTTP ECHO SERVER RESPONSE',
			serverPort: serverPort,
			serverHost: serverHost,
			timestamp: timestp.toJSON(),
			received: {
				message: data,
				fromIP: req.connection.remoteAddress,
				fromPort: req.connection.remotePort
			}
		}

    if (parsedURL.pathname == '/') {
        res.statusCode = 200
        res.end(JSON.stringify(response))
    } else if (parsedURL.pathname == '/slow') {
        res.statusCode = 200
        setTimeout(() => { 
          log("http_server", "info", "Sleeping 2 seconds")
          res.end(JSON.stringify(response))
        }, 2000)
    } else if (parsedURL.pathname == '/status' && parsedURL.query.code) {
        if (http.STATUS_CODES[parsedURL.query.code]) {
          res.statusCode = parsedURL.query.code
          res.end(JSON.stringify(response))
        } else {
          res.statusCode = 400;
          log("http_server", "error", `HTTP 400: Bad request parameter ${parsedURL.query.code}`)
          res.end("Bad request")
        }
    } else {
        res.statusCode = 404;
        log("http_server", "error", "HTTP 404: Page not found")
        res.end("Page not found")
    }
  })
});
 
server.listen(serverPort, serverHost, function () {
	const address = server.address()
	const port = address.port
  const family = address.family
  const ipaddr = address.address
    
	log("http_server", "info", "HTTP Echo Server started")
	log("http_server", "info", `HTTP Echo Server port     : ${port}`)
  log("http_server", "info", `HTTP Echo Server ip       : ${ipaddr}`)
  log("http_server", "info", `HTTP Echo Server protocol : ${family}`)
});
