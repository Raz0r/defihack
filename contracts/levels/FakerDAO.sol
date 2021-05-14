pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";

contract FakerDAO is ERC20, ReentrancyGuard {

    using SafeMath for uint256;

    address public immutable pair;

    constructor (address _pair) public ERC20("Lambo", "LAMBO") {
        _setupDecimals(0);
        pair = _pair;
        _mint(address(this), 1000 * 10 ** 18);
    }


    function borrow(uint256 _amount) public nonReentrant {
        uint256 _balance = Pair(pair).balanceOf(msg.sender);
        console.log("_balance:", _balance);

        uint256 _tokenPrice = price();
        console.log("_tokenPrice:", _tokenPrice);
        uint256 _depositRequired = _amount.mul(_tokenPrice);
        console.log("_depositRequired:", _depositRequired);

        require(_balance >= _depositRequired, "Not enough collateral");

        // we get LP tokens
        Pair(pair).transferFrom(msg.sender, address(this), _depositRequired);
        // you get a lambo
        transfer(msg.sender, _amount);
    }

    function price() public view returns (uint256) {
        address token0 = Pair(pair).token0();
        address token1 = Pair(pair).token1();
        uint256 _reserve0 = IERC20(token0).balanceOf(pair);
        uint256 _reserve1 = IERC20(token1).balanceOf(pair);
        return (_reserve0 * _reserve1) / Pair(pair).totalSupply();
    }
}

library $
{
	address constant UniswapV2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // ropsten
	address constant UniswapV2_ROUTER02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ropsten
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
