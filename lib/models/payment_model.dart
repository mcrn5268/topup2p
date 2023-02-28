class Payment {
  final String paymentname;
  final String paymentimage;
  String accountname;
  String accountnumber;
  bool isEnabled;

  Payment(
      {required this.paymentname,
      required this.paymentimage,
      required this.accountname,
      required this.accountnumber,
      required this.isEnabled});

  factory Payment.fromMap(Map<String, dynamic> map) {
  final paymentName = map.keys.toList()[0];
  final paymentData = map[paymentName];
    return Payment(
        paymentname: paymentName,
        accountname: paymentData['account_name'],
        accountnumber: paymentData['account_number'],
        isEnabled: paymentData['status']=='enabled',
        paymentimage: paymentData['image']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          runtimeType == other.runtimeType &&
          paymentname == other.paymentname &&
          paymentimage == other.paymentimage &&
          accountname == other.accountname &&
          accountnumber == other.accountnumber &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode =>
      paymentname.hashCode ^
      paymentimage.hashCode ^
      accountname.hashCode ^
      accountnumber.hashCode ^
      isEnabled.hashCode;
}
