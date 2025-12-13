import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/DetailPoly.dart';
import 'package:antrean_poliklinik/features/kios/Poly/ListPoly/listAppointment.dart';

// ---- MOCKS ----
class MockAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockDB extends Mock implements FirebaseDatabase {}
class MockRef extends Mock implements DatabaseReference {}
class MockSnap extends Mock implements DataSnapshot {}

class FakeRef extends Fake implements DatabaseReference {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeRef());
  });

  group('Unit Test DetailAntreanPage', () {
    testWidgets(
      'UT_QUEUE_01 - BLOCK: Memblokir antrean bila status poli != selesai',
      (tester) async {
        // ---------- AUTH ----------
        final auth = MockAuth();
        final user = MockUser();
        when(() => auth.currentUser).thenReturn(user);
        when(() => user.uid).thenReturn('uid_test');

        // ---------- DB ----------
        final db = MockDB();

        // mock loadRealData() -> db.ref().child("loket").get()
        final rootRef = MockRef();
        final loketRef = MockRef();
        final loketSnap = MockSnap();
        when(() => db.ref()).thenReturn(rootRef);
        when(() => rootRef.child('loket')).thenReturn(loketRef);
        when(() => loketRef.get()).thenAnswer((_) async => loketSnap);
        when(() => loketSnap.children).thenReturn(const <DataSnapshot>[]);

        // mock antrean_user/uid_test -> status menunggu (BLOCK)
        final userRef = MockRef();
        final cekSnap = MockSnap();
        when(() => db.ref('antrean_user/uid_test')).thenReturn(userRef);
        when(() => userRef.get()).thenAnswer((_) async => cekSnap);
        when(() => cekSnap.exists).thenReturn(true);
        when(() => cekSnap.value).thenReturn({'status': 'menunggu'});

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
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ---------- ACTION ----------
        await tester.tap(find.text('Ambil Antrean Poli'));
        await tester.pumpAndSettle();

        // ---------- ASSERT ----------
        expect(find.text('Tidak Bisa Mendaftar'), findsOneWidget);
        expect(find.text('Anda masih memiliki antrean aktif.'), findsOneWidget);
      },
    );
  });
}
