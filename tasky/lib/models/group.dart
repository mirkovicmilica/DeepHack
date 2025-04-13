// class Group {
//   final String id;
//   final String name;

//   Group({required this.id, required this.name});

//   factory Group.fromMap(Map<String, dynamic> data, String documentId) {
//     return Group(id: documentId, name: data['name'] ?? 'Unnamed Group');
//   }

//   Map<String, dynamic> toMap() {
//     return {'name': name};
//   }
// }
class Group {
  final String id;
  final String name;
  final List<String> members; // A list to hold the member IDs (or names)

  Group({required this.id, required this.name, required this.members});

  // Factory constructor to create a Group from a Map
  factory Group.fromMap(Map<String, dynamic> data, String documentId) {
    return Group(
      id: documentId,
      name: data['name'] ?? 'Unnamed Group',
      members: List<String>.from(data['members'] ?? []), // Convert the list of members from the data map
    );
  }

  // Method to convert the Group object back to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members, // Include the members when converting to a map
    };
  }
}
