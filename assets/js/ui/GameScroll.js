import { h, Component } from 'preact';

const EMPTY_DELTA_STATE = undefined;

export default class GameScroll extends Component {
  constructor() {
    super();

    this.onMouseDown = this.onMouseDown.bind(this);
    this.onMouseMove = this.onMouseMove.bind(this);
    this.onMouseUp = this.onMouseUp.bind(this);
    this.state = {};
    this.lastDelta = EMPTY_DELTA_STATE;
  }

  componentDidMount() {
    this.base.addEventListener('mousedown', this.onMouseDown)
  }

  componentWillUnmount() {
    this.base.removeEventListener('mousedown', this.onMouseDown);
    document.removeEventListener('mousemove', this.onMouseMove);
    document.removeEventListener('mouseup', this.onMouseUp);
  }

  onMouseDown(evt) {
    this.setState({ x: evt.clientX, y: evt.clientY });
    document.addEventListener('mousemove', this.onMouseMove);
    document.addEventListener('mouseup', this.onMouseUp);
  }

  onMouseMove(evt) {
    const { x, y, moving } = this.state;
    const verticalDelta = evt.clientY - y;
    const horizontalDelta = evt.clientX - x;

    if (moving || Math.abs(verticalDelta) > 25 || Math.abs(horizontalDelta) > 25) {
      if (!moving) {
        this.setState({ moving: true });
      }

      if (this.lastDelta) {
        const vertical = verticalDelta - this.lastDelta.vertical;
        const horizontal = horizontalDelta - this.lastDelta.horizontal;
        this.props.changeBoardPosition({ horizontal, vertical });
      }

      this.lastDelta = { vertical: verticalDelta, horizontal: horizontalDelta }
    }
  }

  onMouseUp(evt) {
    document.removeEventListener('mousemove', this.onMouseMove);
    document.removeEventListener('mouseup', this.onMouseUp);

    const { x, y } = this.state;
    const verticalDelta = Math.abs(evt.clientY - y);
    const horizontalDelta = Math.abs(evt.clientX - x);

    if (verticalDelta < 10 && horizontalDelta < 10) {
      const zIndex = this.base.style.zIndex;
      this.base.style.zIndex = 0;
      document.elementFromPoint(x, y).dispatchEvent(new Event('click', { bubbles: true, cancelable: true }));
      this.base.style.zIndex = zIndex;
    }

    this.setState({ x: undefined, y: undefined, moving: false });
    this.lastDelta = EMPTY_DELTA_STATE;
  }

  render() {
    return <div className="game-scroll" onMouseDown={this.mouseDown}></div>;
  }
}
