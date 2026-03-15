import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_navbar.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  final currentController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  double passwordStrength = 0;

  void checkPasswordStrength(String value) {

    int passed = 0;

    if (value.length >= 6) passed++;
    if (value.contains(RegExp(r'[A-Z]'))) passed++;
    if (value.contains(RegExp(r'[0-9]'))) passed++;

    setState(() {
      passwordStrength = passed / 3;
    });
  }

  Color getStrengthColor() {

    if (passwordStrength < 0.25) return Colors.red;
    if (passwordStrength < 0.5) return Colors.orange;
    if (passwordStrength < 0.75) return Colors.yellow;
    return Colors.green;

  }

  Future<void> changePassword() async {

    final newPass = newPasswordController.text.trim();
    final confirm = confirmController.text.trim();

    if (newPass.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru tidak boleh kosong")),
      );

      return;
    }

    if (newPass != confirm) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama")),
      );

      return;
    }

    setState(() => loading = true);

    try {

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password berhasil diganti")),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengganti password: $e")),
      );

    } finally {

      if (mounted) setState(() => loading = false);

    }
  }

  Widget passwordRule(String text, bool valid) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [

          Icon(
            valid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: valid ? Colors.green : Colors.grey,
          ),

          const SizedBox(width: 6),

          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: valid ? Colors.green : Colors.grey,
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final pass = newPasswordController.text;
    final confirm = confirmController.text;

    return Scaffold(

      appBar: const AppNavbar(title: "Change Password"),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(AppSpacing.lg),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Icon(
                Icons.lock_reset,
                size: 72,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                "Update Your Password",
                textAlign: TextAlign.center,
                style: AppTextStyles.heading,
              ),

              const SizedBox(height: AppSpacing.xl),

              Card(

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),

                child: Padding(

                  padding: const EdgeInsets.all(AppSpacing.lg),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [

                      Text(
                        "Change Password",
                        style: AppTextStyles.subheading,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// CURRENT PASSWORD
                      TextField(
                        controller: currentController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          hintText: "Current Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      /// NEW PASSWORD
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        onChanged: (value) {
                          checkPasswordStrength(value);
                        },
                        decoration: InputDecoration(
                          hintText: "New Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      LinearProgressIndicator(
                        value: passwordStrength,
                        minHeight: 6,
                        color: getStrengthColor(),
                        backgroundColor: Colors.grey.shade300,
                      ),

                      const SizedBox(height: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          passwordRule("Minimal 6 karakter", pass.length >= 6),

                          passwordRule(
                            "Mengandung huruf besar",
                            pass.contains(RegExp(r'[A-Z]')),
                          ),

                          passwordRule(
                            "Mengandung angka",
                            pass.contains(RegExp(r'[0-9]')),
                          ),

                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      /// CONFIRM PASSWORD
                      TextField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (confirm.isNotEmpty)
                        Row(
                          children: [

                            Icon(
                              confirm == pass
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 16,
                              color: confirm == pass
                                  ? Colors.green
                                  : Colors.red,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              confirm == pass
                                  ? "Password cocok"
                                  : "Password tidak sama",
                              style: TextStyle(
                                fontSize: 12,
                                color: confirm == pass
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),

                          ],
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : changePassword,
                          child: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Update Password"),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}