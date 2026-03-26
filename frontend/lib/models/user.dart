class User {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String city;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone_number'],
      city: json['city'],
    );
  }
}
