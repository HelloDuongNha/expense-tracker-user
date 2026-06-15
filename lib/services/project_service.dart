import 'dart:async';
import 'package:expense_user/models/project_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Service for managing project operations: loading, joining, leaving, expense totals.
class ProjectService {
  final DatabaseReference _adminProjectsRef = FirebaseDatabase.instance.ref('AdminProjects');

  // Listens to all projects and returns a stream of joined projects + expense totals.
  Stream<({List<ProjectModel> projects, Map<String, double> expenseTotals})> joinedProjectsStream() {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      return Stream.error('No user authenticated');
    }

    return _adminProjectsRef.onValue.map((DatabaseEvent event) {
      Map<dynamic, dynamic>? value = event.snapshot.value as Map<dynamic, dynamic>?;

      // Parse all projects and filter to only joined ones.
      List<ProjectModel> allProjects = ProjectModel.parseAdminProjects(value);
      List<ProjectModel> joined = [];
      for (int i = 0; i < allProjects.length; i++) {
        if (allProjects[i].isParticipant(currentUserUid)) {
          joined.add(allProjects[i]);
        }
      }

      // Parse expense totals per project code.
      Map<String, double> totals = {};
      if (value != null) {
        for (MapEntry<dynamic, dynamic> adminEntry in value.entries) {
          dynamic adminData = adminEntry.value;
          if (adminData is! Map) {
            continue;
          }
          dynamic expenses = adminData['expenses'];
          if (expenses is! Map) {
            continue;
          }
          for (MapEntry<dynamic, dynamic> expEntry in expenses.entries) {
            dynamic expData = expEntry.value;
            if (expData is! Map) {
              continue;
            }
            String code = (expData['projectCode'] ?? '').toString();
            double amount = _parseAmount(expData['amount']);
            if (code.isNotEmpty) {
              totals[code] = (totals[code] ?? 0) + amount;
            }
          }
        }
      }

      return (projects: joined, expenseTotals: totals);
    });
  }

  // Loads all available projects from Firebase.
  Future<List<ProjectModel>> loadAllProjects() async {
    try {
      DataSnapshot snapshot = await _adminProjectsRef.get();
      Map<dynamic, dynamic>? value = snapshot.value as Map<dynamic, dynamic>?;
      return ProjectModel.parseAdminProjects(value);
    } catch (_) {
      throw Exception('Failed to load projects');
    }
  }

  // Joins the current user to a project.
  Future<void> joinProject(String adminUid, String projectCode) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      throw Exception('No user authenticated');
    }

    DatabaseReference participantRef = FirebaseDatabase.instance.ref(
      'AdminProjects/$adminUid/projects/$projectCode/participants/$currentUserUid',
    );

    try {
      await participantRef.set(true);
    } catch (_) {
      throw Exception('Failed to join project');
    }
  }

  // Removes the current user from a project and clears favorite status.
  Future<void> leaveProject(String adminUid, String projectCode) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      throw Exception('No user authenticated');
    }

    Map<String, Object?> updates = <String, Object?>{
      'AdminProjects/$adminUid/projects/$projectCode/participants/$currentUserUid': null,
      'UserFavorites/$currentUserUid/${adminUid}_$projectCode': null,
    };

    try {
      await FirebaseDatabase.instance.ref().update(updates);
    } catch (_) {
      throw Exception('Failed to leave project');
    }
  }

  // Parses a dynamic value into a double amount.
  double _parseAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse((value ?? '').toString()) ?? 0;
  }
}

