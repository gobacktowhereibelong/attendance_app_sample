import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/screens/home/widgets/logout_dialog.dart';

void main() {
  testWidgets(
    'LogoutDialog tampil dan tombol Batal menutupnya',
    (WidgetTester tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    dialogResult = await LogoutDialog.show(context);
                  },
                  child: const Text('Buka Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Dialog belum muncul
      expect(find.text('Keluar dari akun?'), findsNothing);

      // Ketuk tombol untuk membuka dialog
      await tester.tap(find.text('Buka Dialog'));
      await tester.pumpAndSettle();

      // Dialog muncul
      expect(find.text('Keluar dari akun?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Ketuk tombol Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog tertutup
      expect(find.text('Keluar dari akun?'), findsNothing);
      expect(dialogResult, false);
    },
  );
}
