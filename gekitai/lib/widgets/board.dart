import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gekitai/enums/messages.dart';
import 'package:gekitai/services/socket.dart';
import 'package:gekitai/widgets/gekitai_pieces.dart';

class GekitaiBoard extends StatefulWidget {
  const GekitaiBoard({super.key});

  @override
  State<GekitaiBoard> createState() => _GekitaiBoardState();
}

class _GekitaiBoardState extends State<GekitaiBoard> {
  Color? playerColor;
  final Color _currentColor = Colors.grey;
  final List<Color> _cells = List<Color>.filled(36, Colors.grey);
  final SocketClient _client = SocketClient();
  List<GekitaiPiece> playersPieces = [];

  @override
  void initState() {
    if (_client.socket.disconnected) _client.connect();
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
      );
    }
  }

  void _handleComingMessage() {
    _client.socket.on(
      'board-moviment',
      (data) {
        List<dynamic> move =
            data.replaceAll('{', '').replaceAll('}', '').split(':');
        setState(() {
          _cells[int.parse(move[1])] = Color(int.parse(move[0]));
        });
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
    if (playersPieces.isEmpty) return false;
    if (_cells[tapedIndex].toString() != Colors.grey.toString()) {
      final SnackBar snackbar = SnackBar(
        content: Text(Messages.invalidMoviment),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return false;
    }

    return true;
  }
}
