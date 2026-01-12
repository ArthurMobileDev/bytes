import 'dart:async';
import 'dart:io';

import '../byte_array_builder.dart';
import '../byte_array_reader.dart';
import 'state_stream_controller.dart';
import 'repository.dart';
import 'udp_client.dart';

class CommunicationService {

  static const int kScanUDPPort = 37998;
  static const kUDPDelayMessage = Duration(seconds: 1);

  late StateStreamController<Installation?> _receiveStream;
  final List<Installation> _receivedInstallation = [];

  static const String _broadcastIP = "192.168.11.255";

  UDPClient? _client;

  void _received() {
    _client!.connect().then((socket){
      try {
        socket?.listen((event) async{
          if (event == RawSocketEvent.closed || event == RawSocketEvent.readClosed) return;

          final datagram = socket.receive();
          if (datagram == null) return;

          final reader = datagram.data.reader..jump(2);
          if (!reader.testByte(0x04)) return;
          final mac = reader.readMacAddress();
          final name = reader.readString();

          if (mac == null || name == null) return;

          final installation = Installation(macAddress: mac, name: name, ipAddress: datagram.address.address);

          if (!_receivedInstallation.contains(installation))
          {
            _receivedInstallation.add(installation);
            _receiveStream.emit(installation);
          }

        },
        onDone: stop,
        cancelOnError: true);
      } on Exception catch(e){
        print("Receive Fail: $e");
        stop();
      }
    });
  }

  void _send() async {
    final message = ByteArrayBuilder().add16Int(0x1).addByte(0x3).build();
    Timer.periodic(kUDPDelayMessage, (timer) async{
      if (_client == null || !_client!.connected)
      {
        timer.cancel();
        return;
      }
      print("send");
      _client?.send(message);
    });
  }

  void start([final Duration? duration]) async {
    if (_client != null) stop();

    _receiveStream = StateStreamController();
    _client = UDPClient(ipAddress: _broadcastIP, port: kScanUDPPort);

    print("Start");
    try{
      _received();
      _send();

      if (duration != null) Timer(duration, stop);

    } catch (e) {
      print("Start Fail: $e");
    }

  }

  void stop()
  {
    _client?.disconnect();
    _client = null;
    print("Stopped");
  }

  Stream<Installation?> get installations => _receiveStream.stream;

}