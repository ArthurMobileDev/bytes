class Installation {
  final String? name;
  final String? macAddress;
  final String? ipAddress;
  const Installation({this.macAddress, this.name, this.ipAddress});

  @override
  bool operator ==(Object other){
    if (other is! Installation) return false;
    return macAddress == other.macAddress;
  }

  @override
  int get hashCode => macAddress.hashCode;


}