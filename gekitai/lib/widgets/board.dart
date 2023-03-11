import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gekitai/enums/env.dart';
import 'package:gekitai/enums/gekitaiclient/gekitai.pbgrpc.dart';
import 'package:gekitai/enums/messages.dart';
import 'package:gekitai/services/socket.dart';
import 'package:gekitai/widgets/action_button.dart';
import 'package:gekitai/widgets/gekitai_pieces.dart';

const Color graycolor = Colors.grey;

class GekitaiBoard extends StatefulWidget {
  const GekitaiBoard({super.key});

  @override
  State<GekitaiBoard> createState() => _GekitaiBoardState();
}

class _GekitaiBoardState extends State<GekitaiBoard> {
  bool canPlay = true;
  Color? playerColor;
  final Color _currentColor = graycolor;
  final List<Color> _cells = List<Color>.filled(36, graycolor);
  final RMIClient _client = RMIClient();
  List<GekitaiPiece> playersPieces = [];
  final clientId = Random().nextInt(10).toString();

  @override
  void initState() {
    super.initState();
    _handleComingMessage();
  }

  void _handlePlayerClick({required int tapedIndex}) {
    if (_isValidMoviment(tapedIndex: tapedIndex)) {
      setState(
        () {
          _cells[tapedIndex] = playerColor!;
        },
      );
      playersPieces.removeLast();
      _client.sendBoardMove(
        playerColor: playerColor!,
        boardIndex: tapedIndex,
        clientId: clientId,
      );
      _pushPieces(tapedIndex: tapedIndex);
      _hanldeTurn();
      _checkWinner();
    }
  }

  void _handleComingMessage() {
    _handleMoviment();
    _handlePushes();
    // _client.socket.on(
    //   SocketEvents.pieceOutBoard.event,
    //   (data) {
    //     data =
    //         data.toString().replaceAll('{', '').replaceAll('}', '').split(',');
    //     final int color = int.parse(data[1]);
    //     final int boardPosition = int.parse(data[0].toString().trim());
    //     _cells[boardPosition] = graycolor;
    //     if (color == playerColor?.value) {
    //       playersPieces.add(
    //         GekitaiPiece(
    //           color: playerColor!,
    //         ),
    //       );
    //     }
    //     setState(() {});
    //   },
    // );

    // _client.socket.on(
    //   SocketEvents.giveUp.event,
    //   (data) {
    //     _showGivUpRequest();
    //   },
    // );

    // _client.socket.on(
    //   SocketEvents.aceptGiveUp.event,
    //   (data) {
    //     final SnackBar snackbar = SnackBar(
    //       content: Text(Messages.loseByGivingUp),
    //       backgroundColor: Colors.red,
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
    //     _resetTheBoard();
    //   },
    // );
  }

