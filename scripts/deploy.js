
require("dotenv").config();
const data = require('../utils/data');
async function deploy() {
    const contract = await ethers.getContractFactory('ContractLogic');
    const deployedContract = await contract.deploy(
        data.variantNumbers,
        data.initialPlayerBallance,
    );
    console.log("Contract deployed to address:", deployedContract.address);
}

deploy()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });