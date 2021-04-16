import * as actions from '../actions'

let queuedAction;

export default store => next => action => {
  if(action.type !== actions.COLLECT_STATS) {
    if(queuedAction && action.type === actions.LOAD_ETHERNAUT_CONTRACT && action.contract) {
      // console.log(`RETRIGGER`)
      next(action)
      store.dispatch(queuedAction)
      queuedAction = null
      return
    }
    return next(action)
  }

  const state = store.getState()
  // console.log(`TRY COLLECT_STATS >`, state.contracts.ethernaut !== undefined)
  if(
    !state.network.web3 ||
    !state.contracts.ethernaut
  ) {
    if(!queuedAction) queuedAction = action
    return
  }

  const query = {
    filter: {},
    range: {
      fromBlock: 0,
      toBlock: state.network.blockNum || 'latest'
    }
  }
  // console.log(`query`, query)

  // Get Level created
  if(!action.createdInstanceLogs) {
    state.contracts.ethernaut.getPastEvents('LevelInstanceCreatedLog', {
      fromBlock: 0,
      toBlock: 'latest'
    }, function(error, events){
    }).then(function(events){
      action.createdInstanceLogs = events;
      store.dispatch(action);
    });
  }

  // Level completed
  if(!action.completedLevelLogs) {
    state.contracts.ethernaut.getPastEvents('LevelCompletedLog', {
      fromBlock: 0,
      toBlock: 'latest'
    }, function(error, events){
    }).then(function(events){
      action.completedLevelLogs = events;
      store.dispatch(action);
    });
  }

  next(action)
}
