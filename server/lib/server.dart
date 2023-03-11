import 'package:grpc/grpc.dart';
import 'package:server/gekitaiclient/gekitai.pbgrpc.dart';

class GekitaiServices extends GekitaiServiceBase {
  final _messages = <Message>[];

  @override
  Future<Empty> sendMessage(ServiceCall call, Message request) async {
    _messages.add(request);
    return Empty();
  }

  @override
  Stream<Message> receiveMessages(ServiceCall call, Empty request) async* {
    final seenMessages = <Message>{};
    final sender = request.sender;
    while (true) {
      for (final message in _messages) {
        if (message.sender != sender && !seenMessages.contains(message)) {
          seenMessages.add(message);
          yield message;
        }
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}

Future<void> main(List<String> args) async {
  final Server server = Server([GekitaiServices()]);
  await server.serve(port: 3000);
  print('Server listening on port ${server.port}...');
}
