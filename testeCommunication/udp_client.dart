import 'dart:io';
import 'dart:typed_data';

class UDPClient {

  RawDatagramSocket? _socket;
  final InternetAddress ipAddress;
  final int port;

  UDPClient({required String ipAddress, required this.port})
      : ipAddress = InternetAddress(ipAddress);

  bool get connected => _socket != null;

  Future<RawDatagramSocket?> connect() async {
    if (connected) disconnect();
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _socket?.broadcastEnabled = true;
    return _socket;
  }

  void disconnect()
  {
    _socket?.close();
    _socket = null;
  }

  void send(Uint8List data, [String? address])
  {
    if (connected){
      final destiny = address == null? ipAddress : InternetAddress(address);
      _socket?.send(data, destiny, port);
    }
  }

}