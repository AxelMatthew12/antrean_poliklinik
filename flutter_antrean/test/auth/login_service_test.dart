import 'package:flutter_test/flutter_test.dart';
import 'package:antrean_poliklinik/features/auth/login_service.dart';

void main() {
  late LoginService loginService;

  setUp(() {
    loginService = LoginService();
  });

  group('Unit Test LoginService', () {
    test('UT_LOGIN_01 - Login dengan data valid', () {
      expect(
        () => loginService.validateLogin(
          'dimasnugrohopro22@email.com',
          'dimas123',
        ),
        returnsNormally,
      );
    });

    test('UT_LOGIN_02 - Email kosong', () {
      expect(
        () => loginService.validateLogin('', 'password123'),
        throwsException,
      );
    });

    test('UT_LOGIN_03 - Password kosong', () {
      expect(
        () => loginService.validateLogin('test@email.com', ''),
        throwsException,
      );
    });

    test('UT_LOGIN_04 - Password kurang dari 6 karakter', () {
      expect(
        () => loginService.validateLogin('test@email.com', '123'),
        throwsException,
      );
    });

    test('UT_LOGIN_05 - Format email tidak valid', () {
      expect(
        () => loginService.validateLogin('testemail.com', 'password123'),
        throwsException,
      );
    });
  });
}
