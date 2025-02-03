class ItemCategory {
  final String title;
  final String image;

  ItemCategory({required this.title, required this.image});

  // Factory method to create an Item from JSON
  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      title: json['title'],
      image: json['image'],
    );
  }
}
