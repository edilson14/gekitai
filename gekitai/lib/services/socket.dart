import 'package:flutter/services.dart';
import 'package:gekitai/enums/sockt_events.dart';
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
    socket.emit(SocketEvents.message.event, message);
  }

  sendBoardMove({required Color playerColor, required int boardIndex}) {
    Map<int, int> playerMove = {playerColor.value: boardIndex};
    socket.emit(SocketEvents.boardMoviment.event, playerMove.toString());
  }

  giveUp({
    required Color playerColor,
  }) {
    socket.emit(SocketEvents.giveUp.event, playerColor.toString());
  }

  playerPieceMovedOut({
    required int piecePosition,
    required int colorValue,
  }) {
    final socketData = {piecePosition, colorValue};
    socket.emit(SocketEvents.pieceOutBoard.event, socketData.toString());
  }

  pieceWasPushed({
    required int from,
    required int to,
  }) {
    final List<int> moviment = [from, to];
    socket.emit(SocketEvents.pieceWasPushed.event, moviment.toString());
  }
}
