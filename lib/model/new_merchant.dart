class NewMerchant {
  final String title;
  final String image;

  NewMerchant({required this.title, required this.image});

  // Fungsi factory untuk parsing dari JSON
  factory NewMerchant.fromJson(Map<String, dynamic> json) {
    return NewMerchant(
      title: json['title'] as String,
      image: json['image'] as String,
    );
  }
}
