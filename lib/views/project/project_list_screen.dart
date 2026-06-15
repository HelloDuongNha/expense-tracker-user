import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/view_models/project_list_view_model.dart';
import 'package:expense_user/views/project/join_project_screen.dart';
import 'package:expense_user/views/project/my_project_card.dart';
import 'package:expense_user/views/project/project_detail_screen.dart';
import 'package:expense_user/views/project/widgets/project_filter_dialog.dart';
import 'package:expense_user/views/project/widgets/project_search_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screen that displays the list of projects the current user has joined.
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() {
    return _ProjectListScreenState();
  }
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late ProjectListViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProjectListViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // Opens the advanced filter dialog and applies the result.
  Future<void> _openFilterDialog() async {
    final currentCriteria = _viewModel.criteria;
    final result = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ProjectFilterDialog(initialCriteria: currentCriteria);
      },
    );

    if (result == null) {
      return;
    }

    _viewModel.updateCriteria(result);
  }

  // Builds the main UI for the project list screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectListViewModel>.value(
      value: _viewModel,
      child: Consumer<ProjectListViewModel>(
        builder: (BuildContext context, ProjectListViewModel vm, Widget? child) {
          String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
          List<ProjectModel> visibleProjects = vm.getVisibleProjects();

          // Build the body widget based on current state.
          Widget bodyWidget;
          if (currentUserUid == null) {
            bodyWidget = const Center(child: Text('Please log in first.'));
          } else if (vm.isLoading) {
            bodyWidget = const Center(child: CircularProgressIndicator());
          } else if (vm.errorMessage != null) {
            bodyWidget = Center(child: Text(vm.errorMessage!));
          } else {
            // Build the list content widget.
            Widget listContent;
            if (visibleProjects.isEmpty) {
              listContent = const Center(child: Text('No matching projects found.'));
            } else {
              listContent = ListView.builder(
                padding: const EdgeInsets.only(top: 0, bottom: 96),
                itemCount: visibleProjects.length,
                itemBuilder: (BuildContext context, int index) {
                  ProjectModel project = visibleProjects[index];
                  double remaining = vm.getRemainingBudget(project);
                  bool isFavorited = vm.favorites.contains(
                    '${project.adminUid}_${project.projectCode}',
                  );

                  return MyProjectCard(
                    project: project,
                    remainingBudget: remaining,
                    isFavorited: isFavorited,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext routeContext) {
                            return ProjectDetailScreen(project: project);
                          },
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      vm.toggleFavorite(project);
                    },
                  );
                },
              );
            }

            bodyWidget = Column(
              children: [
                ProjectSearchBarWidget(
                  controller: _searchController,
                  onChanged: (String value) {
                    vm.updateKeyword(value);
                  },
                  onFilterTap: _openFilterDialog,
                ),
                Expanded(child: listContent),
              ],
            );
          }

          return Scaffold(
            backgroundColor: AppColors.screenBackground,
            appBar: AppBar(
              title: const Text('My Projects'),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext routeContext) {
                      return const JoinProjectScreen();
                    },
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
            body: bodyWidget,
          );
        },
      ),
    );
  }
}
