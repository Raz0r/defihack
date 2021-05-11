pragma solidity ^0.6.0;

import './base/Level.sol';
import './P2PSwapper.sol';

contract P2PSwapperFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    address payable p2pweth = address(new P2P_WETH());
    P2PSwapper instance = new P2PSwapper(p2pweth);

    IP2P_WETH(p2pweth).deposit{value: msg.value - 313337}();
    IP2P_WETH(p2pweth).approve(address(instance), 123);
    instance.createDeal{value: 313337}(p2pweth, 1, p2pweth, 1000000000000);

    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public returns (bool) {
    _player;
    return IP2P_WETH(P2PSwapper(_instance).p2pweth()).balanceOf(_instance) == 0;
  }
}
