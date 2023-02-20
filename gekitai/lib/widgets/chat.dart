import 'package:flutter/material.dart';
import 'package:gekitai/services/socket.dart';

class ChatClient extends StatefulWidget {
  const ChatClient({super.key});

  @override
  State<ChatClient> createState() => _ChatClientState();
}

class _ChatClientState extends State<ChatClient> {
  final TextEditingController _textController = TextEditingController();
  final _client = SocketClient();
  List<String> mensagensRecebidas = [];

  @override
  void initState() {
    _client.connect();
    _handleReceviedMessages();
    super.initState();
  }

  void _handleReceviedMessages() {
    _client.socket.on(
      'message',
      (message) {
        setState(() {
          mensagensRecebidas.add(message);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensagensRecebidas.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(mensagensRecebidas[index]),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration:
                      const InputDecoration(hintText: 'Escreva uma mensagem!'),
                ),
              ),
              TextButton(
                onPressed: () {
                  _client.sendMessage(message: _textController.text);
                  _textController.clear();
                },
                child: Row(
                  children: const [
                    Icon(Icons.send),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
