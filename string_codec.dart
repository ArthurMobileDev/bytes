import 'dart:convert';
import 'dart:typed_data';

const StringCodec codec = _StringCodecReplace();

abstract class StringCodec {

  factory StringCodec([bool replace = true]) =>
      replace ? const _StringCodecReplace() : const _StringCodecFallback();

  Uint8List encode(String string, [Encoding encoder = utf8]);

  String decode(Uint8List bytes, [Encoding decoder = utf8]);
}

class _StringCodecFallback implements StringCodec {
  const _StringCodecFallback();

  @override
  Uint8List encode(String string, [Encoding encoder = utf8]) {
    try {
      return encoder.encode(string) as Uint8List;
    } catch (_) {
      //Fallback for the invalid chars
      return utf8.encode(string);
    }
  }

  @override
  String decode(Uint8List bytes, [Encoding decoder = utf8]) {
    return switch (decoder) {
      Utf8Codec() => decoder.decode(bytes, allowMalformed: true),
      AsciiCodec() => decoder.decode(bytes, allowInvalid: true),
      Latin1Codec() => latin1.decode(bytes, allowInvalid: true),
      _ => decoder.decode(bytes),
    };
  }
}

class _StringCodecReplace implements StringCodec {
  static const int nullChar = 0x1F;
  static const int asciiValidChar = 0x7F;
  static const int latin1ValidChar = 0xFF;

  const _StringCodecReplace();

  @override
  String decode(Uint8List bytes, [Encoding decoder = utf8]) {
    return switch (decoder) {
      Utf8Codec() => decoder.decode(bytes, allowMalformed: true),
      AsciiCodec() => decoder.decode(bytes, allowInvalid: true),
      Latin1Codec() => latin1.decode(bytes, allowInvalid: true),
      _ => decoder.decode(bytes),
    };
  }

  @override
  Uint8List encode(String string, [Encoding encoder = utf8]) {
    if (encoder is AsciiCodec)
      string = _replaceInvalidChars(string, asciiValidChar);
    else if (encoder is Latin1Codec)
      string = _replaceInvalidChars(string, latin1ValidChar);
    return encoder.encode(string) as Uint8List;
  }

  String _replaceInvalidChars(String string, int validCharLimit) {
    final codes = Uint16List.fromList(string.codeUnits);
    for (var i = 0; i < codes.length; i++) {
      if (codes[i] > validCharLimit) codes[i] = nullChar;
    }
    return String.fromCharCodes(codes);
  }
}
