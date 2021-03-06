require("@nomiclabs/hardhat-truffle5");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {
      blockGasLimit: 9500000,
      forking: {
        url: "https://eth-ropsten.alchemyapi.io/v2/DX39e67S1a4pmCjgGKavlEOvl9RUCNGT",
        blockNumber: 10144911
      },
      allowUnlimitedContractSize: true
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.5.3"
      },
      {
        version: "0.6.5"
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000
          }
        }
      },
      {
        version: "0.6.6"
      }
    ]
  },
  paths: {
    artifacts: './build'
  }
};
