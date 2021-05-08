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

contract Token is ERC20 {
  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) public {
    _mint(msg.sender, 100000 * 10 ** 18); // initial LP liquidity
    _mint(tx.origin, 1 * 10 ** 18); // a tip to user
  }
}

contract DiscoLPFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    address _factory = $.UniswapV2_FACTORY;
    address _router = $.UniswapV2_ROUTER02;
    ERC20 tokenA = new Token("Jimbo", "JIMBO");
    ERC20 tokenB = new Token("Jambo", "JAMBO");
    address reserveToken = IUniswapV2Factory(_factory).createPair(address(tokenA), address(tokenB));
    DiscoLP instance = new DiscoLP("DiscoLP", "DISCO", 18, reserveToken);
    tokenA.approve(_router, uint256(-1));
    tokenB.approve(_router, uint256(-1));
    (uint256 amountA, uint256 amountB, uint256 _shares) = Router02(_router).addLiquidity(
      address(tokenA),
      address(tokenB),
      100000 * 10 ** 18,
      100000 * 10 ** 18,
      1, 1, address(instance), uint256(-1));
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public returns (bool) {
    _player;
    return DiscoLP(_instance).balanceOf(_player) > 100 * 10 ** 18;
  }
}
