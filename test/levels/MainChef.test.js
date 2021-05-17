const Factory = artifacts.require('./levels/MainChefFactory.sol')
const Instance = artifacts.require('./levels/MainChef.sol')
const Exploit = artifacts.require('./attacks/MainChefAttack.sol')
const Ethernaut = artifacts.require('./Ethernaut.sol')

const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers')
const utils = require('../utils/TestUtils')


contract('MainChef', function(accounts) {

  let ethernaut
  let level
  let owner = accounts[1]
  let player = accounts[0]

  before(async function() {
    ethernaut = await Ethernaut.new();
    level = await Factory.new()
    await ethernaut.registerLevel(level.address)
  });

  it('should allow the player to solve the level', async function() {

    instance = await utils.createLevelInstance(
      ethernaut, level.address, player, Instance,
      {from: player}
    )

    assert(instance);

    /*const password = await instance.password.call()
    await instance.authenticate(password)
    const clear = await instance.getCleared()
    assert.equal(clear, true)

    // Factory check
    const ethCompleted = await utils.submitLevelInstance(
      ethernaut,
      level.address,
      instance.address,
      player
    )*/

    //assert.equal(ethCompleted, true)
  });

  it('deploy exploit', async function() {
    exp = await Exploit.new(instance.address, {from: player})
    await network.provider.send('evm_mine')
  });

  it('prepare exploit', async function() {
    await exp.prepare({from: player})
  });

  it('pwn pwn', async function() {
    await network.provider.send('evm_mine')
    await exp.hack({from: player})
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
