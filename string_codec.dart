import 'dart:convert';
import 'dart:typed_data';

import 'utf16_codec.dart';

enum Encoding {latin1, ascii, utf8, utf16}
const StringCodec codec = _StringCodecReplace(); //TODO: colocar no GetIt

abstract class StringCodec {
  Uint8List encode(String string, [Encoding encoder = Encoding.utf8]);
  String decode(Uint8List bytes, [Encoding decoder = Encoding.utf8]);
}

class _StringCodecFallback implements StringCodec{

  const _StringCodecFallback();

  @override
  Uint8List encode(String string, [Encoding encoder = Encoding.utf8]) {
    try {
      return switch(encoder) {
        Encoding.utf8 => utf8.encode(string),
        Encoding.ascii => ascii.encode(string),
        Encoding.latin1 => latin1.encode(string),
        Encoding.utf16 => utf16.encode(string),
      };
    } catch (_) {
      //Fallback for the invalid chars
      return utf8.encode(string);
    }
  }

  @override
  String decode(Uint8List bytes, [Encoding decoder = Encoding.utf8]) {
    //Replace invalid chars
    return switch(decoder) {
      Encoding.utf8 => utf8.decode(bytes, allowMalformed: true),
      Encoding.ascii => ascii.decode(bytes, allowInvalid: true),
      Encoding.latin1 => latin1.decode(bytes, allowInvalid: true),
      Encoding.utf16 => utf16.decode(bytes),
    };
  }
}


class _StringCodecReplace implements StringCodec{

  static const int nullChar = 0x1F;
  static const int asciiValidChar = 0x7F;
  static const int latin1ValidChar = 0xFF;

  const _StringCodecReplace();

  @override
  String decode(Uint8List bytes, [Encoding decoder = Encoding.utf8]) {
    return switch(decoder) {
      Encoding.utf8 => utf8.decode(bytes, allowMalformed: true),
      Encoding.ascii => ascii.decode(bytes, allowInvalid: true),
      Encoding.latin1 => latin1.decode(bytes, allowInvalid: true),
      Encoding.utf16 => utf16.decode(bytes),
    };
  }

  @override
  Uint8List encode(String string, [Encoding encoder = Encoding.utf8]) {
    return switch(encoder) {
      Encoding.utf8 => utf8.encode(string),
      Encoding.ascii => ascii.encode(_replaceInvalidAsciiChars(string)),
      Encoding.latin1 => latin1.encode(_replaceInvalidLatin1Chars(string)),
      Encoding.utf16 => utf16.encode(string),
    };
  }

  String _replaceInvalidAsciiChars(String string)
  {
    return String.fromCharCodes(
      string.codeUnits.map((char) => char <= asciiValidChar ? char : nullChar)
    );
  }

  String _replaceInvalidLatin1Chars(String string)
  {
    return String.fromCharCodes(
        string.codeUnits.map((char) => char <= latin1ValidChar ? char : nullChar)
    );
  }
}