  void _showColorPicker() async {
    showDialog<Color>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  playerColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                playerColor = null;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(playerColor);
              },
            ),
          ],
        );
      },
    ).then((selectedColor) {
      if (selectedColor != null) {
        playerColor = selectedColor;
        setState(
          () {
            playersPieces = List.generate(
              8,
              (_) => GekitaiPiece(
                color: selectedColor,
              ),
            );
          },
        );
      }
    });
  }

  void _showGivUpRequest() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Desistencia!'),
          content: SingleChildScrollView(
            child: Column(
              children: const [
                Text('O adversário quer desistir do jogo!'),
                Text('Caso aceite , você será o  vencedor!')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text('Não Aceitar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Aceitar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _aceptPlayerGivenUp();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVictory() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vencedor!'),
          content: SingleChildScrollView(
            child: Column(
              children: const [
                Text('Parabéns, venceu o jogo!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _aceptPlayerGivenUp();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValidMoviment({required int tapedIndex}) {
    if (playerColor == null) {
      final SnackBar snackbar = SnackBar(
        content: Text(Messages.selectAColor),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return false;
    }
    if (!canPlay) {
      final SnackBar snackbar = SnackBar(
        content: Text(
          Messages.waitYourTurn,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return false;
    }
    if (playersPieces.isEmpty) {
      return false;
    }
    if (_cells[tapedIndex].toString() != graycolor.toString()) {
      final SnackBar snackbar = SnackBar(
        content: Text(Messages.invalidMoviment),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return false;
    }

    return true;
  }

  void _hanldeTurn() {
    setState(() {
      canPlay = !canPlay;
    });
  }

  bool _isNotFirstMoviment() {
    return _cells.any((cell) => cell.value != graycolor.value);
  }

  void _pushPieces({required int tapedIndex}) {
    handleAdjecenyIndexes(tapedIndex: tapedIndex);
  }

  handlePieceOut({required int position, required Color color}) {
    if (playerColor?.value == color.value) {
      playersPieces.add(
        GekitaiPiece(
          color: color,
        ),
      );
    }
    _client.playerPieceMovedOut(
      piecePosition: position,
      colorValue: color.value,
    );
    _cells[position] = graycolor;
    setState(() {});
  }

  _aceptPlayerGivenUp() {
    Navigator.of(context).pop();
    final SnackBar snackbar = SnackBar(
      content: Text(Messages.winTheGame),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    // _client.socket.emit(SocketEvents.aceptGiveUp.event, 1);
    _resetTheBoard();
  }

  void _resetTheBoard() {
    for (int index = 0; index < _cells.length; index++) {
      _cells[index] = graycolor;
    }
    playersPieces = [];
    playersPieces = List.generate(
      8,
      (_) => GekitaiPiece(
        color: playerColor,
      ),
    );
    setState(() {});
  }

  _checkWinner() {
    // verificar se o jogador ainda possui peças

    if (playersPieces.isEmpty) _showVictory();

    // Check rows
    for (int row = 0; row < 6; row++) {
      int start = row * 6;
      for (int col = 0; col < 4; col++) {
        int pos = start + col;
        if (_cells[pos] == playerColor &&
            _cells[pos] == _cells[pos + 1] &&
            _cells[pos] == _cells[pos + 2]) {
          _showVictory();
        }
      }
    }

    // Check columns
    for (int col = 0; col < 6; col++) {
      for (int row = 0; row < 4; row++) {
        int pos = row * 6 + col;
        if (_cells[pos] == playerColor &&
            _cells[pos] == _cells[pos + 6] &&
            _cells[pos] == _cells[pos + 12]) {
          _showVictory();
        }
      }
    }

    // Check diagonals
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        int pos = row * 6 + col;
        if (_cells[pos] == playerColor &&
            _cells[pos] == _cells[pos + 7] &&
            _cells[pos] == _cells[pos + 14]) {
          _showVictory();
        }
      }
    }
    for (int row = 0; row < 4; row++) {
      for (int col = 2; col < 6; col++) {
        int pos = row * 6 + col;
        if (_cells[pos] == playerColor &&
            _cells[pos] == _cells[pos + 5] &&
            _cells[pos] == _cells[pos + 10]) {
          _showVictory();
        }
      }
    }
  }

  handleAdjecenyIndexes({required int tapedIndex}) {
    // verifica se a posição acima existe e adiciona ao array
    if (tapedIndex > 5) {
      int pushedIndex = tapedIndex - 12;
      final Color currentColor = _cells[tapedIndex - 6];

      if (pushedIndex >= 0 && pushedIndex <= 35) {
        if (_cells[tapedIndex - 6] != graycolor &&
            _cells[tapedIndex - 12] == graycolor) {
          _cells[tapedIndex - 6] = graycolor;
          _cells[tapedIndex - 12] = currentColor;
          _client.pieceWasPushed(
              clientId: clientId, from: tapedIndex - 6, to: tapedIndex - 12);
        }
      } else {
        handlePieceOut(
          position: tapedIndex - 6,
          color: currentColor,
        );
      }

      // verifica se a posição à esquerda acima existe e adiciona ao array
      if (tapedIndex % 6 > 0) {
        int pushedIndex = tapedIndex - 14;

        if (pushedIndex >= 0 && pushedIndex <= 35) {
          if (_cells[tapedIndex - 7] != graycolor &&
              _cells[tapedIndex - 14] == graycolor) {
            final Color currentColor = _cells[tapedIndex - 7];
            _cells[tapedIndex - 7] = graycolor;

            if (Env.isOnBorder(tapedIndex - 7)) {
              handlePieceOut(position: tapedIndex - 7, color: currentColor);
            } else {
              // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
              _cells[tapedIndex - 14] = currentColor;
              _client.pieceWasPushed(
                  clientId: clientId,
                  from: tapedIndex - 7,
                  to: tapedIndex - 14);
            }
          }
        } else {
          handlePieceOut(
            position: tapedIndex - 7,
            color: _cells[tapedIndex - 7],
          );
        }
      }

      // verifica se a posição à direita acima existe e adiciona ao array
      if (tapedIndex % 6 < 5) {
        int pushedIndex = tapedIndex - 10;

        if (pushedIndex >= 0 && pushedIndex <= 35) {
          if (Env.rightBorder.contains(tapedIndex - 5)) {
            handlePieceOut(position: tapedIndex - 5, color: currentColor);
          } else if (_cells[tapedIndex - 5] != graycolor &&
              _cells[tapedIndex - 10] == graycolor) {
            final Color currentColor = _cells[tapedIndex - 5];
            _cells[tapedIndex - 5] = graycolor;

            // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
            _cells[tapedIndex - 10] = currentColor;
            _client.pieceWasPushed(
                clientId: clientId, from: tapedIndex - 5, to: tapedIndex - 10);
          }
        } else {
          handlePieceOut(
            position: tapedIndex - 5,
            color: _cells[tapedIndex - 5],
          );
        }
      }
    }

    // verifica se a posição à esquerda existe e adiciona ao array
    if (tapedIndex % 6 > 0) {
      int pushedIndex = tapedIndex - 2;

      if (pushedIndex >= 0 && pushedIndex <= 35) {
        if (_cells[tapedIndex - 1] != graycolor &&
            _cells[tapedIndex - 2] == graycolor) {
          final Color currentColor = _cells[tapedIndex - 1];
          _cells[tapedIndex - 1] = graycolor;

          if (Env.leftBorder.contains(tapedIndex - 1)) {
            handlePieceOut(position: tapedIndex - 1, color: currentColor);
          } else {
            // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
            _cells[tapedIndex - 2] = currentColor;
            _client.pieceWasPushed(
                clientId: clientId, from: tapedIndex - 1, to: tapedIndex - 2);
          }
        }
      } else {
        handlePieceOut(
          position: tapedIndex - 1,
          color: _cells[tapedIndex - 1],
        );
      }
    }

    // verifica se a posição à direita existe e adiciona ao array
    if (tapedIndex % 6 < 5) {
      int pushedIndex = tapedIndex + 2;

      if (pushedIndex >= 0 && pushedIndex <= 35) {
        if (_cells[tapedIndex + 1] != graycolor &&
            _cells[tapedIndex + 2] == graycolor) {
          final Color currentColor = _cells[tapedIndex + 1];
          _cells[tapedIndex + 1] = graycolor;

          if (Env.rightBorder.contains(tapedIndex + 1)) {
            handlePieceOut(position: tapedIndex + 1, color: currentColor);
          } else {
            // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
            _cells[tapedIndex + 2] = currentColor;
            _client.pieceWasPushed(
                clientId: clientId, from: tapedIndex + 1, to: tapedIndex + 2);
          }
        }
      } else {
        handlePieceOut(
          position: tapedIndex + 1,
          color: _cells[tapedIndex + 1],
        );
      }
    }

    // verifica se a posição abaixo existe e adiciona ao array
    if (tapedIndex < 30) {
      int pushedIndex = tapedIndex + 12;
      final Color currentColor = _cells[tapedIndex + 6];

      if (pushedIndex >= 0 && pushedIndex <= 35) {
        if (_cells[tapedIndex + 6] != graycolor &&
            _cells[tapedIndex + 12] == graycolor) {
          _cells[tapedIndex + 6] = graycolor;
          _cells[tapedIndex + 12] = currentColor;
          _client.pieceWasPushed(
              clientId: clientId, from: tapedIndex + 6, to: tapedIndex + 12);
        }
      } else {
        handlePieceOut(
          position: tapedIndex + 6,
          color: currentColor,
        );
      }

      // verifica se a posição à esquerda abaixo existe e adiciona ao array
      if (tapedIndex % 6 > 0) {
        int pushedIndex = tapedIndex + 10;

        if (pushedIndex >= 0 && pushedIndex <= 35) {
          if (Env.rightBorder.contains(tapedIndex + 5)) {
            handlePieceOut(position: tapedIndex + 5, color: currentColor);
          } else if (_cells[tapedIndex + 5] != graycolor &&
              _cells[tapedIndex + 10] == graycolor) {
            final Color currentColor = _cells[tapedIndex + 5];
            _cells[tapedIndex + 5] = graycolor;

            // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
            _cells[tapedIndex + 10] = currentColor;
            _client.pieceWasPushed(
                clientId: clientId, from: tapedIndex + 5, to: tapedIndex + 10);
          }
        } else {
          handlePieceOut(
            position: tapedIndex + 5,
            color: _cells[tapedIndex + 5],
          );
        }
      }

      // verifica se a posição à direita abaixo existe e adiciona ao array
      if (tapedIndex % 6 < 5) {
        int pushedIndex = tapedIndex + 14;

        if (pushedIndex >= 0 && pushedIndex <= 35) {
          if (_cells[tapedIndex + 7] != graycolor &&
              _cells[tapedIndex + 14] == graycolor) {
            final Color currentColor = _cells[tapedIndex + 7];
            _cells[tapedIndex + 7] = graycolor;

            if (Env.rightBorder.contains(tapedIndex + 7)) {
              handlePieceOut(position: tapedIndex + 7, color: currentColor);
            } else {
              // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
              _cells[tapedIndex + 14] = currentColor;
              _client.pieceWasPushed(
                  clientId: clientId,
                  from: tapedIndex + 7,
                  to: tapedIndex + 14);
            }
          }
        } else {
          handlePieceOut(
            position: tapedIndex + 7,
            color: _cells[tapedIndex + 7],
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          width: 400,
          child: GridView.count(
            crossAxisCount: 6,
            children: List.generate(_cells.length, (index) {
              return GestureDetector(
                onTap: () => _handlePlayerClick(tapedIndex: index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    color: _cells[index],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CherryBlossomPainter(),
                        ),
                      ),
                      Center(
                        child: Text(
                          index.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (playerColor == null)
          ActionButton(
            callBack: _showColorPicker,
            textColor: Colors.red,
            label: 'Escolha uma cor',
          ),
        Row(
          children: [
            ...playersPieces.map((e) => e).toList(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        if (playerColor != null)
          ActionButton(
            callBack: _handleGivUp,
            textColor: Colors.blueAccent,
            label: 'Desistir',
          )
      ],
    );
  }

  _handleGivUp() {
    final SnackBar snackbar = SnackBar(
      content: Text(
        Messages.givUpRequest,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.yellowAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    _client.giveUp(playerColor: playerColor!);
  }

  _handleMoviment() {
    _client.gameStream.receiveMoviment(Empty()).listen((moviment) {
      if (moviment.sender != clientId) {
        if (_isNotFirstMoviment()) _hanldeTurn();
        setState(() {
          _cells[moviment.index] = Color(moviment.color.toInt());
        });
      }
    });
  }

  _handlePushes() {
    _client.gameStream.recievePiecePushed(Empty()).listen((push) {
      if (push.sender != clientId) {
        final Color currentColor = _cells[push.from];
        _cells[push.from] = graycolor;
        _cells[push.to] = currentColor;
        setState(() {});
      }
    });
  }
}
