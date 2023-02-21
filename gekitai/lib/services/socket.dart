import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  static final SocketClient _socketClient = SocketClient._internal();
  io.Socket socket = io.io('http://localhost:3000', {
    'autoConnect': false,
    'transports': ['websocket'],
  });

  SocketClient._internal();
  factory SocketClient() {
    return _socketClient;
  }

  connect() {
    socket.connect();
    socket.onConnectError((data) {});
  }

  sendMessage({required String message}) {
    socket.emit('message', message);
  }

  sendBoardMove({required Color playerColor, required int boardIndex}) {
    Map<int, int> playerMove = {playerColor.value: boardIndex};
    socket.emit('board-moviment', playerMove.toString());
  }

  giveUp({
    required Color playerColor,
  }) {
    socket.emit('give-up', playerColor.toString());
  }

  playerPieceMovedOut() {
    socket.emit(
      'piece-out-board',
    );
  }
}
