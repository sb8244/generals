// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix";

function connectSocket(token) {
  let socket = new Socket("/socket", {params: {token: token}});
  socket.connect();
  return socket;
}

export default connectSocket;
