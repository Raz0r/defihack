pragma solidity ^0.6.0;

import './base/Level.sol';
import './MainChef.sol';


contract MainChefFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    KhinkalToken khinkal = new KhinkalToken();
    LPToken lptoken = new LPToken();

    lptoken.mint(_player, 1337);

    MainChef instance = new MainChef(khinkal, address(this), 31333333337, 0, 0, address(this));

    khinkal.mint(address(instance), 313337);
    khinkal.transferOwnership(address(instance));
    
    instance.addToken(IERC20(lptoken));

    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public returns (bool) {
    _player;
    return KhinkalToken(MainChef(_instance).khinkal()).balanceOf(_instance) == 0;
  }
}
