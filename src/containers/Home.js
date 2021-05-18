import React from 'react'
import {connect} from 'react-redux'
import {bindActionCreators} from 'redux'
import * as constants from '../constants'
import * as actions from '../actions'

class Home extends React.Component {

  constructor(props) {
    super(props);
    this.state = {'nickname': ''};
    this.handleChange = this.handleChange.bind(this);
  }

  navigateToFirstIncompleteLevel() {

    // Find first incomplete level
    let target = this.props.levels[0].deployedAddress
    for(let i = 0; i < this.props.levels.length; i++) {
      const level = this.props.levels[i]
      const completed = this.props.completedLevels[level.deployedAddress]
      if(!completed) {
        target = level.deployedAddress
        break
      }
    }

    // Navigate to first incomplete level
    this.props.router.push(`${constants.PATH_LEVEL_ROOT}${target}`)
  }

  handleChange(event) {
    this.setState({nickname: event.target.value});
    console.log(event.target.value);
  }

  render() {
    return (
      <div
        className="row"
        style={{
        paddingLeft: '40px',
        paddingRight: '40px',
      }}>

        <div className="col-sm-8">
        {/* INFO */}
        { this.props.player.nickname ?
        (<div><h1>Hello, {this.props.player.nickname}!</h1><form><button
          style={{marginTop: '10px'}}
          className="btn btn-primary"
          onClick={() => this.navigateToFirstIncompleteLevel()}
        >
          Play now!
        </button></form></div>)
        : (<form><input
          className="form-control"
          type="text"
          style={{marginTop: '10px'}}
          width="200px"
          onChange={this.handleChange}
          placeholder="Nickname"
          name="nickname"
        >
        </input><button
          type="button"
          style={{marginTop: '10px'}}
          className='btn btn-warning'
          onClick={evt => this.props.register(this.state.nickname)}
        >
          Register
        </button></form>)}
          {/* TITLE */}
          <img
            width="50%"
            src='../../imgs/defihack.png'/>
        </div>
      </div>
    )
  }
}

function mapStateToProps(state) {
  return {
    levels: state.gamedata.levels,
    completedLevels: state.player.completedLevels,
    player: state.player
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({
    register: actions.register
  }, dispatch);
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Home);
