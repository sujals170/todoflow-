import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('valid email addresses pass validation', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('firstname.lastname@domain.co'), isNull);
      expect(Validators.validateEmail('user+tag@domain.org'), isNull);
    });

    test('empty or whitespace email fails validation', () {
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail('   '), 'Email address is required');
    });

    test('malformed email fails validation', () {
      expect(Validators.validateEmail('not-an-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('user@'), 'Please enter a valid email address');
      expect(Validators.validateEmail('@domain.com'), 'Please enter a valid email address');
      expect(Validators.validateEmail('user@domain'), 'Please enter a valid email address');
    });
  });

  group('Validators - Password', () {
    test('valid password (>= 6 chars) passes validation', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('strongPassword!'), isNull);
    });

    test('empty password fails validation', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword(''), 'Password is required');
    });

    test('short password (< 6 chars) fails validation', () {
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters long');
      expect(Validators.validatePassword('abc'), 'Password must be at least 6 characters long');
    });
  });

  group('Validators - Confirm Password', () {
    test('matching passwords pass validation', () {
      expect(Validators.validateConfirmPassword('secret123', 'secret123'), isNull);
    });

    test('mismatched passwords fail validation', () {
      expect(
        Validators.validateConfirmPassword('different', 'secret123'),
        'Passwords do not match',
      );
    });

    test('empty confirm password fails validation', () {
      expect(
        Validators.validateConfirmPassword('', 'secret123'),
        'Please confirm your password',
      );
    });
  });

  group('Validators - Full Name', () {
    test('valid name passes validation', () {
      expect(Validators.validateFullName('Jane Doe'), isNull);
      expect(Validators.validateFullName('Jo'), isNull);
    });

    test('empty or short name fails validation', () {
      expect(Validators.validateFullName(''), 'Full name is required');
      expect(Validators.validateFullName('A'), 'Full name must be at least 2 characters');
    });
  });
}
