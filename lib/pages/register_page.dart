import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_navbar.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;

  bool obscurePassword = true;
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
    if (passwordStrength < 0.3) return Colors.red;
    if (passwordStrength < 0.5) return Colors.orange;
    if (passwordStrength < 0.7) return Colors.yellow;
    return Colors.green;
  }

  Future<void> register() async {

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama, email, dan password tidak boleh kosong"),
        ),
      );

      return;
    }

    if (password != confirmPassword) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password tidak sama"),
        ),
      );

      return;
    }

    if (password.length < 6) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password minimal 6 karakter"),
        ),
      );

      return;
    }

    setState(() => loading = true);

    try {

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (!mounted) return;

      if (response.user == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register gagal")),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register berhasil! Silakan login")),
        );

        Navigator.pop(context);

      }

    } on AuthException catch (e) {

      var errorMessage = e.message;

      if (errorMessage.toLowerCase().contains('already registered')) {
        errorMessage = "Email sudah terdaftar";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register gagal: $errorMessage')),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register gagal: $e")),
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

    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;

    return Scaffold(

      appBar: const AppNavbar(title: 'Register'),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(AppSpacing.lg),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Icon(
                Icons.catching_pokemon,
                size: 72,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                "Pokemon TCG Collection",
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
                        "Create Account",
                        style: AppTextStyles.subheading,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Nama",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        onChanged: (value) {
                          checkPasswordStrength(value);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
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

                      const SizedBox(height: 6),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          passwordRule(
                            "Minimal 6 karakter",
                            pass.length >= 6,
                          ),

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

                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock_outline),
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
                          onPressed: loading ? null : register,
                          child: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Register"),
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