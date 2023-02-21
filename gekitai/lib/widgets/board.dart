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

    _client.socket.on('piece-out-board', (data) {
      playersPieces.add(
        GekitaiPiece(
          color: playerColor!,
        ),
      );
      setState(() {});
    });
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
        )
      ],
    );
  }

  void _showColorPicker() async {
    showDialog(
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
      print('indece $tapedIndex');
      print(Env.getBorderIndexes(tapedIndex));
      print('perto da borda');
    } else {
      print('posição normal');
    }
  }

  handlePiceMoviment() {}
}
