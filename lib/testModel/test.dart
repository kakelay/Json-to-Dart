class MyModel {
  final int? id;
  final String? name;
  final bool? isActive;

  final List<Items>? items;

  MyModel({this.id, this.name, this.isActive, this.items});

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],

      items: json['items'] != null
          ? List<Items>.from(json['items'].map((x) => Items.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'items': items?.map((x) => x.toJson()).toList(),
    };
  }
}

class Items {
  final String? title;
  final double? price;

  Items({this.title, this.price});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(title: json['title'], price: json['price']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'price': price};
  }
}
