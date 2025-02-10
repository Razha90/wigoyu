import 'package:wigoyu/model/user_voucher.dart';

class VoucherUsed {
  int? id;
  String? name;
  String? description;
  int? discount;
  int? price;
  List<int>? product;
  String?
      userName; // Tambahan data name (nama pengguna yang menggunakan voucher)

  VoucherUsed({
    this.id,
    this.name,
    this.description,
    this.discount,
    this.price,
    this.product,
    this.userName,
  });

  // Factory method untuk membuat instance dari UserVoucher + nama pengguna
  factory VoucherUsed.fromUserVoucher(UserVoucher voucher, String userName) {
    return VoucherUsed(
      id: voucher.id,
      name: voucher.name,
      description: voucher.description,
      discount: voucher.discount,
      price: voucher.price,
      product: voucher.product,
      userName: userName,
    );
  }

  factory VoucherUsed.fromJson(Map<String, dynamic> json) {
    return VoucherUsed(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discount: json['discount'],
      price: json['price'],
      product: List<int>.from(json['product']),
      userName: json['userName'],
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
      'userName': userName,
    };
  }
}
