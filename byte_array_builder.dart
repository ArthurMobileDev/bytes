import 'dart:convert';
import 'dart:typed_data';

//import 'package:crypto/crypto.dart';

import 'bytes_utils.dart' as Bytes;
import 'string_codec.dart';

class ByteArrayBuilder {
  final _buffer = BytesBuilder();

  ByteArrayBuilder();

  ByteArrayBuilder.fromArray(Uint8List array) {
    _buffer.add(array);
  }

  int get length => _buffer.length;

  Uint8List _uint16ToBytes(int value) {
    final buffer = ByteData(Bytes.int16ByteCount);
    buffer.setUint16(0, value, Endian.big);
    return buffer.buffer.asUint8List();
  }

  Uint8List _uint32ToBytes(int value) {
    final buffer = ByteData(Bytes.int32ByteCount);
    buffer.setUint32(0, value, Endian.big);
    return buffer.buffer.asUint8List();
  }

  Uint8List _uint64ToBytes(int value) {
    final buffer = ByteData(Bytes.int64ByteCount);
    buffer.setUint64(0, value, Endian.big);
    return buffer.buffer.asUint8List();
  }

  Uint8List _genericUintToBytes(int value, int bytesCount) {
    final buffer = ByteData(Bytes.int64ByteCount);
    buffer.setUint64(0, value, Endian.big);
    return buffer.buffer.asUint8List().sublist(
      Bytes.int64ByteCount - bytesCount,
    );
  }

  Uint8List _intToBytes(int value, int bytesCount) {
    return switch (bytesCount) {
      > Bytes.int64ByteCount || < 0 => Uint8List(0),
      Bytes.int8ByteCount => Uint8List(1)..[0] = value & 0xFF,
      Bytes.int16ByteCount => _uint16ToBytes(value),
      Bytes.int32ByteCount => _uint32ToBytes(value),
      Bytes.int64ByteCount => _uint64ToBytes(value),
      _ => _genericUintToBytes(value, bytesCount),
    };
  }

  ByteArrayBuilder addBoolean(bool boolean) {
    _buffer.addByte(boolean ? 1 : 0);
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
    _buffer.add(_uint16ToBytes(short));
    return this;
  }

  ByteArrayBuilder add24Int(int integer) {
    _buffer.add(_genericUintToBytes(integer, 3));
    return this;
  }

  ByteArrayBuilder add32Int(int integer) {
    _buffer.add(_uint32ToBytes(integer));
    return this;
  }

  ByteArrayBuilder add64Int(int integer) {
    _buffer.add(_uint64ToBytes(integer));
    return this;
  }

  ByteArrayBuilder addInteger(int integer, {required int bytesCount}) {
    _buffer.add(_intToBytes(integer, bytesCount));
    return this;
  }

  ByteArrayBuilder addDouble(double value) {
    final data = ByteData(Bytes.doubleInt16Dec8ByteCount);
    data.setUint16(0, value.truncate(), Endian.big);
    data.setUint8(Bytes.int16ByteCount, (value % 1 * 100).round());
    _buffer.add(data.buffer.asUint8List());
    return this;
  }

  ByteArrayBuilder addString(
    String? string, {
    int sizeBytesCount = 1,
    Encoding encoder = utf8,
  }) {
    if (string == null || string.isEmpty) {
      addInteger(0, bytesCount: sizeBytesCount);
      return this;
    }
    var bytes = codec.encode(string, encoder);
    final maxSize = sizeBytesCount > 1
        ? 1 << (Bytes.byteBitCount * sizeBytesCount)
        : 256;
    if (bytes.length < maxSize) {
      addInteger(bytes.length, bytesCount: sizeBytesCount);
      _buffer.add(bytes);
    }
    return this;
  }

  // ByteArrayBuilder addMD5(String string,
  //     {bool hasCount = true, Encoding encoder = utf8}) {
  //   if (string.isEmpty) return this;
  //   var strMd5 = md5.convert(string.codeUnits).toString().toUpperCase();
  //   return addString(
  //       strMd5, sizeBytesCount: hasCount ? 1 : 0, encoder: encoder);
  // }

  ByteArrayBuilder addMacAddress(String macAddress) {
    final strMac = macAddress.replaceAll(":", "").replaceAll("-", "");
    if (strMac.length < Bytes.macByteCount * 2) return this;
    int? macNumber = int.tryParse(strMac, radix: Bytes.hexDecimalBase);
    if (macNumber != null) {
      _buffer.add(_genericUintToBytes(macNumber, Bytes.macByteCount));
    }
    return this;
  }

  ByteArrayBuilder addIPv4Address(String ipAddress) {
    final ipSplit = ipAddress.split(".");
    if (ipSplit.length != Bytes.ipv4ByteCount) return this;
    final tempBuffer = Uint8List(Bytes.ipv4ByteCount);
    for (int i = 0; i < ipSplit.length; i++) {
      final part = int.tryParse(ipSplit[i], radix: Bytes.decimalBase);
      if (part == null || part < 0 || part > 255) return this;
      tempBuffer[i] = part;
    }
    _buffer.add(tempBuffer);
    return this;
  }

  ByteArrayBuilder addDate(DateTime? dateTime) {
    Uint8List tempBuffer = Uint8List(Bytes.dateByteCount);
    if (dateTime != null && dateTime.year >= 2000) {
      tempBuffer[0] = dateTime.day;
      tempBuffer[1] = dateTime.month;
      tempBuffer[2] = dateTime.year - 2000;
    }
    _buffer.add(tempBuffer);
    return this;
  }

  ByteArrayBuilder addTime(DateTime? dateTime) {
    Uint8List tempBuffer = Uint8List(Bytes.dateByteCount);
    if (dateTime != null) {
      tempBuffer[0] = dateTime.hour;
      tempBuffer[1] = dateTime.minute;
      tempBuffer[2] = dateTime.second;
    }
    _buffer.add(tempBuffer);
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
}
