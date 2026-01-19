
import 'dart:convert';
import 'dart:typed_data';

import 'byte_array_builder.dart';
import 'byte_array_reader.dart';
import 'bytes_utils.dart';
import 'utf16_codec.dart';

 bool compareList (dynamic a, dynamic b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

void testByteArrayBuilder() {

  ByteArrayBuilder builder = ByteArrayBuilder();

  //add Bytes Padrões
  builder.addBoolean(true);
  assert(compareList(builder.build(), [1]));

  builder.addByte(0x50);
  assert(compareList(builder.build(), [1, 80]));

  builder.addByte(-1);
  assert(compareList(builder.build(), [1, 80, 255]));

  builder.add16Int(0x1ff);
  assert(compareList(builder.build(), [1, 80, 255, 1, 255]));

  builder.add24Int(0x00500A);
  assert(compareList(builder.build(), [1, 80, 255, 1, 255, 0, 80, 10]));

  builder.add32Int(0x00552001);
  assert(compareList(builder.build(), [1, 80, 255, 1, 255, 0, 80, 10, 00, 85, 32, 1]));

  builder.addByte(0x6556);
  assert(compareList(builder.build(), [1, 80, 255, 1, 255, 0, 80, 10, 00, 85, 32, 1, 86]));

  builder.clear();
  assert(compareList(builder.build(), []));

  //add Big integers
  builder.add64Int(0x2002200200200220);
  assert(compareList(builder.build(), [32, 2, 32, 2, 0, 32, 2, 32]));

  builder.add24Int(0x50505050);
  assert(compareList(builder.build(), [32, 2, 32, 2, 0, 32, 2, 32, 80, 80, 80]));

  builder.add16Int(0x40404040);
  assert(compareList(builder.build(), [32, 2, 32, 2, 0, 32, 2, 32, 80, 80, 80, 64, 64]));

  builder.addInteger(0x30303030, bytesCount: 1);
  assert(compareList(builder.build(), [32, 2, 32, 2, 0, 32, 2, 32, 80, 80, 80, 64, 64, 48]));

  builder.addInteger(0x010101010101, bytesCount: 6);
  assert(compareList(builder.build(), [32, 2, 32, 2, 0, 32, 2, 32, 80, 80, 80, 64, 64, 48, 01, 01, 01, 01, 01, 01]));

  //add Double
  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addDouble(3.1415);
  assert(compareList(builder.build(), [0, 3, 14]));

  builder.addDouble(3.1499);
  assert(compareList(builder.build(), [0, 3, 14, 0, 3, 15]));

  builder.addDouble(3);
  assert(compareList(builder.build(), [0, 3, 14, 0, 3, 15, 0, 3, 0]));

  builder.addDouble(0.1);
  assert(compareList(builder.build(), [0, 3, 14, 0, 3, 15, 0, 3, 0, 0, 0, 10]));

  builder.addDouble(65535.599);
  assert(compareList(builder.build(), [0, 3, 14, 0, 3, 15, 0, 3, 0, 0, 0, 10, 255, 255, 60]));

  //add Byte List
  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addByteList(Uint8List.fromList([1, 43, 65 , 90, 48, 47, 255, 167, 100]));
  assert(compareList(builder.build(), [1, 43, 65 , 90, 48, 47, 255, 167, 100]));

  builder.addByteList(Uint8List(0));
  assert(compareList(builder.build(), [1, 43, 65 , 90, 48, 47, 255, 167, 100]));

  //add String
  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addString("M4çã v³®D& ぁ🫵", encoder: utf8);
  assert(compareList(builder.build(), [22, 0x4D, 0x34, 0xC3, 0xA7, 0xC3, 0xA3, 0x20, 0x76, 0xC2, 0xB3, 0xC2, 0xAE, 0x44, 0x26, 0x20, 0xE3, 0x81, 0x81, 0xF0, 0x9F, 0xAB, 0xB5,]));

  builder.addString("M4çã v³®D& ぁ🫵", encoder: latin1);
  assert(compareList(builder.build(), [22, 0x4D, 0x34, 0xC3, 0xA7, 0xC3, 0xA3, 0x20, 0x76, 0xC2, 0xB3, 0xC2, 0xAE, 0x44, 0x26, 0x20, 0xE3, 0x81, 0x81, 0xF0, 0x9F, 0xAB, 0xB5, 14, 0x4D, 0x34, 0xE7, 0xE3, 0x20, 0x76, 0xB3, 0xAE, 0x44, 0x26, 0x20, 0x1F, 0x1F, 0x1F]));

  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addString("M4çã v³®D& ぁ🫵", encoder: utf16);
  assert(compareList(builder.build(), [28, 0x00, 0x4D, 0x00, 0x34, 0x00, 0xE7, 0x00, 0xE3, 0x00, 0x20, 0x00, 0x76, 0x00, 0xB3, 0x00, 0xAE, 0x00, 0x44, 0x00, 0x26, 0x00, 0x20, 0x30, 0x41, 0xD8, 0x3E, 0xDE, 0xF5,]));

  builder.addString("M4çã v³®D& ぁ🫵", encoder: ascii);
  assert(compareList(builder.build(), [28, 0x00, 0x4D, 0x00, 0x34, 0x00, 0xE7, 0x00, 0xE3, 0x00, 0x20, 0x00, 0x76, 0x00, 0xB3, 0x00, 0xAE, 0x00, 0x44, 0x00, 0x26, 0x00, 0x20, 0x30, 0x41, 0xD8, 0x3E, 0xDE, 0xF5, 14, 0x4D, 0x34, 0x1F, 0x1F, 0x20, 0x76, 0x1F, 0x1F, 0x44, 0x26, 0x20, 0x1F, 0x1F, 0x1F]));

  builder.addString("", sizeBytesCount: 2);
  assert(compareList(builder.build(), [28, 0x00, 0x4D, 0x00, 0x34, 0x00, 0xE7, 0x00, 0xE3, 0x00, 0x20, 0x00, 0x76, 0x00, 0xB3, 0x00, 0xAE, 0x00, 0x44, 0x00, 0x26, 0x00, 0x20, 0x30, 0x41, 0xD8, 0x3E, 0xDE, 0xF5, 14, 0x4D, 0x34, 0x1F, 0x1F, 0x20, 0x76, 0x1F, 0x1F, 0x44, 0x26, 0x20, 0x1F, 0x1F, 0x1F, 0, 0]));

  builder.addString(null);
  assert(compareList(builder.build(), [28, 0x00, 0x4D, 0x00, 0x34, 0x00, 0xE7, 0x00, 0xE3, 0x00, 0x20, 0x00, 0x76, 0x00, 0xB3, 0x00, 0xAE, 0x00, 0x44, 0x00, 0x26, 0x00, 0x20, 0x30, 0x41, 0xD8, 0x3E, 0xDE, 0xF5, 14, 0x4D, 0x34, 0x1F, 0x1F, 0x20, 0x76, 0x1F, 0x1F, 0x44, 0x26, 0x20, 0x1F, 0x1F, 0x1F, 0, 0, 0]));

  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addMD5("oi", withSize: true, asHexString: true);
  assert(compareList(builder.build(), [0x20, 0x41, 0x32, 0x45, 0x36, 0x33, 0x45, 0x45, 0x30, 0x31, 0x34, 0x30, 0x31, 0x41, 0x41, 0x45, 0x43, 0x41, 0x37, 0x38, 0x42, 0x45, 0x30, 0x32, 0x33, 0x44, 0x46, 0x42, 0x42, 0x38, 0x43, 0x35, 0x39]));

  builder.addMD5("oi", withSize: false, asHexString: true);
  assert(compareList(builder.build(), [0x20, 0x41, 0x32, 0x45, 0x36, 0x33, 0x45, 0x45, 0x30, 0x31, 0x34, 0x30, 0x31, 0x41, 0x41, 0x45, 0x43, 0x41, 0x37, 0x38, 0x42, 0x45, 0x30, 0x32, 0x33, 0x44, 0x46, 0x42, 0x42, 0x38, 0x43, 0x35, 0x39, 0x41, 0x32, 0x45, 0x36, 0x33, 0x45, 0x45, 0x30, 0x31, 0x34, 0x30, 0x31, 0x41, 0x41, 0x45, 0x43, 0x41, 0x37, 0x38, 0x42, 0x45, 0x30, 0x32, 0x33, 0x44, 0x46, 0x42, 0x42, 0x38, 0x43, 0x35, 0x39]));

  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addMD5("oi", withSize: true, asHexString: false);
  assert(compareList(builder.build(), [0x10, 0xA2, 0xE6, 0x3E, 0xE0, 0x14, 0x01, 0xAA, 0xEC, 0xA7, 0x8B, 0xE0, 0x23, 0xDF, 0xBB, 0x8C, 0x59]));

  builder.addMD5("oi", withSize: false, asHexString: false);
  assert(compareList(builder.build(), [0x10, 0xA2, 0xE6, 0x3E, 0xE0, 0x14, 0x01, 0xAA, 0xEC, 0xA7, 0x8B, 0xE0, 0x23, 0xDF, 0xBB, 0x8C, 0x59, 0xA2, 0xE6, 0x3E, 0xE0, 0x14, 0x01, 0xAA, 0xEC, 0xA7, 0x8B, 0xE0, 0x23, 0xDF, 0xBB, 0x8C, 0x59]));

  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addString("abc", sizeBytesCount: 5);
  assert(compareList(builder.build(), [0, 0, 0, 0, 3, 0x61, 0x62, 0x63]));

  builder.addString("abc", sizeBytesCount: 0);
  assert(compareList(builder.build(), [0, 0, 0, 0, 3, 0x61, 0x62, 0x63, 0x61, 0x62, 0x63]));

  //add Network Parameters
  builder.clear();
  assert(compareList(builder.build(), []));

  builder.addIPv4Address("192.168.0.12");
  assert(compareList(builder.build(), [192, 168, 0, 12]));

  builder.addIPv4Address("192.168.0.");
  assert(compareList(builder.build(), [192, 168, 0, 12]));

  builder.addIPv4Address("192.168.0.12.43");
  assert(compareList(builder.build(), [192, 168, 0, 12]));

  builder.addMacAddress("192.168.0.12");
  assert(compareList(builder.build(), [192, 168, 0, 12]));

  builder.addMacAddress("ff-0a-20-14-00-10");
  assert(compareList(builder.build(), [192, 168, 0, 12, 255, 10, 32, 20, 0, 16]));

  builder.addMacAddress("ff:0a:20:14:00:10");
  assert(compareList(builder.build(), [192, 168, 0, 12, 255, 10, 32, 20, 0, 16, 255, 10, 32, 20, 0, 16]));

  builder.addMacAddress("ff0a20140010");
  assert(compareList(builder.build(), [192, 168, 0, 12, 255, 10, 32, 20, 0, 16, 255, 10, 32, 20, 0, 16, 255, 10, 32, 20, 0, 16]));

  builder.clear();
  assert(compareList(builder.build(), []));

  // add Date e Time
  builder.clear();
  assert(compareList(builder.build(), []));

  final dateTime = DateTime(2014, 10, 24, 15, 20, 55);

  builder.addDate(dateTime);
  assert(compareList(builder.build(), [24, 10, 14]));

  builder.addTime(dateTime);
  assert(compareList(builder.build(), [24, 10, 14, 15, 20, 55]));

  builder.addDateTime(dateTime);
  assert(compareList(builder.build(), [24, 10, 14, 15, 20, 55, 24, 10, 14, 15, 20, 55]));

  // merge builders
  ByteArrayBuilder builder2 = ByteArrayBuilder();
  builder2.add24Int(0x454).addByte(0x25).addByte(0x00);
  assert(compareList(builder2.build(), [0, 4, 84, 37, 0]));

  builder2.merge(builder);
  assert(compareList(builder2.build(), [0, 4, 84, 37, 0, 24, 10, 14, 15, 20, 55, 24, 10, 14, 15, 20, 55]));

  builder.clear();
  builder2.merge(builder);
  assert(compareList(builder2.build(), [0, 4, 84, 37, 0, 24, 10, 14, 15, 20, 55, 24, 10, 14, 15, 20, 55]));

  print("ByteArrayBuilder: OK");
}

void testByteArrayReader() {

  //read Common Integer
  ByteArrayReader reader = Uint8List.fromList([0, 80, 255, 0, 1, 21, 100, 0, 12, 12, 12]).reader;
  assert(reader.readBoolean() == false);
  assert(reader.readByte() == 0x50);
  assert(reader.read16Int() == 0xff00);
  assert(reader.read24Int() == 0x011564);
  assert(reader.read32Int() == 0x000C0C0C);
  assert(reader.read64Int() == null);
  assert(reader.read24Int() == null);

  //read Decimal
  reader = Uint8List.fromList([0, 3, 14, 0, 3, 0, 0, 0, 10, 255, 255, 59]).reader;
  assert(reader.readDouble() == 3.14);
  assert(reader.readDouble() == 3);
  assert(reader.readDouble() == 0.1);
  assert(reader.readDouble() == 65535.59);

  //read Big Integers e Byte Lists
  reader = Uint8List.fromList([50, 40, 30, 20, 10, 80, 70, 60, 50, 40, 30, 20, 10, 13, 23, 33, 43, 53, 63, 64, 74, 01, 02, 03, 04, 05, 06, 07]).reader;
  assert(reader.readInteger(5) == 0x32281E140A);
  assert(reader.readInteger(0) == null);
  assert(reader.readInteger(-1) == null);
  assert(reader.readInteger(9) == null);
  assert(reader.read64Int()! == 0x50463c32281E140A);
  assert(compareList(reader.readBytes(5), [13, 23, 33, 43, 53]));
  assert(compareList(reader.readBytes(1), [63]));
  assert(reader.readBytes(0) == null);
  assert(reader.readBytes(-1) == null);
  assert(reader.testByte(64));
  assert(!reader.testByte(64));
  assert(reader.remainingCount == 7);
  assert(compareList(reader.remaining, [1, 2, 3, 4, 5, 6, 7]));

  //read Strings
  reader = Uint8List.fromList([22, 0x4D, 0x34, 0xC3, 0xA7, 0xC3, 0xA3, 0x20, 0x76, 0xC2, 0xB3, 0xC2, 0xAE, 0x44, 0x26, 0x20, 0xE3, 0x81, 0x81, 0xF0, 0x9F, 0xAB, 0xB5, 14, 0x4D, 0x34, 0xE7, 0xE3, 0x20, 0x76, 0xB3, 0xAE, 0x44, 0x26, 0x20, 0x1F, 0x1F, 0x1F]).reader;
  assert(reader.readString(decoder: utf8) == "M4çã v³®D& ぁ🫵");
  assert(reader.readString(decoder: latin1) == "M4çã v³®D& \u001F\u001F\u001F");

  reader = Uint8List.fromList([28, 0x00, 0x4D, 0x00, 0x34, 0x00, 0xE7, 0x00, 0xE3, 0x00, 0x20, 0x00, 0x76, 0x00, 0xB3, 0x00, 0xAE, 0x00, 0x44, 0x00, 0x26, 0x00, 0x20, 0x30, 0x41, 0xD8, 0x3E, 0xDE, 0xF5, 14, 0x4D, 0x34, 0x1F, 0x1F, 0x20, 0x76, 0x1F, 0x1F, 0x44, 0x26, 0x20, 0x1F, 0x1F, 0x1F]).reader;
  assert(reader.readString(decoder: utf16) == "M4çã v³®D& ぁ🫵");
  assert(reader.readString(decoder: ascii) == "M4\u001F\u001F v\u001F\u001FD& \u001F\u001F\u001F");

  reader = Uint8List.fromList([0, 0, 0, 0, 3, 0x61, 0x62, 0x63, 0x61, 0x62, 0x63, 0x61, 0x62, 0x63, 0x00]).reader;
  assert(reader.readString(sizeBytesCount: 5) == "abc");
  assert(reader.readString(size: 3) == "abc");
  assert(reader.readString(size: 0) == null);
  assert(reader.readString(size: -1) == null);
  assert(reader.readString(size: 3, sizeBytesCount: 100) == "abc"); //if size has value ignore qtdBytesSize
  assert(reader.readString() == null);

  // read network parameters
  reader = Uint8List.fromList([192, 168, 0, 64, 0xff, 0x55, 0x31, 0x00, 0x12, 0x1f, 0xff, 0x55, 0x31, 0x00, 0x12, 0x1f, 0xff, 0x55, 0x31, 0x00, 0x12, 0x1f]).reader;
  assert(reader.readIPv4Address() == "192.168.0.64");
  assert(reader.readMacAddress() == "FF-55-31-00-12-1F");
  assert(reader.readMacAddress() != "ff-55-31-00-12-1f");
  assert(reader.readMacAddress(joinSeparator: ":") == "FF:55:31:00:12:1F");

  //read Date and Time
  reader = Uint8List.fromList([24, 10, 24, 10, 57, 23, 29, 02, 28, 23, 34, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]).reader;

  final date1 = reader.readDate()!;
  assert(date1.day == 24 && date1.month == DateTime.october && date1.year == 2024 && date1.hour == 0 && date1.minute == 0 && date1.second == 0);

  final time1 = reader.readTime()!;
  assert(time1.day == 1 && time1.month == DateTime.january && time1.year == 2000 && time1.hour == 10 && time1.minute == 57 && time1.second == 23);

  final dateTime1 = reader.readDateTime()!;
  assert(dateTime1.day == 29 && dateTime1.month == DateTime.february && dateTime1.year == 2028 && dateTime1.hour == 23 && dateTime1.minute == 34 && dateTime1.second == 59);

  final date2 = reader.readDate()!;
  assert(date2.day == 1 && date2.month == DateTime.january && date2.year == 2000 && date2.hour == 0 && date2.minute == 0 && date2.second == 0);

  final time2 = reader.readTime()!;
  assert(time2.day == 1 && time2.month == DateTime.january && time2.year == 2000 && time2.hour == 0 && time2.minute == 0 && time2.second == 0);

  final dateTime2 = reader.readDateTime()!;
  assert(dateTime2.day == 1 && dateTime2.month == DateTime.january && dateTime2.year == 2000 && dateTime2.hour == 0 && dateTime2.minute == 0 && dateTime2.second == 0);

  print("ByteArrayReader: OK");
}

void testUtils() {

  final number = 0x0A517F42;
  final bits = [false, false, false, false, true, false, true, false, false, true, false, true, false, false, false, true, false, true, true, true, true, true, true, true, false, true, false, false, false, false, true, false];

  // Integer to Bits
  assert(compareList(number.toBits(), bits.sublist(24)));
  assert(compareList(number.toBits(bytesCount: 1), bits.sublist(24)));
  assert(compareList(number.toBits(bytesCount: 2), bits.sublist(16)));
  assert(compareList(number.toBits(bytesCount: 3), bits.sublist(8)));
  assert(compareList(number.toBits(bytesCount: 4), bits));
  assert(!compareList(number.toBits(bytesCount: 5), bits));
  assert(compareList(number.toBits(bitsCount: 8), bits.sublist(24)));
  assert(compareList(number.toBits(bitsCount: 16), bits.sublist(16)));
  assert(compareList(number.toBits(bitsCount: 24), bits.sublist(8)));
  assert(compareList(number.toBits(bitsCount: 32), bits));
  assert(!compareList(number.toBits(bitsCount: 48), bits));
  assert(compareList(number.toBits(bitsCount: 30), bits.sublist(2)));
  assert(compareList(number.toBits(bitsCount: 2), bits.sublist(30)));
  assert(compareList(number.toBits(bitsCount: 0), []));
  assert(compareList(number.toBits(bitsCount: -1), []));

  print("Utils: OK");
}



void main() {
  testUtils();
  testByteArrayBuilder();
  testByteArrayReader();
}