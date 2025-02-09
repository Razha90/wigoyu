class UserNotification {
  String? name;
  String? text;
  String? id;
  bool? open;

  UserNotification({
    this.name,
    this.text,
    this.id,
    this.open,
  });

  // Convert from JSON
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      name: json['name'],
      text: json['text'],
      id: json['id'],
      open: json['open'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'text': text,
      'id': id,
      'open': open,
    };
  }
}
