pragma solidity ^0.6.0;

import './base/Level.sol';
import './DiscoLP.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DiscoLPFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    address _factory = $.UniswapV2_FACTORY;
    ERC20 tokenA = new ERC20("Token A", "TKNA");
    ERC20 tokenB = new ERC20("Token B", "TKNB");
    address reserveToken = IUniswapV2Factory(_factory).createPair(address(tokenA), address(tokenB));
    DiscoLP instance = new DiscoLP("DiscoLP", "DISCO", 18, reserveToken);
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public returns (bool) {
    _player;
    DiscoLP instance = DiscoLP(_instance);
    return true;
  }
}
