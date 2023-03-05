class SocketEvents {
  final String event;

  SocketEvents._(this.event);

  static final SocketEvents boardMoviment = SocketEvents._('board-moviment');
  static final SocketEvents message = SocketEvents._('message');
  static final SocketEvents pieceOutBoard = SocketEvents._('piece-out-board');
  static final SocketEvents pieceWasPushed = SocketEvents._('piece-was-pushed');
  static final SocketEvents giveUp = SocketEvents._('give-up');
  static final SocketEvents aceptGiveUp = SocketEvents._('acept-give-up');
}
