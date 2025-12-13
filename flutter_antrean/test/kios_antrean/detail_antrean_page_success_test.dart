import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/DetailPoly.dart';
import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/listAppointment.dart';
import 'package:antrean_poliklinik/features/kios/controllers/kios_controller.dart';

// ---------- MOCK ----------
class MockAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockDB extends Mock implements FirebaseDatabase {}
class MockRef extends Mock implements DatabaseReference {}
class MockSnap extends Mock implements DataSnapshot {}
class MockKiosController extends Mock implements KiosController {}

class FakeRef extends Fake implements DatabaseReference {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeRef());
  });

  group('Unit Test DetailAntreanPage', () {
    testWidgets(
      'UT_QUEUE_02 - SUCCESS: status = selesai -> dialog sukses muncul',
      (tester) async {
        // ---------- AUTH ----------
        final auth = MockAuth();
        final user = MockUser();
        when(() => auth.currentUser).thenReturn(user);
        when(() => user.uid).thenReturn('uid_test');

        // ---------- DB ----------
        final db = MockDB();

        // loadRealData() mock
        final rootRef = MockRef();
        final loketRef = MockRef();
        final loketSnap = MockSnap();
        when(() => db.ref()).thenReturn(rootRef);
        when(() => rootRef.child('loket')).thenReturn(loketRef);
        when(() => loketRef.get()).thenAnswer((_) async => loketSnap);
        when(() => loketSnap.children).thenReturn(const <DataSnapshot>[]);

        // antrean_user status selesai
        final userRef = MockRef();
        final cekSnap = MockSnap();
        when(() => db.ref('antrean_user/uid_test')).thenReturn(userRef);
        when(() => userRef.get()).thenAnswer((_) async => cekSnap);
        when(() => cekSnap.exists).thenReturn(true);
        when(() => cekSnap.value).thenReturn({'status': 'selesai'});

        // simpan antrean
        final antreanRef = MockRef();
        when(() => db.ref('antrean/poli_1/1')).thenReturn(antreanRef);
        when(() => antreanRef.set(any())).thenAnswer((_) async {});
        when(() => userRef.set(any())).thenAnswer((_) async {});

        // controller ambil nomor
        final controller = MockKiosController();
        when(() => controller.ambilNomor('poli_1', 'uid_test'))
            .thenAnswer((_) async => '1');

        // ---------- POLI ----------
        final poli = PoliModel(
          id: 'poli_1',
          nama: 'Poli Umum',
          deskripsi: 'Test',
          gambar: 'https://example.com/x.png',
        );

        // ---------- PUMP ----------
        await tester.pumpWidget(
          MaterialApp(
            home: DetailAntreanPage(
              poli: poli,
              auth: auth,
              database: db,
              controller: controller,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ---------- ACTION ----------
        await tester.tap(find.text('Ambil Antrean Poli'));
        await tester.pumpAndSettle();

        // ---------- ASSERT ----------
        expect(find.text('Anda berhasil mendaftar antrean'), findsOneWidget);

        // opsional tapi bagus: memastikan dialog blokir tidak muncul
        expect(find.text('Tidak Bisa Mendaftar'), findsNothing);
      },
    );
  });
}
