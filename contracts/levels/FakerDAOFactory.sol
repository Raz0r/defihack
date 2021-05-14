pragma solidity ^0.6.0;

import './base/Level.sol';
import './FakerDAO.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Token is ERC20 {
  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) public {
    _mint(msg.sender, 1000000 * 10 ** 18); // initial LP liquidity
    _mint(tx.origin, 5000 * 10 ** 18); // a tip to user
  }
}

contract FakerDAOFactory is Level {
  function createInstance(address _player) override public payable returns (address) {
    _player;
    address _factory = $.UniswapV2_FACTORY;
    address _router = $.UniswapV2_ROUTER02;
    Token yin = new Token("Yin", "YIN");
    Token yang = new Token("Yang", "YANG");
    address pair = IUniswapV2Factory(_factory).createPair(address(yin), address(yang));
    FakerDAO instance = new FakerDAO(pair);
    yin.approve(_router, uint256(-1));
    yang.approve(_router, uint256(-1));
    (uint256 amountA, uint256 amountB, uint256 _shares) = Router02(_router).addLiquidity(
      address(yin),
      address(yang),
      1000000 * 10 ** 18,
      1000000 * 10 ** 18,
      1, 1, address(instance), uint256(-1));
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public returns (bool) {
    _player;
    return FakerDAO(_instance).balanceOf(_player) > 0;
  }
}

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface Router01
{
	function WETH() external pure returns (address _token);
	function addLiquidity(address _tokenA, address _tokenB, uint256 _amountADesired, uint256 _amountBDesired, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB, uint256 _liquidity);
	function removeLiquidity(address _tokenA, address _tokenB, uint256 _liquidity, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB);
	function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapETHForExactTokens(uint256 _amountOut, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut) external pure returns (uint256 _amountOut);
}

interface Router02 is Router01
{
}
