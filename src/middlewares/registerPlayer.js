import * as actions from '../actions'

export default store => next => async action => {
  if(action.type !== actions.REGISTER) return next(action)
  if(action.completed) return next(action)

  const state = store.getState()
  if(
    !state.network.web3 ||
    !state.contracts.ethernaut ||
    !action.nickname ||
    !state.player.address ||
    !state.network.gasPrice
  ) return next(action)

  console.asyncInfo(`@good Registering player...`)

  let completed = await registerPlayer(
    state.contracts.ethernaut,
    action.nickname,
    state.player.address,
    state.network.gasPrice
  )
  if(completed) {
    console.info(`@good Hello, ` + action.nickname +`! You have been successfully registered!`)
  }
  else {
    console.error(`@bad Failed to register`)
  }

  action.completed = completed
  next(action)
}

async function registerPlayer(ethernaut, nickname, player, gasPrice) {
  return new Promise(async function(resolve) {
    const data = {from: player, gasPrice}
    // let estimate;
    // try {
    //   estimate = await ethernaut.submitLevelInstance.estimateGas(instanceAddress, data)
    //   data.gas = estimate;
    // } catch(e) {}
    const tx = await ethernaut.register(nickname);
    if (tx) {
      resolve(true);
    } else {
      resolve(false);
    }

    /*if(tx.logs.length === 0) resolve(false)
    else {
      if(tx.logs.length === 0) resolve(false)
      else {
        const log = tx.logs[0].args;
        const ethLevelAddress = log.level;
        const ethPlayer = log.player;
        if(player === ethPlayer && levelAddress === ethLevelAddress) {
          resolve(true)
        }
        else resolve(false)
      }
    } */
  });
}
