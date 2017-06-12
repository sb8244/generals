import 'phoenix_html';
import $ from 'jquery';
import socket from './socket';

const match = window.location.href.match(/\/games\/(.+)/)
if (match) {
  const id = match[1];
  console.log(id);
  joinGameChannel(id);
}

function joinGameChannel(id) {
  let channel = socket.channel(`game:${id}`, {});
  channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp, channel);
      channel.push("full_state");
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
    });

  channel.on("full_state", (payload) => {
    console.log(payload);
  });
}
