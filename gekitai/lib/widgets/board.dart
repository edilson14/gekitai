import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gekitai/enums/socke_types.dart';
import 'package:gekitai/services/socket.dart';

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

  @override
  void initState() {
    if (_client.socket.disconnected) _client.connect();
    super.initState();
    _handleComingMessage();
  }

  void _handlePlayerClick({required int tapedIndex}) {
    setState(
      () {
        _cells[tapedIndex] = playerColor!;
      },
    );
    _client.sendBoardMove(
      playerColor: playerColor!,
      boardIndex: tapedIndex,
    );
  }

  void _handleComingMessage() {
    _client.socket.on(
      'board-moviment',
      (data) {},
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
        // fazer algo com a cor selecionada
      }
    });
  }
}
