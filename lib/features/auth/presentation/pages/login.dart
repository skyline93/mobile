import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    // 定义品牌色
    const Color primaryBlue = Color(0xFF4285F4);
    const Color primaryGreen = Color(0xFF34A853);
    const Color accentPurple = Color(0xFF9C27B0);
    const Color textDark = Color(0xFF1A1D2B);
    const Color textLight = Color(0xFF757575);
    const Color subtleGrey = Color(0xFFF0F2F5);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF8F9FC), subtleGrey],
          ),
        ),
        child: Stack(
          children: [
            // 动态光晕效果 - 右上角蓝色光晕
            AnimatedPositioned(
              duration: const Duration(seconds: 15),
              curve: Curves.easeInOut,
              top: -size.height * 0.25,
              right: -size.width * 0.5,
              child: Container(
                width: size.width * 1.2,
                height: size.width * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // 动态光晕效果 - 左下角绿色光晕
            AnimatedPositioned(
              duration: const Duration(seconds: 20),
              curve: Curves.easeInOut,
              bottom: -size.height * 0.3,
              left: -size.width * 0.4,
              child: Container(
                width: size.width * 1.0,
                height: size.width * 1.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryGreen.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),

            // 新增 - 中心紫色光晕
            Positioned(
              top: size.height * 0.3,
              left: size.width * 0.2,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentPurple.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.9],
                  ),
                ),
              ),
            ),

            // 主要登录表单内容
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // 增强的标题层级
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: textDark,
                                letterSpacing: -1.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Log in to your account',
                              style: TextStyle(
                                fontSize: 17,
                                color: textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.07),

                      // 优化的输入框
                      _buildTextField(
                        context: context,
                        hint: 'Email',
                        icon: Icons.email_rounded,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        context: context,
                        hint: 'Password',
                        icon: Icons.lock_rounded,
                        isPassword: true,
                      ),

                      // 忘记密码
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // 优化的渐变按钮
                      _AnimatedGradientButton(
                        text: 'Log In',
                        onPressed: () {},
                        gradient: const LinearGradient(
                          colors: [primaryBlue, primaryGreen],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 辅助操作 - 带轻微边框
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.15),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: textLight),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 优化的输入框构建方法
  Widget _buildTextField({
    required BuildContext context,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFBDBDBD),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: const Color(0xFFBDBDBD), size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          suffixIcon: isPassword
              ? IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 22),
            onPressed: () {},
            color: const Color(0xFFBDBDBD),
          )
              : null,
        ),
      ),
    );
  }
}

// 优化的渐变按钮Widget - 带动画效果
class _AnimatedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;

  const _AnimatedGradientButton({
    required this.text,
    required this.onPressed,
    required this.gradient,
  });

  @override
  State<_AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _scale = 0.97),
      onPointerUp: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4285F4).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}