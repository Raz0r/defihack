pragma solidity ^0.6.0;

import './base/Level.sol';
import './MayTheForceBeWithYou.sol';

contract MayTheForceBeWithYouFactory is Level {
  MiniMeToken public yoda;

  function createInstance(address _player) override public payable returns (address) {
    _player;
    yoda = new MiniMeToken("YODA Token", 18, "YODA");
    MayTheForceBeWithYou instance = new MayTheForceBeWithYou(address(yoda));
    yoda.mint(address(instance), 69420);
    return address(instance);
  }

  function validateInstance(address payable _instance, address) override public returns (bool) {
    if (yoda.balanceOf(_instance) == 0) {
      return true;
    }
    return false;
  }
}
