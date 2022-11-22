const { createAlchemyWeb3 } = require('@alch/alchemy-web3');
const express = require('express');

const fs = require('fs');
const cors = require('cors');
const bodyParser = require('body-parser');
require("dotenv").config();
const routes = require('./utils/routes');
const messages = require('./utils/messages');
const solidityService = require('./solidity.service');
const app = express();
app.use(cors())
app.use(bodyParser.json());
app.post(routes.createPlayer.route, async (req, res) => await solidityService.createPlayerRoute(req, res));
app.listen(process.env.PORT, () => console.log(messages.serverStarted))

