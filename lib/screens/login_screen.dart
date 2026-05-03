import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'citizen_dashboard.dart';
import 'officer_dashboard.dart';
import 'admin_dashboard.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../complaint_store.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

// DEV: Hardcoded admin credentials for local testing only.
// WARNING: Never ship these to production. Remove before release.
const bool _useHardcodedAdmin = true;
const String _devAdminEmail = 'admin@gmail.com';
const String _devAdminPassword = 'admin123';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.danger),
    );
  }

  Widget _dashboardForRole(String role) {
    if (role == UserRole.officer) return const OfficerDashboardScreen();
    if (role == UserRole.admin) return const AdminDashboardScreen();
    return const CitizenDashboard();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _showError('Enter your password to continue.');
      return;
    }

    try {
      // Dev-only fallback: if enabled and credentials match, create a local admin profile
      if (_useHardcodedAdmin && email == _devAdminEmail && password == _devAdminPassword) {
        const devUid = 'dev_admin_uid';
        await FirebaseService.createUserProfile(
          uid: devUid,
          name: 'Dev Admin',
          email: email,
          role: UserRole.admin,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        return;
      }

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        _showError('Login failed. Please try again.');
        return;
      }

      var profile = await FirebaseService.getUserProfile(user.uid);
      String storedRole;

      if (profile == null) {
        // Check token claims for an admin flag
        final idToken = await user.getIdTokenResult(true);
        final claims = idToken.claims ?? {};
        if (claims['admin'] == true || (claims['role'] is String && (claims['role'] as String).toLowerCase() == 'admin')) {
          storedRole = UserRole.admin;
        } else {
          // Try finding a user profile by email (maybe created earlier with different uid)
          final q = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();
          if (q.docs.isNotEmpty) {
            final doc = q.docs.first;
            final data = doc.data();
            storedRole = (data['role'] as String?) ?? UserRole.citizen;
            // Create a profile under this uid for easier lookups next time
            await FirebaseService.createUserProfile(
              uid: user.uid,
              name: data['name'] as String? ?? email.split('@').first,
              email: email,
              role: storedRole,
              department: data['department'] as String?,
            );
          } else {
            // No profile found: offer to register this account as Admin (useful when admin only created in Auth)
            final createAsAdmin = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No profile found'),
                content: const Text('No Firestore profile exists for this account. Create an Admin profile for this signed-in user?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                ],
              ),
            );

            if (createAsAdmin == true) {
              final displayName = user.displayName ?? email.split('@').first;
              await FirebaseService.createUserProfile(
                uid: user.uid,
                name: displayName,
                email: email,
                role: UserRole.admin,
              );
              storedRole = UserRole.admin;
            } else {
              storedRole = UserRole.citizen;
            }
          }
        }
      } else {
        storedRole = profile['role'] as String? ?? UserRole.citizen;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _dashboardForRole(storedRole)),
      );
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? 'Unable to sign in.');
    } catch (_) {
      _showError('Unable to sign in. Please try again.');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;
    final contentWidth = size.width > 700 ? 480.0 : size.width * 0.92;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
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
                      borderRadius: BorderRadius.circular(26),
                      color: Colors.white.withValues(alpha: 0.96),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2A000000),
                          blurRadius: 30,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 86,
                            height: 86,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: const Color(0xFFEAF4FF),
                              border: Border.all(
                                color: const Color(0xFFBFDCF7),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/smart_city.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: isSmall ? 24 : 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.headingOnLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            'Sign in to continue managing your city services.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF5A7288),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23435C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            hintText: 'name@company.com',
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23435C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
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
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New here? ',
                              style: TextStyle(color: Color(0xFF587286)),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create account',
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
}
