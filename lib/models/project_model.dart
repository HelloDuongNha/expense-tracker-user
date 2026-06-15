// Project data from the AdminProjects Firebase node.
class ProjectModel {
  final String projectCode;
  final String projectName;
  final String description;
  final String status;
  final String startDate;
  final String endDate;
  final String owner;
  final double budget;
  final String budgetCurrency;
  final String? projectPasswordEncrypted;
  final String adminUid;
  final Map<String, bool> participants;

  const ProjectModel({
    required this.projectCode,
    required this.projectName,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.owner,
    required this.budget,
    required this.budgetCurrency,
    required this.adminUid,
    this.projectPasswordEncrypted,
    this.participants = const {},
  });

  // Parse a single project from raw Firebase map.
  factory ProjectModel.fromMap(
    Map<dynamic, dynamic> map,
    String adminUid,
    String projectCode,
  ) {
    // Build participants map from raw data.
    Map<String, bool> participantsMap = {};
    dynamic rawParticipants = map['participants'];
    if (rawParticipants is Map) {
      for (dynamic key in rawParticipants.keys) {
        participantsMap[key.toString()] = true;
      }
    }

    return ProjectModel(
      projectCode: projectCode,
      projectName: (map['projectName'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      status: (map['status'] ?? 'Active').toString(),
      startDate: (map['startDate'] ?? '').toString(),
      endDate: (map['endDate'] ?? '').toString(),
      owner: (map['owner'] ?? '').toString(),
      budget: double.tryParse(map['budget']?.toString() ?? '') ?? 0.0,
      budgetCurrency: (map['budgetCurrency'] ?? 'USD').toString(),
      projectPasswordEncrypted: map['projectPasswordEncrypted']?.toString(),
      adminUid: adminUid,
      participants: participantsMap,
    );
  }

  // Parse the entire AdminProjects root into a flat project list.
  static List<ProjectModel> parseAdminProjects(Map<dynamic, dynamic>? rootData) {
    List<ProjectModel> projects = [];

    // Return empty list if there is no data.
    if (rootData == null) {
      return projects;
    }

    // Walk each admin node, then each project under it.
    for (dynamic adminUid in rootData.keys) {
      dynamic adminData = rootData[adminUid];
      if (adminData is! Map) {
        continue;
      }

      // Iterate through each project under this admin.
      dynamic projectsNode = adminData['projects'];
      if (projectsNode is! Map) {
        continue;
      }

      for (dynamic projectCode in projectsNode.keys) {
        dynamic projectData = projectsNode[projectCode];
        if (projectData is! Map) {
          continue;
        }

        // Convert the raw map data into a ProjectModel and add to results.
        ProjectModel project = ProjectModel.fromMap(
          Map<dynamic, dynamic>.from(projectData),
          adminUid.toString(),
          projectCode.toString(),
        );
        projects.add(project);
      }
    }

    return projects;
  }

  // Check if a user UID is a participant.
  bool isParticipant(String userUid) {
    return participants.containsKey(userUid);
  }

  // True when an encrypted password is set.
  bool get isLocked {
    String password = (projectPasswordEncrypted ?? '').trim();
    return password.isNotEmpty;
  }
}