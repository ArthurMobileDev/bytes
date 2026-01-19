import 'dart:typed_data';

import 'bytes_utils.dart';
import 'string_codec.dart';

export 'string_codec.dart' show Encoding;

class ByteArrayReader {
  final Uint8List _data;
  final ByteData _buffer;
  var _cursor = 0;

  ByteArrayReader(this._data) : _buffer = ByteData.sublistView(_data);

  bool _verifySize(int bytesCount) => _data.length < _cursor + bytesCount;

  int? _bytesToInt(Uint8List? bytes) {
    if (bytes == null) return null;
    int result = 0;
    for (int byte in bytes) {
      result = (result << kByteBitCount) | byte;
    }
    return result;
  }

  bool? readBoolean() {
    if (_verifySize(kInt8ByteCount)) return null;
    final value = _buffer.getUint8(_cursor) != 0;
    _cursor += kInt8ByteCount;
    return value;
  }

  int? readByte() {
    if (_verifySize(kInt8ByteCount)) return null;
    final value = _buffer.getUint8(_cursor);
    _cursor += kInt8ByteCount;
    return value;
  }

  Uint8List? readBytes(int size) {
    if (_verifySize(size) || size < 1) return null;
    final value = Uint8List.sublistView(_data, _cursor, _cursor + size);
    _cursor += size;
    return value;
  }

  int? read16Int() {
    if (_verifySize(kInt16ByteCount)) return null;
    final value = _buffer.getUint16(_cursor, Endian.big);
    _cursor += kInt16ByteCount;
    return value;
  }

  int? read24Int() {
    if (_verifySize(kInt24ByteCount)) return null;
    return _bytesToInt(readBytes(kInt24ByteCount));
  }

  int? read32Int() {
    if (_verifySize(kInt32ByteCount)) return null;
    final value = _buffer.getUint32(_cursor, Endian.big);
    _cursor += kInt32ByteCount;
    return value;
  }

  int? read64Int() {
    if (_verifySize(kInt64ByteCount)) return null;
    final value = _buffer.getUint64(_cursor, Endian.big);
    _cursor += kInt64ByteCount;
    return value;
  }

  int? readInteger(int bytesCount) {
    if (bytesCount > kInt64ByteCount ||
        bytesCount < 1 ||
        _verifySize(bytesCount))
      return null;
    return _bytesToInt(readBytes(bytesCount));
  }

  double? readDouble() {
    if (_verifySize(kDoubleInt16Dec8ByteCount)) return null;
    final integer = _buffer.getUint16(_cursor, Endian.big);
    final decimal = _buffer.getUint8(_cursor + kInt16ByteCount);
    _cursor += kDoubleInt16Dec8ByteCount;
    return integer + (decimal / 100);
  }

  String? readString({
    int? size,
    int? sizeBytesCount = 1,
    Encoding decoder = Encoding.utf8,
  }) {
    if (size == null) {
      if (sizeBytesCount == null) return null;
      size = readInteger(sizeBytesCount);
    }
    if (size == null || _verifySize(size)) return null;
    final bytes = readBytes(size);
    return bytes != null ? codec.decode(bytes, decoder) : null;
  }

  String? readHexByteString() {
    if (_verifySize(kInt8ByteCount)) return null;
    final value = _buffer
        .getUint8(_cursor)
        .toRadixString(hexDecimalBase)
        .padLeft(2, '0');
    _cursor += kInt8ByteCount;
    return value.toUpperCase();
  }

  String? readMacAddress({String divider = '-'}) {
    final bytes = readBytes(kMacByteCount);
    if (bytes == null) return null;
    return bytes.toHexString(divider: divider);
  }

  String? readIPv4Address() {
    final bytes = readBytes(kIPv4ByteCount);
    if (bytes == null) return null;
    final value = StringBuffer();
    for (final byte in bytes) {
      if (value.isNotEmpty) value.write(".");
      value.write(byte.toString());
    }
    return value.toString();
  }

  DateTime? readDate() {
    if (_verifySize(kDateByteCount)) return null;
    final day = _buffer.getUint8(_cursor++);
    final month = _buffer.getUint8(_cursor++);
    final year = _buffer.getUint8(_cursor++);
    return DateTime(year + 2000, month != 0 ? month : 1, day != 0 ? day : 1);
  }

  DateTime? readTime() {
    if (_verifySize(kDateByteCount)) return null;
    final hour = _buffer.getUint8(_cursor++);
    final minutes = _buffer.getUint8(_cursor++);
    final seconds = _buffer.getUint8(_cursor++);
    return DateTime(2000, 1, 1, hour, minutes, seconds);
  }

  DateTime? readDateTime() {
    if (_verifySize(kDateByteCount + kTimeByteCount)) return null;
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
      _data.length >= _cursor ? Uint8List.sublistView(_data, _cursor) : null;
}

extension UtilsByteArrayExtension on Uint8List {
  ByteArrayReader get reader => ByteArrayReader(this);
}
