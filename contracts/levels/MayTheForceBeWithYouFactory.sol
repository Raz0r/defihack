pragma solidity ^0.6.0;

import './base/Level.sol';
import './MayTheForceBeWithYou.sol';
import './base/MiniMe.sol';

contract MayTheForceBeWithYouFactory is Level {
  MiniMeToken public yoda;
  MayTheForceBeWithYou public instance;

  function createInstance(address _player) override public payable returns (address) {
    _player;
    MiniMeToken yoda = new MiniMeToken("YODA Token", 18, "YODA");
    MayTheForceBeWithYou instance = new MayTheForceBeWithYou(address(yoda));
    return address(instance);
  }

  function validateInstance(address payable _instance, address) override public returns (bool) {
    MayTheForceBeWithYou instance = MayTheForceBeWithYou(_instance);
    if (yoda.balanceOf(_instance) == 0) {
      return true;
    }
    return false;
  }
}
