import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_spacing.dart';
import 'package:flutter_application_1/core/utils/app_snackbar.dart';
import 'package:flutter_application_1/core/utils/haptic_utils.dart';
import 'package:flutter_application_1/core/widgets/animated_tab_selector.dart';
import 'package:flutter_application_1/core/widgets/app_primary_button.dart';
import 'package:flutter_application_1/core/widgets/app_text_field.dart';
import 'package:flutter_application_1/core/widgets/social_login_button.dart';
import 'package:flutter_application_1/core/widgets/stackflow_logo.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/routes/app_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  int _tabIndex = 0;
  AppButtonState _buttonState = AppButtonState.idle;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isLogin => _tabIndex == 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _buttonState = AppButtonState.loading);
    await HapticUtils.light();

    try {
      if (_isLogin) {
        await ref.read(authStateProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text,
            );
      } else {
        await ref.read(authStateProvider.notifier).register(
              _emailController.text.trim(),
              _passwordController.text,
              name: _nameController.text.trim(),
            );
      }

      if (mounted) {
        setState(() => _buttonState = AppButtonState.success);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _buttonState = AppButtonState.idle);
        AppSnackbar.show(
          context,
          message: e.toString().replaceFirst('ApiException: ', ''),
          isError: true,
        );
      }
    }
  }

  void _socialLogin(String provider) {
    HapticUtils.selection();
    AppSnackbar.show(
      context,
      message: 'Inicio con $provider no disponible. Usa email y contraseña.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                const StackflowLogo().animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'STACKFLOW',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: AppSpacing.xxxl),
                AnimatedTabSelector(
                  tabs: const ['Inicio de sesión', 'Registro'],
                  selectedIndex: _tabIndex,
                  onChanged: (index) => setState(() => _tabIndex = index),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: AppSpacing.xxl),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey(_tabIndex),
                    children: [
                      AppTextField(
                        label: 'Correo Electrónico',
                        controller: _emailController,
                        placeholder: 'name@company.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El correo es requerido';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Formato de correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        placeholder: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es requerida';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Nombre',
                          controller: _nameController,
                          placeholder: 'Tu nombre',
                          icon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Confirmar Contraseña',
                          controller: _confirmPasswordController,
                          placeholder: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppPrimaryButton(
                  label: _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                  state: _buttonState,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SocialDivider(),
                const SizedBox(height: AppSpacing.xl),
                SocialLoginButton(
                  label: 'Google',
                  icon: _GoogleIcon(),
                  onPressed: () => _socialLogin('Google'),
                ),
                const SizedBox(height: AppSpacing.md),
                SocialLoginButton(
                  label: 'GitHub',
                  icon: const Icon(Icons.code,
                      color: AppColors.textPrimary, size: 22),
                  onPressed: () => _socialLogin('GitHub'),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      2.5,
      true,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.0,
      1.5,
      true,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.5,
      1.2,
      true,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      4.7,
      1.8,
      true,
      red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
