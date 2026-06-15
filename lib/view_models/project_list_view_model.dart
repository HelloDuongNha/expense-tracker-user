import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/services/favorites_service.dart';
import 'package:expense_user/services/project_service.dart';
import 'package:expense_user/views/project/widgets/project_filter_criteria.dart';
import 'package:expense_user/widgets/project_helpers.dart';
import 'package:flutter/foundation.dart';

// ViewModel for the project list screen: manages joined projects, favorites, filtering, sorting.
class ProjectListViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _allJoinedProjects = [];
  Map<String, double> _expenseTotals = {};
  Set<String> _favorites = {};

  bool _isLoading = true;
  String? _errorMessage;

  String _keyword = '';
  ProjectFilterCriteria _criteria = const ProjectFilterCriteria();

  // Getters
  List<ProjectModel> get allJoinedProjects => _allJoinedProjects;
  Map<String, double> get expenseTotals => _expenseTotals;
  Set<String> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get keyword => _keyword;
  ProjectFilterCriteria get criteria => _criteria;

  // Initializes the viewmodel: loads favorites and listens to projects.
  void initialize() {
    _loadFavorites();
    _listenToProjects();
  }

  // Loads saved favorites from Firebase.
  Future<void> _loadFavorites() async {
    Set<String> favs = await FavoritesService.loadFavorites();
    _favorites = favs;
    notifyListeners();
  }

  // Toggles a project as favorite.
  Future<void> toggleFavorite(ProjectModel project) async {
    String key = FavoritesService.projectKey(project.adminUid, project.projectCode);
    Set<String> updated = await FavoritesService.toggleFavorite(key, _favorites);
    _favorites = updated;
    notifyListeners();
  }

  // Listens to Firebase project changes and expense totals.
  void _listenToProjects() {
    _projectService.joinedProjectsStream().listen(
      (result) {
        _allJoinedProjects = result.projects;
        _expenseTotals = result.expenseTotals;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load projects.';
        notifyListeners();
      },
    );
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
      projects: _allJoinedProjects,
      keyword: _keyword,
      criteria: _criteria,
    );
  }

  // Sorts projects so that favorited ones appear first.
  List<ProjectModel> getSortedWithFavorites(List<ProjectModel> projects) {
    List<ProjectModel> sorted = List<ProjectModel>.from(projects);
    sorted.sort((ProjectModel a, ProjectModel b) {
      int aFav = _isFavorited(a) ? 0 : 1;
      int bFav = _isFavorited(b) ? 0 : 1;
      return aFav.compareTo(bFav);
    });
    return sorted;
  }

  // Checks whether a project is in the user's favorites.
  bool _isFavorited(ProjectModel project) {
    String key = FavoritesService.projectKey(project.adminUid, project.projectCode);
    return _favorites.contains(key);
  }

  // Gets the visible projects after filtering and sorting.
  List<ProjectModel> getVisibleProjects() {
    List<ProjectModel> filtered = getFilteredProjects();
    return getSortedWithFavorites(filtered);
  }

  // Gets the remaining budget for a project.
  double getRemainingBudget(ProjectModel project) {
    double spent = _expenseTotals[project.projectCode] ?? 0;
    return project.budget - spent;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

