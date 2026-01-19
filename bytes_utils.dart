import 'dart:typed_data';

const kByteBitCount = 8;

const kInt8ByteCount  = 1;
const kInt16ByteCount = 2;
const kInt24ByteCount = 3;
const kInt32ByteCount = 4;
const kInt64ByteCount = 8;

const kDoubleInt16Dec8ByteCount = kInt16ByteCount + kInt8ByteCount;

const kMacByteCount  = 6;
const kIPv4ByteCount = 4;
const kIPv6ByteCount = 16;
const kDateByteCount = 3;
const kTimeByteCount = 3;

const hexDecimalBase = 16;
const decimalBase    = 10;

extension UtilsByteListExtension on Uint8List {
  String toHexString({String divider = ""}) {
    final buffer = StringBuffer();
    for (final byte in this) {
      if (buffer.isNotEmpty) buffer.write(divider);
      buffer.write(byte.toRadixString(hexDecimalBase).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase();
  }
}

extension UtilsIntegerExtension on int {
  List<bool> toBits({int? bitsCount, int? bytesCount}) {
    bitsCount ??= (bytesCount ?? kInt8ByteCount) * kByteBitCount;
    final buffer = <bool>[];
    for (int i = 0; i < bitsCount; i++) {
      final position = Endian.host == Endian.little ? bitsCount - i - 1 : i;
      buffer.add((this >> position) & 0x1 == 0x1);
    }
    return buffer;
  }
}
