import 'package:expense_user/app_colors.dart';
import 'package:expense_user/view_models/setting_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Settings screen with profile, account management, preferences, and logout.
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen> {
  late SettingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Shows the change password dialog with old, new, and confirm fields.
  void _showChangePasswordDialog(SettingViewModel vm) {
    TextEditingController oldPassCtrl = TextEditingController();
    TextEditingController newPassCtrl = TextEditingController();
    TextEditingController confirmPassCtrl = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setDialogState) {
            Icon oldVisibilityIcon = obscureOld
                ? const Icon(Icons.visibility_off_outlined, size: 20)
                : const Icon(Icons.visibility_outlined, size: 20);

            Icon newVisibilityIcon = obscureNew
                ? const Icon(Icons.visibility_off_outlined, size: 20)
                : const Icon(Icons.visibility_outlined, size: 20);

            Icon confirmVisibilityIcon = obscureConfirm
                ? const Icon(Icons.visibility_off_outlined, size: 20)
                : const Icon(Icons.visibility_outlined, size: 20);

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.indigoLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.lock_outline,
                                color: AppColors.primaryBlue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your current password and choose a new one.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.slateGray,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: oldPassCtrl,
                        obscureText: obscureOld,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: oldVisibilityIcon,
                            onPressed: () {
                              setDialogState(() {
                                obscureOld = !obscureOld;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        validator: (String? v) {
                          if (v == null || v.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: newPassCtrl,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon:
                              const Icon(Icons.lock_reset_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: newVisibilityIcon,
                            onPressed: () {
                              setDialogState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        validator: (String? v) {
                          if (v == null || v.isEmpty) {
                            return 'Required';
                          }
                          if (v.length < 6) {
                            return 'At least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmPassCtrl,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon:
                              const Icon(Icons.check_circle_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: confirmVisibilityIcon,
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                        validator: (String? v) {
                          if (v == null || v.isEmpty) {
                            return 'Required';
                          }
                          if (v != newPassCtrl.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: vm.isChangingPassword
                                  ? null
                                  : () {
                                      Navigator.pop(ctx);
                                    },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side:
                                    const BorderSide(color: AppColors.borderLight),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: vm.isChangingPassword
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      try {
                                        await vm.changePassword(
                                          oldPassCtrl.text.trim(),
                                          newPassCtrl.text.trim(),
                                          confirmPassCtrl.text.trim(),
                                        );

                                        if (ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }

                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Password changed successfully!'),
                                              backgroundColor:
                                                  AppColors.successGreen,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        _showErrorSnackBar(
                                          vm.errorMessage ??
                                              'Failed to change password',
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: vm.isChangingPassword
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Update Password'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Shows an error snackbar with red background.
  void _showErrorSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  // Shows the logout confirmation dialog.
  void _showLogoutDialog(SettingViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Out',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to log out?',
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await vm.logout();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // Shows the reset confirmation dialog.
  void _showResetDatabaseDialog(SettingViewModel vm) {
    showDialog(
      context: context,
      barrierDismissible: !vm.isResettingDatabase,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reset Database',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text(
            'This will remove your joined projects and favorites. Continue?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: vm.isResettingDatabase
                  ? null
                  : () {
                      Navigator.pop(ctx);
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: vm.isResettingDatabase
                  ? null
                  : () async {
                      try {
                        await vm.resetDatabase();
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Database reset completed.'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        }
                      } catch (_) {
                        _showErrorSnackBar(
                          vm.errorMessage ?? 'Failed to reset database',
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: vm.isResettingDatabase
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.slateGray,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Color iconColor = AppColors.textSecondary,
    Color titleColor = AppColors.textPrimary,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    List<Widget> subtitleWidgets = [];
    if (subtitle != null) {
      subtitleWidgets.add(const SizedBox(height: 2));
      subtitleWidgets.add(
        Text(subtitle,
            style: const TextStyle(
                fontSize: 13, color: AppColors.slateGray)),
      );
    }

    List<Widget> trailingWidgets = [];
    if (trailing != null) {
      trailingWidgets.add(trailing);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  ...subtitleWidgets,
                ],
              ),
            ),
            ...trailingWidgets,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      color: AppColors.surfaceLight,
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingViewModel>.value(
      value: _viewModel,
      child: Consumer<SettingViewModel>(
        builder: (BuildContext context, SettingViewModel vm, Widget? child) {
          User? user = FirebaseAuth.instance.currentUser;
          String email = user?.email ?? '-';

          return Scaffold(
            backgroundColor: AppColors.screenBackground,
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.indigoLight,
                                    child: Icon(Icons.person,
                                        size: 36, color: AppColors.primaryBlue),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'User',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.slateGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _buildSectionHeader('ACCOUNT & DATA'),
                        _buildCard(
                          children: [
                            _buildSettingsRow(
                              icon: Icons.lock_outline,
                              title: 'Change Password',
                              subtitle: 'Update your account password',
                              onTap: () {
                                _showChangePasswordDialog(vm);
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              icon: Icons.restart_alt,
                              title: 'Reset Database',
                              subtitle: 'Clear all projects and expenses',
                              iconColor: AppColors.errorRed,
                              titleColor: AppColors.errorRed,
                              onTap: () {
                                _showResetDatabaseDialog(vm);
                              },
                            ),
                          ],
                        ),
                        _buildSectionHeader('PREFERENCES'),
                        _buildCard(
                          children: [
                            _buildSettingsRow(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              trailing: Switch(
                                value: vm.notificationsEnabled,
                                activeTrackColor: AppColors.primaryBlue,
                                onChanged: (bool v) {
                                  vm.toggleNotifications();
                                },
                              ),
                            ),
                            _buildDivider(),
                            _buildSettingsRow(
                              icon: Icons.dark_mode_outlined,
                              title: 'Dark Mode',
                              trailing: Switch(
                                value: vm.darkModeEnabled,
                                activeTrackColor: AppColors.primaryBlue,
                                onChanged: (bool v) {
                                  vm.toggleDarkMode();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            _showLogoutDialog(vm);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

