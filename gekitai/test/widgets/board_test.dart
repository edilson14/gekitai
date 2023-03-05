import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Testando o tabuleiro', (tester) async {
    const giveUpButton = TextButton(
      onPressed: null,
      child: Text('Desistir'),
    );

    await tester.pumpWidget(
      Container(
        child: giveUpButton,
      ),
    );
    // Testando o botão de desistir
    expect(find.byWidget(giveUpButton), findsOneWidget);
  });
}
