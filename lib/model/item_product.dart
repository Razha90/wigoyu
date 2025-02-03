class ItemProduct {
  final String category;
  final String name;
  final String alamat;
  final String video;
  final String detailt;
  final List<String> image;
  final List<String> facility;
  final String shortDetail;
  final OpenTime open;
  final String map;
  final List<SocialMedia> medsos;
  final List<Review> review;
  final List<Voucher> voucher;

  ItemProduct({
    required this.category,
    required this.name,
    required this.alamat,
    required this.video,
    required this.detailt,
    required this.image,
    required this.facility,
    required this.shortDetail,
    required this.open,
    required this.map,
    required this.medsos,
    required this.review,
    required this.voucher,
  });

  factory ItemProduct.fromJson(Map<String, dynamic> json) {
    return ItemProduct(
      category: json['category'],
      name: json['name'],
      alamat: json['alamat'],
      video: json['video'],
      detailt: json['detailt'],
      image: List<String>.from(json['image']),
      facility: List<String>.from(json['facility']),
      shortDetail: json['short_detail'],
      open: OpenTime.fromJson(json['open']),
      map: json['map'],
      medsos: (json['medsos'] as List)
          .map((medsos) => SocialMedia.fromJson(medsos))
          .toList(),
      review: (json['review'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
      voucher: (json['voucher'] as List) // Parsing voucher
          .map((voucher) => Voucher.fromJson(voucher))
          .toList(),
    );
  }
}

class Voucher {
  final int id;
  final String name;
  final String description;
  final int discount;
  final int price;
  final List<int> product;

  Voucher({
    required this.id,
    required this.name,
    required this.description,
    required this.discount,
    required this.price,
    required this.product,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
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

class OpenTime {
  final String startDay;
  final String endDay;
  final String startTime;
  final String endTime;

  OpenTime({
    required this.startDay,
    required this.endDay,
    required this.startTime,
    required this.endTime,
  });

  factory OpenTime.fromJson(Map<String, dynamic> json) {
    return OpenTime(
      startDay: json['start_day'],
      endDay: json['end_day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class SocialMedia {
  final String name;
  final String link;

  SocialMedia({
    required this.name,
    required this.link,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      name: json['name'],
      link: json['link'],
    );
  }
}

class Review {
  final String name;
  final int rating;
  final String comment;
  final String date;
  final int userId;
  final String image;

  Review({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    required this.userId,
    required this.image,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'],
      rating: json['rating'],
      comment: json['comment'],
      date: json['date'],
      userId: json['userdId'],
      image: json['image'],
    );
  }
}
