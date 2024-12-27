class Hobby {
  final String id;
  final String name;
  final String icon;

  Hobby({
    required this.id,
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory Hobby.fromMap(Map<String, dynamic> map) {
    return Hobby(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
    );
  }
}
