import 'dart:math';

String generateRandomNumberString(int length) {
  Random random = Random();
  String number = '';
  for (int i = 0; i < length; i++) {
    number += random.nextInt(10).toString(); // Menghasilkan angka 0-9
  }
  return number;
}
