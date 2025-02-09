class UserVoucher {
  int? id;
  String? name;
  String? description;
  int? discount;
  int? price;
  List<int>? product;

  UserVoucher({
    this.id,
    this.name,
    this.description,
    this.discount,
    this.price,
    this.product,
  });

  factory UserVoucher.fromJson(Map<String, dynamic> json) {
    return UserVoucher(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discount: json['discount'],
      price: json['price'],
      product: List<int>.from(json['product']), // Konversi ke List<int>
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount': discount,
      'price': price,
      'product': product,
    };
  }
}
