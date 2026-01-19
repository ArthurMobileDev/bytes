import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'string_codec.dart';

const byteBitCount = 8;

const int8ByteCount = 1;
const int16ByteCount = 2;
const int24ByteCount = 3;
const int32ByteCount = 4;
const int64ByteCount = 8;

const doubleInt16Dec8ByteCount = int16ByteCount + int8ByteCount;

const macByteCount = 6;
const ipv4ByteCount = 4;
const dateByteCount = 3;
const timeByteCount = 3;

const hexDecimalBase = 16;
const decimalBase = 10;

extension UtilsByteListExtension on Uint8List {
  String toHexString({String joinSeparator = ""}) {
    return map((byte) => byte.toRadixString(hexDecimalBase).padLeft(2, '0'))
        .join(joinSeparator)
        .toUpperCase();
  }
}

extension UtilsIntegerExtension on int {
  List<bool> toBits({int? bitsCount, int? bytesCount}) {
    bitsCount ??= (bytesCount ?? int8ByteCount) * byteBitCount;
    final buffer = <bool>[];
    for (int i = 0; i < bitsCount; i++) {
      final position = Endian.host == Endian.little ? bitsCount - i - 1 : i;
      buffer.add((this >> position) & 0x1 == 0x1);
    }
    return buffer;
  }
}

extension UtilsStringExtension on String {
  Digest toMd5([Encoding encoder = utf8]) =>
      md5.convert(codec.encode(this, encoder));
}
