import 'package:expense_user/app_colors.dart';
import 'package:expense_user/models/project_model.dart';
import 'package:expense_user/view_models/join_project_view_model.dart';
import 'package:expense_user/views/project/project_card.dart';
import 'package:expense_user/views/project/widgets/project_filter_dialog.dart';
import 'package:expense_user/views/project/widgets/project_search_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screen that displays available projects for the user to join.
class JoinProjectScreen extends StatefulWidget {
  const JoinProjectScreen({super.key});

  @override
  State<JoinProjectScreen> createState() {
    return _JoinProjectScreenState();
  }
}

class _JoinProjectScreenState extends State<JoinProjectScreen> {
  late JoinProjectViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = JoinProjectViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // Displays a snackbar message.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  // Shows a confirmation dialog asking the user to join a project.
  Future<bool?> _showJoinConfirmation(ProjectModel project) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Join Project'),
          content: Text('Do you want to join "${project.projectName}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Shows a dialog to enter a password for a locked project.
  Future<String?> _showPasswordDialog(ProjectModel project) async {
    String typedPassword = '';

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Enter Password for ${project.projectName}'),
          content: TextField(
            obscureText: true,
            onChanged: (String value) {
              typedPassword = value.trim();
            },
            onSubmitted: (String value) {
              Navigator.of(dialogContext).pop(typedPassword);
            },
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(typedPassword);
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  // Handles the user tapping on a project card to join it.
  Future<void> _handleProjectTap(ProjectModel project) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      _showMessage('Please log in first.');
      return;
    }

    // Check if the user already joined this project.
    if (project.isParticipant(currentUserUid)) {
      _showMessage('You already joined this project.');
      return;
    }

    // Handle locked projects by showing a password dialog.
    if (project.isLocked) {
      String? enteredPassword = await _showPasswordDialog(project);
      if (enteredPassword == null) {
        return;
      }

      if (!_viewModel.passwordMatches(
        enteredPassword,
        project.projectPasswordEncrypted ?? '',
      )) {
        _showMessage('Wrong Password');
        return;
      }

      try {
        await _viewModel.joinProject(project);
        if (mounted) {
          _showMessage('Joined project successfully.');
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Failed to join project.');
        }
      }
      return;
    }

    // Handle unlocked projects by showing a confirmation dialog.
    bool? shouldJoin = await _showJoinConfirmation(project);
    if (shouldJoin == true) {
      try {
        await _viewModel.joinProject(project);
        if (mounted) {
          _showMessage('Joined project successfully.');
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Failed to join project.');
        }
      }
    }
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

  // Builds the main UI for the join project screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JoinProjectViewModel>.value(
      value: _viewModel,
      child: Consumer<JoinProjectViewModel>(
        builder: (BuildContext context, JoinProjectViewModel vm, Widget? child) {
          String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
          List<ProjectModel> visibleProjects = vm.getFilteredProjects();

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
                padding: const EdgeInsets.only(top: 0, bottom: 24),
                itemCount: visibleProjects.length,
                itemBuilder: (BuildContext context, int index) {
                  ProjectModel project = visibleProjects[index];
                  bool isJoined = project.isParticipant(currentUserUid);

                  return ProjectCard(
                    project: project,
                    showJoinedBadge: isJoined,
                    onTap: () {
                      _handleProjectTap(project);
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
              title: const Text('Join Projects'),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
            ),
            body: bodyWidget,
          );
        },
      ),
    );
  }
}

