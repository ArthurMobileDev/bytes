import 'communication.dart';



void main() async{
  final communication = CommunicationService();
  communication.start(Duration(seconds: 5));

  await for (final installation in communication.installations)
  {
    print(" - ${installation?.macAddress} -> ${installation?.name} on ${installation?.ipAddress}");
  }
}