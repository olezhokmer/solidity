const { createAlchemyWeb3 } = require('@alch/alchemy-web3');
const fs = require('fs');
const { StatusCodes } = require('http-status-codes');
require("dotenv").config();
const bytes32 = require('bytes32');
const web3 = createAlchemyWeb3(process.env.API_URL);
const contractArtifacts = JSON.parse(
    fs.readFileSync('./artifacts/contracts/contract.sol/ContractLogic.json'),
);
const contract = new web3.eth.Contract(contractArtifacts.abi, process.env.contractAddress);

class SolidityService {
    async createPlayer(name, secret) {
        return await contract.methods.createPlayer(
            bytes32({ input: name }),
            bytes32({ input: secret }),
        ).call();      
    }

    async createPlayerRoute(req, res) {
        try {
            const { name, secret } = req.body;
            const response = await this.createPlayer(name, secret);
            return res.json(response);
        } catch (error) {
            return res.send(error.message).status(StatusCodes.BAD_REQUEST);
        }
    }
}
module.exports = new SolidityService();