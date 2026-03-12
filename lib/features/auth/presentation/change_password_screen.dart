import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../application/auth_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _inlineError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_validateInputs()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authApiProvider)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            password: _newPasswordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = _extractErrorMessage(e);
      setState(() => _inlineError = message);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      const message = 'Could not change password.';
      setState(() => _inlineError = message);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateInputs() {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      setState(() => _inlineError = 'Current password is required');
      return false;
    }
    if (next.isEmpty) {
      setState(() => _inlineError = 'New password is required');
      return false;
    }
    if (next.length < 8) {
      setState(() => _inlineError = 'Password must be at least 8 characters');
      return false;
    }
    if (confirm != _newPasswordController.text) {
      setState(() => _inlineError = 'Passwords do not match');
      return false;
    }

    if (_inlineError != null) {
      setState(() => _inlineError = null);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isCupertino = isCupertinoPlatform(context);

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Change Password'),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x1A696CFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update your account password',
                        style: CupertinoTheme.of(
                          context,
                        ).textTheme.navTitleTextStyle,
                      ),
                      const SizedBox(height: 14),
                      CupertinoTextField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        placeholder: 'Current Password',
                        onSubmitted: (_) => _submit(),
                        suffix: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                          child: Icon(
                            _obscureCurrent
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        placeholder: 'New Password',
                        onSubmitted: (_) => _submit(),
                        suffix: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          child: Icon(
                            _obscureNew
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'At least 8 characters',
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              color: CupertinoColors.systemGrey,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        placeholder: 'Confirm New Password',
                        onSubmitted: (_) => _submit(),
                        suffix: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          child: Icon(
                            _obscureConfirm
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            size: 18,
                          ),
                        ),
                      ),
                      if ((_inlineError ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _inlineError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                )
                              : const Text('Change Password'),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update your account password',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        helperText: 'At least 8 characters',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    if ((_inlineError ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _inlineError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Change Password'),
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

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final first = errors.values.cast<dynamic>().firstWhere(
          (value) => value is List && value.isNotEmpty,
          orElse: () => null,
        );

        if (first is List && first.isNotEmpty) {
          final message = first.first?.toString().trim();
          if (message != null && message.isNotEmpty) {
            return message;
          }
        }
      }

      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return 'Could not change password.';
  }
}
