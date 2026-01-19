import 'dart:convert';
import 'dart:typed_data';

import 'bytes_utils.dart' as Bytes;
import 'string_codec.dart';

class ByteArrayReader {
  final Uint8List _data;
  final ByteData _buffer;
  int _cursor = 0;

  ByteArrayReader(this._data) : _buffer = ByteData.sublistView(_data);

  bool _insufficientSize(int bytesCount) => _data.length < _cursor + bytesCount;

  int? _bytesToInt(Uint8List? bytes) {
    if (bytes == null) return null;
    int result = 0;
    for (int byte in bytes) {
      result = (result << Bytes.byteBitCount) | byte;
    }
    return result;
  }

  bool? readBoolean() {
    if (_insufficientSize(Bytes.int8ByteCount)) return null;
    final value = _buffer.getUint8(_cursor) != 0;
    _cursor += Bytes.int8ByteCount;
    return value;
  }

  int? readByte() {
    if (_insufficientSize(Bytes.int8ByteCount)) return null;
    final value = _buffer.getUint8(_cursor);
    _cursor += Bytes.int8ByteCount;
    return value;
  }

  Uint8List? readBytes(int size) {
    if (_insufficientSize(size) || size < 1) return null;
    final value = Uint8List.sublistView(_data, _cursor, _cursor + size);
    _cursor += size;
    return value;
  }

  int? read16Int() {
    if (_insufficientSize(Bytes.int16ByteCount)) return null;
    final value = _buffer.getUint16(_cursor, Endian.big);
    _cursor += Bytes.int16ByteCount;
    return value;
  }

  int? read24Int() {
    if (_insufficientSize(Bytes.int24ByteCount)) return null;
    return _bytesToInt(readBytes(Bytes.int24ByteCount));
  }

  int? read32Int() {
    if (_insufficientSize(Bytes.int32ByteCount)) return null;
    final value = _buffer.getUint32(_cursor, Endian.big);
    _cursor += Bytes.int32ByteCount;
    return value;
  }

  int? read64Int() {
    if (_insufficientSize(Bytes.int64ByteCount)) return null;
    final value = _buffer.getUint64(_cursor, Endian.big);
    _cursor += Bytes.int64ByteCount;
    return value;
  }

  int? readInteger(int bytesCount) {
    if (bytesCount > Bytes.int64ByteCount ||
        bytesCount < 1 ||
        _insufficientSize(bytesCount)) return null;
    return _bytesToInt(readBytes(bytesCount));
  }

  double? readDouble() {
    if (_insufficientSize(Bytes.doubleInt16Dec8ByteCount)) return null;
    final integer = _buffer.getUint16(_cursor, Endian.big);
    final decimal = _buffer.getUint8(_cursor + Bytes.int16ByteCount);
    _cursor += Bytes.doubleInt16Dec8ByteCount;
    return integer + (decimal / 100);
  }

  String? readString({
    int? size,
    int sizeBytesCount = 1,
    Encoding decoder = utf8,
  }) {
    size ??= readInteger(sizeBytesCount);
    if (size == null || _insufficientSize(size)) return null;
    final bytes = readBytes(size);
    return bytes != null ? codec.decode(bytes, decoder) : null;
  }

  String? readHexByteString() {
    final byte = readByte();
    if (byte == null) return null;
    return byte
        .toRadixString(Bytes.hexDecimalBase)
        .padLeft(2, '0')
        .toUpperCase();
  }

  String? readMacAddress({String joinSeparator = '-'}) {
    final bytes = readBytes(Bytes.macByteCount);
    if (bytes == null) return null;
    return bytes.toHexString(joinSeparator: joinSeparator);
  }

  String? readIPv4Address() {
    final bytes = readBytes(Bytes.ipv4ByteCount);
    if (bytes == null) return null;
    return bytes.join(".");
  }

  DateTime? readDate() {
    if (_insufficientSize(Bytes.dateByteCount)) return null;
    final day = _buffer.getUint8(_cursor++);
    final month = _buffer.getUint8(_cursor++);
    final year = _buffer.getUint8(_cursor++);
    return DateTime(year + 2000, month != 0 ? month : 1, day != 0 ? day : 1);
  }

  DateTime? readTime() {
    if (_insufficientSize(Bytes.dateByteCount)) return null;
    final hour = _buffer.getUint8(_cursor++);
    final minutes = _buffer.getUint8(_cursor++);
    final seconds = _buffer.getUint8(_cursor++);
    return DateTime(2000, 1, 1, hour, minutes, seconds);
  }

  DateTime? readDateTime() {
    if (_insufficientSize(Bytes.dateByteCount + Bytes.timeByteCount))
      return null;
    final day = _buffer.getUint8(_cursor++);
    final month = _buffer.getUint8(_cursor++);
    final year = _buffer.getUint8(_cursor++);
    final hour = _buffer.getUint8(_cursor++);
    final minutes = _buffer.getUint8(_cursor++);
    final seconds = _buffer.getUint8(_cursor++);
    return DateTime(
      year + 2000,
      month != 0 ? month : 1,
      day != 0 ? day : 1,
      hour,
      minutes,
      seconds,
    );
  }

  bool testByte(int byte) => readByte() == (byte & 0xff);

  void jump(int count) => _cursor += count;

  bool get notEnd => _data.length > _cursor;

  Uint8List get data => _data;

  int get remainingCount => _data.length - _cursor;

  Uint8List? get remaining =>
      _data.length > _cursor ? Uint8List.sublistView(_data, _cursor) : null;
}

extension UtilsByteArrayExtension on Uint8List {
  ByteArrayReader get reader => ByteArrayReader(this);
}
