import 'package:fixnum/fixnum.dart';

import 'package:flutter/services.dart';
import 'package:gekitai/enums/gekitaiclient/gekitai.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class GRCPClien {
  static final GRCPClien _gRCPClient = GRCPClien._internal();

  var gameStream = GekitaiClient(
    ClientChannel(
      'localhost',
      port: 3000,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    ),
  );

  GRCPClien._internal();
  factory GRCPClien() {
    return _gRCPClient;
  }

  sendMessage({required String messageText, required String clientId}) {
    final Message message = Message();
    message.isSent = true;
    message.text = messageText;
    message.sender = clientId;
    gameStream.sendMessage(message);
  }

  sendBoardMove({
    required Color playerColor,
    required int boardIndex,
    required String clientId,
  }) {
    dynamic color = playerColor.value.toUnsigned(64);
    final Moviment moviment = Moviment(
      color: Int64(color),
      index: boardIndex,
      sender: clientId,
    );
    gameStream.sendMoviment(moviment);
  }

  giveUp({
    required String clientId,
  }) {
    gameStream.sendGiveUP(
      Empty(sender: clientId),
    );
  }

  playerPieceMovedOut({
    required int piecePosition,
    required int colorValue,
    required String clientID,
  }) {
    PieceOutBoard pieceOutBoard = PieceOutBoard(
      boardPosition: piecePosition,
      color: Int64(colorValue),
      sender: clientID,
    );
    gameStream.sendPieceOutBoard(pieceOutBoard);
  }

  pieceWasPushed({
    required int from,
    required int to,
    required String clientId,
  }) {
    final PieceWasPushed push =
        PieceWasPushed(from: from, to: to, sender: clientId);
    gameStream.sendPiecePushed(push);
  }
}
