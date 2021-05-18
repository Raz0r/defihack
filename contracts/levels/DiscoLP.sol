pragma solidity >=0.6.5;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Babylonian.sol";

contract DiscoLP is ERC20, Ownable, ReentrancyGuard
{
  using SafeERC20 for IERC20;

  address public immutable reserveToken;

  constructor (string memory _name, string memory _symbol, uint8 _decimals, address _reserveToken)
    ERC20(_name, _symbol) public
  {
    _setupDecimals(_decimals);
    assert(_reserveToken != address(0));
    reserveToken = _reserveToken;
    _mint(address(this), 100000 * 10 ** 18); // some inital supply
  }

  function calcCostFromShares(uint256 _shares) public view returns (uint256 _cost)
  {
    return _shares.mul(totalReserve()).div(totalSupply());
  }

  function totalReserve() public view returns (uint256 _totalReserve)
  {
    return IERC20(reserveToken).balanceOf(address(this));
  }

  // accepts only JIMBO or JAMBO tokens
  function depositToken(address _token, uint256 _amount, uint256 _minShares) external nonReentrant
  {
    address _from = msg.sender;
    uint256 _minCost = calcCostFromShares(_minShares);
    if (_amount != 0) {
      IERC20(_token).safeTransferFrom(_from, address(this), _amount);
    }
    uint256 _cost = UniswapV2LiquidityPoolAbstraction._joinPool(reserveToken, _token, _amount, _minCost);
    uint256 _shares = _cost.mul(totalSupply()).div(totalReserve().sub(_cost));
    _mint(_from, _shares);
  }
}

library UniswapV2LiquidityPoolAbstraction
{
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  function _joinPool(address _pair, address _token, uint256 _amount, uint256 _minShares) internal returns (uint256 _shares)
  {
    if (_amount == 0) return 0;
    address _router = $.UniswapV2_ROUTER02;
    address _token0 = Pair(_pair).token0();
    address _token1 = Pair(_pair).token1();
    address _otherToken = _token == _token0 ? _token1 : _token0;
    (uint256 _reserve0, uint256 _reserve1,) = Pair(_pair).getReserves();
    uint256 _swapAmount = _calcSwapOutputFromInput(_token == _token0 ? _reserve0 : _reserve1, _amount);
    if (_swapAmount == 0) _swapAmount = _amount / 2;
    uint256 _leftAmount = _amount.sub(_swapAmount);
    _approveFunds(_token, _router, _amount);
    address[] memory _path = new address[](2);
    _path[0] = _token;
    _path[1] = _otherToken;
    uint256 _otherAmount = Router02(_router).swapExactTokensForTokens(_swapAmount, 1, _path, address(this), uint256(-1))[1];
    _approveFunds(_otherToken, _router, _otherAmount);
    (,,_shares) = Router02(_router).addLiquidity(_token, _otherToken, _leftAmount, _otherAmount, 1, 1, address(this), uint256(-1));
    require(_shares >= _minShares, "high slippage");
    return _shares;
  }

  function _calcSwapOutputFromInput(uint256 _reserveAmount, uint256 _inputAmount) private pure returns (uint256)
  {
    return Babylonian.sqrt(_reserveAmount.mul(_inputAmount.mul(3988000).add(_reserveAmount.mul(3988009)))).sub(_reserveAmount.mul(1997)) / 1994;
  }

  function _approveFunds(address _token, address _to, uint256 _amount) internal
  {
    uint256 _allowance = IERC20(_token).allowance(address(this), _to);
    if (_allowance > _amount) {
      IERC20(_token).safeDecreaseAllowance(_to, _allowance - _amount);
    }
    else
    if (_allowance < _amount) {
      IERC20(_token).safeIncreaseAllowance(_to, _amount - _allowance);
    }
  }
}

library $
{
  address constant UniswapV2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // ropsten
  address constant UniswapV2_ROUTER02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ropsten
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

interface PoolToken is IERC20
{
}

interface Pair is PoolToken
{
  function token0() external view returns (address _token0);
  function token1() external view returns (address _token1);
  function price0CumulativeLast() external view returns (uint256 _price0CumulativeLast);
  function price1CumulativeLast() external view returns (uint256 _price1CumulativeLast);
  function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
  function mint(address _to) external returns (uint256 _liquidity);
  function sync() external;
}
