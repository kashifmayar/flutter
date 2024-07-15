class User {
  String firstName;
  String lastName;
  String cnic;
  String dateOfBirth;
  String gender;
  String email;
  String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.cnic,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'cnic': cnic,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'email': email,
      'password': password,
    };
  }
}
