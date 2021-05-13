class User {
  String? name;
  String mailAddress;

  static User? current;

  User({this.name, required this.mailAddress});
}
