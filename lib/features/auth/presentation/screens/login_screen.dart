import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/auth_service.dart';
import '../../../../shared/widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess && result.user != null) {
      if (mounted) {
        // Navigate based on role
        switch (result.user!.role) {
          case UserRole.superAdmin:
            context.go('/admin/dashboard');
            break;
          case UserRole.manager:
            context.go('/manager/dashboard');
            break;
          case UserRole.technician:
            context.go('/technician/tickets');
            break;
        }
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppDimensions.mobileBreakpoint;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.2 : AppDimensions.paddingXL,
              vertical: AppDimensions.paddingXL,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    const Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: _LoginLogoWrapper(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.h2.copyWith(
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue to Makina AI',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.critical.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: AppColors.critical.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.critical,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.critical,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Login button
                    SizedBox(
                      height: AppDimensions.buttonHeightL,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: AppTextStyles.buttonLarge,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Theme toggle
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          final currentMode = ref.read(themeModeProvider);
                          ref.read(themeModeProvider.notifier).state =
                              currentMode == ThemeMode.light
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                        },
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          size: 20,
                        ),
                        label: Text(
                          isDark ? 'Light Mode' : 'Dark Mode',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Demo credentials
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightGrey,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Credentials',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCredentialRow(
                            'Super Admin',
                            'admin@makina.ai',
                            'Admin123!',
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _buildCredentialRow(
                            'Manager',
                            'manager@makina.ai',
                            'Manager123!',
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _buildCredentialRow(
                            'Technician',
                            'tech@makina.ai',
                            'Tech123!',
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(
    String role,
    String email,
    String password,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryDarkGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              ),
              child: Text(
                role,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryDarkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginLogoWrapper extends StatelessWidget {
  const _LoginLogoWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the asset logo when available; AppLogo falls back to 'M'
    return const AppLogo(width: 100, height: 100, borderRadius: 25);
  }
}
