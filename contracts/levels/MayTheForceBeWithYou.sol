pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MayTheForceBeWithYou is ERC20, ReentrancyGuard {
    using SafeMath for uint256;
    IERC20 public yoda;

    event Withdraw(address indexed beneficiary, uint256 amount);
    event Deposit(address indexed beneficiary, uint256 amount);

    // Define the Yoda token contract
    constructor(address _underlying) ERC20("xYODA", "xYODA") public {
        yoda = IERC20(_underlying);
    }

    function deposit(uint256 amount) external nonReentrant {
        // Gets the amount of YODA locked in the contract
        uint256 totalYoda = yoda.balanceOf(address(this));
        // Gets the amount of xYODA in existence
        uint256 totalShares = totalSupply();
        // If no xYODA exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalYoda == 0) {
            _mint(msg.sender, amount);
        }
        // Calculate and mint the amount of xYODA the YODA is worth. The ratio will change overtime, as xYODA is burned/minted and YODA deposited + gained from fees / withdrawn.
        else {
            uint256 what = amount.mul(totalShares).div(totalYoda);
            _mint(msg.sender, what);
        }
        // Lock the YODA in the contract
        yoda.transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 numberOfShares) external nonReentrant {
        // Gets the amount of xYODA in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of YODA the xYODA is worth
        uint256 what =
            numberOfShares.mul(yoda.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, numberOfShares);
        yoda.transfer(msg.sender, what);

        emit Withdraw(msg.sender, what);
    }
}
