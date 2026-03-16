import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_navbar.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

import 'main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool rememberMe = true;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() {

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {

      WidgetsBinding.instance.addPostFrameCallback((_) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );

      });

    }
  }

  Future<void> login() async {

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password tidak boleh kosong")),
      );

      return;
    }

    setState(() => loading = true);

    try {

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session == null || response.user == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Login gagal. Periksa kembali email dan password.",
            ),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );

      }

    } on AuthException catch (e) {

      final responseMessage = e.message;

      final message = responseMessage.toLowerCase().contains('confirm')
          ? 'Akun belum diverifikasi. Periksa email konfirmasi.'
          : responseMessage;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $message')),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );

    } finally {

      if (mounted) setState(() => loading = false);

    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      appBar: const AppNavbar(title: 'Login'),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              const SizedBox(height: AppSpacing.md),

              Icon(
                Icons.catching_pokemon,
                size: 72,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Pokemon TCG Collection',
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
                        "Masuk",
                        style: AppTextStyles.subheading,
                      ),

                      const SizedBox(height: AppSpacing.lg),

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

                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        children: [

                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? true;
                              });
                            },
                          ),

                          const Text("Remember me"),

                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          child: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      TextButton(

                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );

                        },

                        child: const Text(
                          "Belum punya akun? Register",
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
