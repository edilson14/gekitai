import 'package:flutter/material.dart';
import 'package:gekitai/enums/mensagem.dart';
import 'package:gekitai/services/socket.dart';

class ChatClient extends StatefulWidget {
  const ChatClient({
    super.key,
  });

  @override
  State<ChatClient> createState() => _ChatClientState();
}

class _ChatClientState extends State<ChatClient> {
  final TextEditingController _textController = TextEditingController();
  final _client = SocketClient();
  final FocusNode _messageFocusNode = FocusNode();
  List<Mensagem> mensagens = [];

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
        setState(
          () {
            mensagens.add(
              Mensagem(
                mensagem: message,
                isSent: false,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE5DDD5),
            Color(0xFFB5B5B5),
          ],
        ),
        image: DecorationImage(
          image: NetworkImage(
            'https://www.hypeness.com.br/1/2022/03/317b91c0-edit_sombras_hiroshige_2.jpg',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black,
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mensagens.length,
              itemBuilder: (BuildContext context, int index) {
                return Wrap(
                  alignment: mensagens[index].isSent
                      ? WrapAlignment.end
                      : WrapAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: mensagens[index].isSent
                            ? Colors.blueAccent
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        mensagens[index].mensagem,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            height: 1.0,
            color: Colors.blueAccent,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onSubmitted: (value) {
                    _sendMessage();
                  },
                  controller: _textController,
                  focusNode: _messageFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Escreva uma mensagem!',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _sendMessage();
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

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      mensagens.add(
        Mensagem(mensagem: _textController.text),
      );
      _client.sendMessage(message: _textController.text);
      _textController.clear();
      _messageFocusNode.requestFocus();
      setState(() {});
    }
  }
}
