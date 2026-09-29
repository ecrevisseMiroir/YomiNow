import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/sha256.dart';

String _sha256(String text) => sha256Hex(utf8.encode(text));

void main() {
  // Expected values from Python's hashlib; the first three are the FIPS
  // 180-4 examples.
  test('hashes the standard examples', () {
    expect(
      _sha256(''),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      _sha256('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    expect(
      _sha256('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'),
      '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
    );
  });

  test('pads correctly around block boundaries', () {
    final expected = {
      55: '9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318',
      56: 'b35439a4ac6f0948b6d6f9e3c6af0f5f590ce20f1bde7090ef7970686ec6738a',
      63: '7d3e74a05d7db15bce4ad9ec0658ea98e3f06eeecf16b4c6fff2da457ddc2f34',
      64: 'ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb',
      65: '635361c48bb9eab14198e76ea8ab7f1a41685d6ad62aa9146d301d4f17eb0ae0',
      119: '31eba51c313a5c08226adf18d4a359cfdfd8d2e816b13f4af952f7ea6584dcfb',
      120: '2f3d335432c70b580af0e8e1b3674a7c020d683aa5f73aaaedfdc55af904c21c',
      128: '6836cf13bac400e9105071cd6af47084dfacad4e5e302c94bfed24e013afb73e',
    };
    expect({
      for (final length in expected.keys) length: _sha256('a' * length),
    }, expected);
  });

  test('hashes multi-byte text and arbitrary bytes', () {
    expect(
      _sha256('日本語のテキスト'),
      'd4192d3b01dfa9f5b08388f13e5c7492e3cfdc5611bf8c77784dc97523f03efb',
    );
    expect(
      sha256Hex([for (var i = 0; i < 256; i++) i]),
      '40aff2e9d2d8922e47afd4648e6967497158785fbd1da870e7110266bf944880',
    );
  });

  test('hashes a million bytes', () {
    expect(
      _sha256('a' * 1000000),
      'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0',
    );
  });
}
