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
    }
  }

  void _handleComingMessage() {
    _client.socket.on(
      'board-moviment',
      (data) {
        if (_isNotFirstMoviment()) _hanldeTurn();
        List<dynamic> move =
            data.replaceAll('{', '').replaceAll('}', '').split(':');
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
        if (color == playerColor!.value) {
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
    if (Env.isOnBorder(tapedIndex)) {
      print('ok está na borda');
    } else if (Env.isNearFromBorder(tapedIndex)) {
      final List<int> borders = Env.getBorderIndexes(tapedIndex);
      for (var element in borders) {
        handlePiceOut(position: element);
      }
    } else {
      print('posição normal');
    }
  }

  handlePiceOut({required int position}) {
    if (_cells[position].value == playerColor!.value) {
      playersPieces.add(
        GekitaiPiece(
          color: playerColor,
        ),
      );
    }
    _client.playerPieceMovedOut(
      piecePosition: position,
      colorValue: _cells[position].value,
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
    _client.socket.emit('acept-give-up');
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
}
