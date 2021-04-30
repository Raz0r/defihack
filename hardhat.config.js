require("@nomiclabs/hardhat-truffle5");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-ropsten.alchemyapi.io/v2/DX39e67S1a4pmCjgGKavlEOvl9RUCNGT",
        blockNumber: 10144911
      }
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.5.3"
      },
      {
        version: "0.6.5"
      }
    ]
  },
  paths: {
    artifacts: './build'
  }
};
