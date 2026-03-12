class ApiUser {
  const ApiUser({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    required this.rights,
    required this.site,
  });

  final int? id;
  final String username;
  final String? fullname;
  final String? email;
  final int rights;
  final String? site;

  factory ApiUser.fromMap(Map<String, dynamic> map) {
    return ApiUser(
      id: map['id'] as int?,
      username: (map['username'] ?? '') as String,
      fullname: map['fullname'] as String?,
      email: map['email'] as String?,
      rights: (map['rights'] as num?)?.toInt() ?? 0,
      site: map['site'] as String?,
    );
  }
}
