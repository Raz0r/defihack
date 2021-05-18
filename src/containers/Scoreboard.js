import React from 'react'
import {connect} from 'react-redux'
import {bindActionCreators} from 'redux'
import * as actions from '../actions'
import _ from 'lodash'

import '../styles/scoreboard.css'

class Scoreboard extends React.Component {

  constructor() {
    super()
    this.state = {
      highscores: []
    }
  }

  componentDidMount() {
    setInterval(() => this.props.collectStats(), 1000);
  }

  componentWillMount() {
    this.props.collectStats()
  }

  componentWillReceiveProps(nextProps) {

    // Receiving completed level logs?
    if(nextProps.createdInstances && nextProps.createdInstances.length > 0) {
      // console.log(`completedLevels`, nextProps.completedLevels)

      // Get array of game levels
      const levels = _.map(this.props.levels, 'deployedAddress')
      // console.log(`levels:`, levels)

      // Addresses we dont consider
      const ignoredAddresses = [
        "0xf46e63c5d3461bc50bc63933385f03a5c7b4358c" // ajsantander
      ]

      // Get unique players.
      const players = _.uniq(_.map(this.props.createdInstances, 'args.player'))

      let nicknames = {};
      for(let i = 0; i < this.props.createdInstances.length; i++) {
        if(this.props.createdInstances[i].args.nickname) {
          nicknames[this.props.createdInstances[i].args.player] = this.props.createdInstances[i].args.nickname;
        }
      }
      this.setState({
        nicknames
      })

      // Sweep players and collect info.
      let highscores = [];
      for(let i = 0; i < players.length; i++) {

        // Find level completion logs for this player
        const player = players[i]
        //debugger;
        if(ignoredAddresses.indexOf(player) !== -1) continue
        const logs = _.filter(nextProps.createdInstances, levelLog => {
          return levelLog.args.player === player
        })

        const completed = _.uniqBy(_.filter(nextProps.completedLevels, levelLog => {
          return levelLog.args.player === player
        }), 'args.level');

        // Process logs
        let completedCount = completed.length
        let earliestBlock = 9999999999999999999999999999999999999999999999
        let latestBlock = -9999999999999999999999999999999999999999999999
        let points = 0
        for(let i = 0; i < completed.length; i++) {
          const log = completed[i]
          if(log.blockNumber < earliestBlock) earliestBlock = log.blockNumber
          if(log.blockNumber > latestBlock) latestBlock = log.blockNumber
          const logLevel = log.args.level
          if(levels.indexOf(logLevel) > 0) { // FIRST LEVEL (TUTORIAL) IS IGNORED
            points++
          }
        }
        if(completed.length == 0) {
          earliestBlock = 0
          latestBlock = 0
        }

        // Push data
        //if(points >= levels.length - 1) {
          highscores.push({
            player,
            completedCount,
            earliestBlock,
            latestBlock,

            logs: logs
          })
        //}
      }

      // Sort data
      highscores = _.sortBy(highscores, ['latestBlock'])
      this.setState({
        highscores
      })
    }
  }

  filter(player) {
    if(this.state.playerFilter !== '' && player !== '') {
      if(player !== this.state.playerFilter) return false
    }
    return true
  }

  render() {
    return (
        <div  className="scoreboard">
          <h3 style={{fontSize: 35, textAlign: 'center'}}>https://www.defihack.xyz</h3>
          { this.state.highscores.length === 0 &&
          <div>
            <span>Processing level complete logs...</span>
            <br/>
            <br/>
            <small className="text-info">Please make sure that your metamask extension is (1) installed (2) unlocked and (3) pointed at the ropsten network. If you still dont see any results try refreshing or even disabling and re-enabling your metamask extension as a last resort.</small>
          </div>
          }
          { this.state.highscores.length > 0 &&
          <table className="table">
            <thead>
            <tr>
              <th>#</th>
              <th>Player</th>
              <th>Completed Tasks</th>
              <th>Latest Block</th>
            </tr>
            </thead>
            <tbody>
            {_.map(_.orderBy(this.state.highscores, ['completedCount', 'latestBlock'], ['desc', 'asc']), (item, idx) => {
              let style = {}
              if(idx < 3) style = {fontWeight: 'bold', fontSize: 26}
              return (
                <tr key={item.player}>
                  <td><small style={style}>{idx + 1}</small></td>
                  <td><small style={style}>{this.state.nicknames[item.player] ? this.state.nicknames[item.player] : item.player}</small></td>
                  <td><small style={style}>{item.completedCount}</small></td>
                  <td><small style={style}>{item.latestBlock}</small></td>
                </tr>
              )
            })}
            </tbody>
          </table>
          }
        </div>
    )
  }
}

function mapStateToProps(state) {
  return {
    createdInstances: state.stats.createdInstanceLogs,
    completedLevels: state.stats.completedLevelLogs,
    levels: state.gamedata.levels
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({
    collectStats: actions.collectStats
  }, dispatch)
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Scoreboard)
