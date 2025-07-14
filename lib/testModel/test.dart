class ProductModel {
  final int? id;
  final String? name;
  final bool? isActive;
  final Profile? profile;

  ProductModel({this.id, this.name, this.isActive, this.profile});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'profile': profile?.toJson(),
    };
  }
}

class Profile {
  final String? email;
  final String? phone;

  Profile({this.email, this.phone});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(email: json['email'], phone: json['phone']);
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'phone': phone};
  }
}
