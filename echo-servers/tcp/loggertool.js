
const winston = require('winston')
const moment = require('moment')
const conf = require('./config')

const transports = [
    new winston.transports.Console({
        colorize: true,
        name: 'logs',
        stderrLevels: ['error']
    })
]

const logger = winston.createLogger({
    format: winston.format.json(),
    transports: transports
})

const log = async (service, level, msg) => {
    logger.log({
        timestamp: moment().format('YYYY-MM-DD HH:mm:ss.SSSS'),
        service: service,
        level: level,
        message: msg
    })
}

module.exports = { log }
