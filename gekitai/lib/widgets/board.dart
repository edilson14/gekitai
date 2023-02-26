// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gekitai/enums/env.dart';
import 'package:gekitai/enums/messages.dart';
import 'package:gekitai/services/socket.dart';
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
  final SocketClient _client = SocketClient();
  List<GekitaiPiece> playersPieces = [];

  @override
  void initState() {
    super.initState();
    if (_client.socket.disconnected) {
      _client.connect();
    } else {
      final SnackBar snackbar = SnackBar(
        content: Text(Messages.connected),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
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
      );
      _pushPieces(tapedIndex: tapedIndex);
      _hanldeTurn();
      _checkWinner();
    }
  }

  void _handleComingMessage() {
    _client.socket.on(
      'board-moviment',
      (data) {
        if (_isNotFirstMoviment()) _hanldeTurn();
        List<dynamic> move =
            data.toString().replaceAll('{', '').replaceAll('}', '').split(':');
        setState(
          () {
            _cells[int.parse(move[1])] = Color(int.parse(move[0]));
          },
        );
      },
    );

    _client.socket.on(
      'piece-out-board',
      (data) {
        data = data.replaceAll('{', '').replaceAll('}', '').split(',');
        final int color = int.parse(data[1]);
        final int boardPosition = int.parse(data[0].toString().trim());
        _cells[boardPosition] = graycolor;
        if (color == playerColor?.value) {
          playersPieces.add(
            GekitaiPiece(
              color: playerColor!,
            ),
          );
        }
        setState(() {});
      },
    );

    _client.socket.on(
      'give-up',
      (data) {
        _showGivUpRequest();
      },
    );

    _client.socket.on(
      'acept-give-up',
      (data) {
        final SnackBar snackbar = SnackBar(
          content: Text(Messages.loseByGivingUp),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        _resetTheBoard();
      },
    );

    _client.socket.on(
      'piece-was-pushed',
      (data) {
        final List<String> positions =
            data.toString().replaceAll('[', '').replaceAll(']', '').split(',');
        int from = int.parse(positions[0]);
        int to = int.parse(positions[1]);

        final Color currentColor = _cells[from];
        _cells[from] = graycolor;
        _cells[to] = currentColor;
        setState(() {});
      },
    );
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
                  child: Center(
                    child: Text(
                      index.toString(),
                    ),
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
          TextButton(
            onPressed: () => _showColorPicker(),
            child: const Text(
              'Escolha uma cor',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          TextButton(
            onPressed: () {
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
            },
            child: const Text('Desistir'),
          ),
      ],
    );
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
    List<int> adjecens = handleAdjecenyIndexes(tapedIndex: tapedIndex);
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
    _client.socket.emit('acept-give-up', 1);
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
    // Check rows
    for (int row = 0; row < 6; row++) {
      int start = row * 6;
      for (int col = 0; col < 4; col++) {
        int pos = start + col;
        if (_cells[pos] == playerColor &&
            _cells[pos] == _cells[pos + 1] &&
            _cells[pos] == _cells[pos + 2]) {
          print(pos);
          return _cells[pos];
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
          print(pos);
          return _cells[pos];
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
          print(pos);
          return _cells[pos];
        }
      }
    }
    for (int row = 0; row < 4; row++) {
      for (int col = 2; col < 6; col++) {
        int pos = row * 6 + col;
        if (_cells[pos] == playerColor &&
            _cells[pos] == _cells[pos + 5] &&
            _cells[pos] == _cells[pos + 10]) {
          print(pos);
          return _cells[pos];
        }
      }
    }

    return 0; // No winner
  }

  List<int> handleAdjecenyIndexes({required int tapedIndex}) {
    List<int> adjacentIndexes = [];

    // verifica se a posição acima existe e adiciona ao array
    if (tapedIndex > 5) {
      adjacentIndexes.add(tapedIndex - 6);
      int pushedIndex = tapedIndex - 12;
      final Color currentColor = _cells[tapedIndex - 6];

      if (pushedIndex >= 0 && pushedIndex <= 35) {
        if (_cells[tapedIndex - 6] != graycolor &&
            _cells[tapedIndex - 12] == graycolor) {
          _cells[tapedIndex - 6] = graycolor;
          _cells[tapedIndex - 12] = currentColor;
          _client.pieceWasPushed(from: tapedIndex - 6, to: tapedIndex - 12);
        }
      } else {
        handlePieceOut(
          position: tapedIndex - 6,
          color: currentColor,
        );
      }

      // verifica se a posição à esquerda acima existe e adiciona ao array
      if (tapedIndex % 6 > 0) {
        adjacentIndexes.add(tapedIndex - 7);
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
              _client.pieceWasPushed(from: tapedIndex - 7, to: tapedIndex - 14);
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
        adjacentIndexes.add(tapedIndex - 5);

        int pushedIndex = tapedIndex - 10;

        if (pushedIndex >= 0 && pushedIndex <= 35) {
          if (Env.rightBorder.contains(tapedIndex - 5)) {
            handlePieceOut(position: tapedIndex - 5, color: currentColor);
          } else if (_cells[tapedIndex - 5] != graycolor &&
              _cells[tapedIndex - 10] == graycolor) {
            final Color currentColor = _cells[tapedIndex - 5];
            _cells[tapedIndex - 5] = graycolor;

            //  else {
            // Verifica se a posição para onde a peça deve ser empurrada está fora do tabuleiro
            _cells[tapedIndex - 10] = currentColor;
            _client.pieceWasPushed(from: tapedIndex - 5, to: tapedIndex - 10);
            // }
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
      adjacentIndexes.add(tapedIndex - 1);
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
            _client.pieceWasPushed(from: tapedIndex - 1, to: tapedIndex - 2);
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
      adjacentIndexes.add(tapedIndex + 1);
    }

    // verifica se a posição abaixo existe e adiciona ao array
    if (tapedIndex < 30) {
      adjacentIndexes.add(tapedIndex + 6);

      // verifica se a posição à esquerda abaixo existe e adiciona ao array
      if (tapedIndex % 6 > 0) {
        adjacentIndexes.add(tapedIndex + 5);
      }

      // verifica se a posição à direita abaixo existe e adiciona ao array
      if (tapedIndex % 6 < 5) {
        adjacentIndexes.add(tapedIndex + 7);
      }

      // return adjacentIndexes;
    }

    return adjacentIndexes;
  }
}
