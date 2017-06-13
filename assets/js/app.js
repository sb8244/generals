import 'phoenix_html';
import $ from 'jquery';
import socket from './socket';

const match = window.location.href.match(/\/games\/(.+)/)
if (match && window.gameAuthToken) {
  const id = match[1];
  console.log(id);
  joinGameChannel(id, window.gameAuthToken);
}

function joinGameChannel(id, authToken) {
  let channel = socket.channel(`game:${id}`, { token: authToken });
  channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp, channel);
      channel.push("full_state", { token: authToken }).receive("ok", (payload) => {
        console.log(payload);
      });
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
    });
  channel.onError(() => console.log("there was an error!"))
  channel.onClose(() => console.log("The channel closed"));
}
