class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromMap(Map<String, dynamic> data, String documentId) {
    return Group(id: documentId, name: data['name'] ?? 'Unnamed Group');
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
