import 'package:flutter/services.dart';
import 'package:gekitai/enums/gekitaiclient/gekitai.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class RMIClient {
  static final RMIClient _gRCPClient = RMIClient._internal();
  var channel = ClientChannel(
    'localhost',
    port: 3000,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
    ),
  );

  var gameStream = GekitaiClient(
    ClientChannel(
      'localhost',
      port: 3000,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    ),
  );

  RMIClient._internal();
  factory RMIClient() {
    return _gRCPClient;
  }

  sendMessage({required String messageText, required String clientId}) {
    final Message message = Message();
    message.isSent = true;
    message.text = messageText;
    message.sender = clientId;
    gameStream.sendMessage(message);
  }

  sendBoardMove({required Color playerColor, required int boardIndex}) {
    Map<int, int> playerMove = {playerColor.value: boardIndex};
  }

  giveUp({
    required Color playerColor,
  }) {}

  playerPieceMovedOut({
    required int piecePosition,
    required int colorValue,
  }) {
    final socketData = {piecePosition, colorValue};
  }

  pieceWasPushed({
    required int from,
    required int to,
  }) {
    final List<int> moviment = [from, to];
  }
}
