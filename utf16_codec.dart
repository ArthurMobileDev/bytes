import 'dart:convert';
import 'dart:typed_data';

const utf16 = Utf16Codec();

class Utf16Codec extends Codec<String, Uint8List>
{
  final Endian endian;
  const Utf16Codec([this.endian = Endian.big]);

  @override
  Converter<Uint8List, String> get decoder => _Utf16Decoder(endian);

  @override
  Converter<String, Uint8List> get encoder => _Utf16Encoder(endian);
}

class _Utf16Encoder extends Converter<String, Uint8List>
{
  final Endian endian;
  const _Utf16Encoder(this.endian);

  Uint8List convert(String input) {
    final chars = input.codeUnits;
    final data = ByteData(chars.length * 2);
    for (int i = 0; i < chars.length; i++) {
      data.setUint16(i * 2, chars[i], endian);
    } return data.buffer.asUint8List();
  }
}

class _Utf16Decoder extends Converter<Uint8List, String>
{
  final Endian endian;

  _Utf16Decoder(this.endian);

  @override
  String convert(Uint8List input) {
    final buffer = StringBuffer();
    final data = ByteData.sublistView(input);
    for (int i = 0; i < input.length; i+=2)
    {
      buffer.writeCharCode(data.getUint16(i, endian));
    }
    if (input.length % 2 == 1)
      buffer.writeCharCode(data.getUint8(input.length-1));
    return buffer.toString();
  }
}