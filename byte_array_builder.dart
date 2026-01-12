import 'dart:typed_data';

//import 'package:crypto/crypto.dart';

import 'bytes_utils.dart';
import 'string_codec.dart';

export 'string_codec.dart' show Encoding;

const _kIPv6BlocksCount = 8;

class ByteArrayBuilder {

  final _buffer = BytesBuilder();
  int get length => _buffer.length;

  ByteArrayBuilder addBoolean(bool boolean) {
    _buffer.addByte(boolean? 1: 0);
    return this;
  }

  ByteArrayBuilder addByte(int byte) {
    _buffer.addByte(byte);
    return this;
  }

  ByteArrayBuilder addByteList(Uint8List bytes) {
    _buffer.add(bytes);
    return this;
  }

  ByteArrayBuilder add16Int(int short) {
    final data = ByteData(kInt16ByteCount);
    data.setInt16(0, short, Endian.big);
    _buffer.add(data.buffer.asUint8List());
    return this;
  }

  ByteArrayBuilder add24Int(int integer){
    _buffer.add(integer.toBytes(3));
    return this;
  }

  ByteArrayBuilder add32Int(int integer) {
    final data = ByteData(kInt32ByteCount);
    data.setInt32(0, integer, Endian.big);
    _buffer.add(data.buffer.asUint8List());
    return this;
  }

  ByteArrayBuilder add64Int(int integer) {
    final data = ByteData(kInt64ByteCount);
    data.setInt64(0, integer, Endian.big);
    _buffer.add(data.buffer.asUint8List());
    return this;
  }

  ByteArrayBuilder addInteger(int integer, {required int bytesCount}) {
    _buffer.add(integer.toBytes(bytesCount));
    return this;
  }

  ByteArrayBuilder addDouble(double value) {
    final data = ByteData(kDoubleInt16Dec8ByteCount);
    data.setUint16(0, value.truncate(), Endian.big);
    data.setUint8(kInt16ByteCount, (value % 1 * 100).round());
    _buffer.add(data.buffer.asUint8List());
    return this;
  }

  ByteArrayBuilder addString(String? string, {int sizeBytesCount = 1, Encoding encoder = Encoding.utf8}) {
    if (string == null || string.isEmpty) {
      addInteger(0, bytesCount: sizeBytesCount);
      return this;
    }
    var bytes = codec.encode(string, encoder);
    addInteger(bytes.length, bytesCount: sizeBytesCount);
    _buffer.add(bytes);
    return this;
  }

  // ByteArrayBuilder addMD5(String string, {bool hasCount = true, Encoding encoder = Encoding.utf8}) {
  //   if (string.isEmpty) return this;
  //   var strMd5 = md5.convert(string.codeUnits).toString().toUpperCase();
  //   return addString(strMd5, sizeBytesCount: hasCount? 1 : 0, encoder: encoder);
  // }

  ByteArrayBuilder addMacAddress(String macAddress) {
    final strMac = macAddress.replaceAll(":", "").replaceAll("-", "");
    if (strMac.length < kMacByteCount * 2) return this;
    try{
      int macNumber = int.parse(strMac, radix: hexDecimal);
      _buffer.add(macNumber.toBytes(kMacByteCount));
    } catch(_) {}
    return this;
  }

  ByteArrayBuilder addIPv4Address(String ipAddress) {
    final ipSplit = ipAddress.split(".");
    if (ipSplit.length != kIPv4ByteCount) return this;
    try {
      final tempBuffer = Uint8List(kIPv4ByteCount);
      for (int i = 0; i < ipSplit.length; i++) {
        tempBuffer[i] = int.parse(ipSplit[i]);
      }
      _buffer.add(tempBuffer);
    } catch(_) {}
    return this;
  }

  ByteArrayBuilder addIPv6Address(String ipAddress) {
    final ipSplit = ipAddress.split(":");
    try {
      var cursor = 0;
      bool jumpMissingBlocks = false;
      final tempBuffer = ByteData(kIPv6ByteCount);
      for (final part in ipSplit) {

        if (part.isEmpty) {
          if (!jumpMissingBlocks) {
            jumpMissingBlocks = true;
            cursor += (_kIPv6BlocksCount - ipSplit.where((p) => p.isNotEmpty).length) * 2;
          }
          continue;
        }

        tempBuffer.setUint16(cursor, int.parse(part, radix: hexDecimal), Endian.big);
        cursor += kInt16ByteCount;
      }
      _buffer.add(tempBuffer.buffer.asUint8List());
    } catch(_) {}
    return this;
  }

  ByteArrayBuilder addDate(DateTime? dateTime) {
    _buffer.add(dateTime != null && dateTime.year >= 2000
        ? [dateTime.day, dateTime.month, dateTime.year - 2000]
        : [0, 0, 0]);
    return this;
  }

  ByteArrayBuilder addTime(DateTime? dateTime) {
    _buffer.add(dateTime != null
        ? [dateTime.hour, dateTime.minute, dateTime.second]
        : [0, 0, 0]);
    return this;
  }

  ByteArrayBuilder addDateTime(DateTime? dateTime) {
    addDate(dateTime);
    addTime(dateTime);
    return this;
  }

  ByteArrayBuilder merge(ByteArrayBuilder builder) {
    if (builder.length > 0) _buffer.add(builder.build());
    return this;
  }

  void clear() => _buffer.clear();
  Uint8List build() => _buffer.toBytes();

  static ByteArrayBuilder fromArray(Uint8List array) => ByteArrayBuilder().._buffer.add(array);
}

extension UtilsIntToByteExtension on int{
  Uint8List toBytes([int? bytesCount]) {
    bytesCount ??= kInt8ByteCount;
    final buffer = Uint8List(bytesCount);
    for (int i = 0; i < bytesCount; i++)
    {
      final position = Endian.host == Endian.little
          ? bytesCount - i - 1 : i;
      buffer[i] = (this >> (kByteBitCount * position)) & 0xff;
    }
    return buffer;
  }

  List<bool> toBits({int? bitsCount, int? bytesCount}) {
    bitsCount ??= (bytesCount ?? kInt8ByteCount) * kByteBitCount;
    final buffer = <bool>[];
    for (int i = 0; i < bitsCount; i++) {
      final position = Endian.host == Endian.little
          ? bitsCount - i - 1 : i;
      buffer.add((this >> position) & 0x1 == 0x1);
    }
    return buffer;
  }
}

