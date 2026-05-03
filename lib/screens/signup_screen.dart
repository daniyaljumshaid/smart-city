import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../complaint_store.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.danger),
    );
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    try {
      await FirebaseService.registerUser(
        name: name,
        email: email,
        password: password,
        role: UserRole.citizen,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? 'Unable to create account.');
    } catch (_) {
      _showError('Unable to create account. Please try again.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;
    final contentWidth = size.width > 700 ? 520.0 : size.width * 0.92;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C6BA8).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A8AC7).withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Container(
                    width: contentWidth,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A0C3758),
                          blurRadius: 26,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFFEAF4FF),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Color(0xFF0D649F),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Create your account',
                                style: TextStyle(
                                  fontSize: isSmall ? 23 : 27,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.headingOnLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join Smart City portal to report and track local issues faster.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF567085),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23435C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _authInput(
                          controller: _nameController,
                          hint: 'Your full name',
                          icon: Icons.badge_outlined,
                          inputType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23435C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _authInput(
                          controller: _emailController,
                          hint: 'name@company.com',
                          icon: Icons.mail_outline,
                          inputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23435C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _authInput(
                          controller: _passwordController,
                          hint: 'Create a strong password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23435C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _authInput(
                          controller: _confirmController,
                          hint: 'Re-enter your password',
                          icon: Icons.lock_reset,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _createAccount,
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(color: Color(0xFF587286)),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFF0E5A92),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Iterable<String>? autofillHints,
    Widget? trailing,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: trailing,
      ),
    );
  }
}
