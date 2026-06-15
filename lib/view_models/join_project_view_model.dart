import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/services/password_crypto.dart';
import 'package:expense_user/services/project_service.dart';
import 'package:expense_user/views/project/widgets/project_filter_criteria.dart';
import 'package:expense_user/widgets/project_helpers.dart';
import 'package:flutter/foundation.dart';

// ViewModel for the join project screen: manages available projects and joining logic.
class JoinProjectViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _keyword = '';
  ProjectFilterCriteria _criteria = const ProjectFilterCriteria();
  bool _isJoiningProject = false;

  // Getters
  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get keyword => _keyword;
  ProjectFilterCriteria get criteria => _criteria;
  bool get isJoiningProject => _isJoiningProject;

  // Initializes the viewmodel: loads available projects.
  void initialize() {
    _loadProjects();
  }

  // Loads all available projects from Firebase.
  Future<void> _loadProjects() async {
    try {
      _isLoading = true;
      notifyListeners();

      List<ProjectModel> loadedProjects = await _projectService.loadAllProjects();
      _projects = loadedProjects;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load projects.';
      notifyListeners();
    }
  }

  // Updates the search keyword.
  void updateKeyword(String keyword) {
    _keyword = keyword;
    notifyListeners();
  }

  // Updates the filter criteria.
  void updateCriteria(ProjectFilterCriteria criteria) {
    _criteria = criteria;
    notifyListeners();
  }

  // Filters projects by keyword and criteria.
  List<ProjectModel> getFilteredProjects() {
    return filterProjects(
      projects: _projects,
      keyword: _keyword,
      criteria: _criteria,
    );
  }

  // Checks whether the entered password matches the stored password.
  bool passwordMatches(String enteredPassword, String storedPassword) {
    String entered = enteredPassword.trim();
    String stored = storedPassword.trim();

    // Use crypto matching for encrypted passwords.
    if (stored.startsWith('enc:')) {
      return PasswordCrypto.matchesStoredValue(
        plainText: entered,
        storedValue: stored,
      );
    }

    // Keep plain match for old unlocked/plain password records.
    return entered == stored;
  }

  // Joins the current user to a project.
  Future<void> joinProject(ProjectModel project) async {
    try {
      _isJoiningProject = true;
      notifyListeners();

      await _projectService.joinProject(project.adminUid, project.projectCode);

      // Reload projects to update UI.
      await _loadProjects();

      _isJoiningProject = false;
      notifyListeners();
    } catch (e) {
      _isJoiningProject = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

