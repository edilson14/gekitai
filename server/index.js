const http = require("http");
const socketIO = require("socket.io");

const server = http.createServer();
const io = socketIO(server);

const clients = [];

io.on("connection", (socket) => {
  if (clients.length < 2) clients.push(socket);
  console.log(`Total de clients ${clients.length}`);

  socket.on("message", (data) => {
    const otherClient = findClient(socket);
    if (otherClient !== undefined) {
      otherClient.emit("message", `${data}`);
      console.log(`Mensagem Enviada para ${otherClient.id} : ${data}`);
    }
  });

  socket.on("board-moviment", (data) => {
    console.log(`Jogada do ${socket.id}: ${data}`);
    const otherClient = findClient(socket);
    if (otherClient !== undefined) {
      otherClient.emit("board-moviment", `${data}`);
      console.log(`Jogada Enviada ${otherClient.id} : ${data}`);
    }
  });

  socket.on("disconnect", () => {
    const clientIndex = clients.findIndex(
      (_client) => _client.id === socket.id
    );
    clients.splice(clientIndex, 1);
    console.log(`Client desconectado: ${socket.id}`);
  });
});

server.listen(3000, () => {
  console.log("Server started on port 3000");
});

function findClient(socket) {
  return clients.find((_client) => _client.id !== socket.id);
}
