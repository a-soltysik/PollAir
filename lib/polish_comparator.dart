import 'dart:math';

class PolishComparator {
  static final Map<String, int> map = {
    "A": 1,
    "a": 2,
    "Ą": 3,
    "ą": 4,
    "B": 5,
    "b": 6,
    "C": 7,
    "c": 8,
    "Ć": 9,
    "ć": 10,
    "D": 11,
    "d": 12,
    "E": 13,
    "e": 14,
    "Ę": 15,
    "ę": 16,
    "F": 17,
    "f": 18,
    "G": 19,
    "g": 20,
    "H": 21,
    "h": 22,
    "I": 23,
    "i": 24,
    "J": 25,
    "j": 26,
    "K": 27,
    "k": 28,
    "L": 29,
    "l": 30,
    "Ł": 31,
    "ł": 32,
    "M": 33,
    "m": 34,
    "N": 35,
    "n": 36,
    "Ń": 37,
    "ń": 38,
    "O": 39,
    "o": 40,
    "Ó": 41,
    "ó": 42,
    "P": 43,
    "p": 44,
    "R": 45,
    "r": 46,
    "S": 47,
    "s": 48,
    "Ś": 49,
    "ś": 50,
    "T": 51,
    "t": 52,
    "U": 53,
    "u": 54,
    "V": 55,
    "v": 56,
    "W": 57,
    "w": 58,
    "X": 59,
    "x": 60,
    "Y": 61,
    "y": 62,
    "Z": 63,
    "z": 64,
    "Ż": 65,
    "ż": 66,
    "Ź": 67,
    "ź": 68,
  };

  int compare(String a, String b) {
    final minLength = min(a.length, b.length);
    for (var i = 0; i < minLength; ++i) {
      final charA = a[i];
      final charB = b[i];

      final charAValue = map[charA];
      final charBValue = map[charB];
      if ([charAValue, charBValue].contains(null)) {
        continue;
      }
      if (charAValue! > charBValue!) {
        return 1;
      } else if (charAValue < charBValue) {
        return -1;
      }
    }
    return a.length - b.length;
  }
}
