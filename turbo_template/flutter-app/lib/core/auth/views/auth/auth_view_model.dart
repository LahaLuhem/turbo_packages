import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo_firestore_api/constants/t_values.dart';
import 'package:turbo_flutter_template/core/auth/enums/auth_view_mode.dart';
import 'package:turbo_flutter_template/core/auth/forms/forgot_password_form.dart';
import 'package:turbo_flutter_template/core/auth/forms/login_form.dart';
import 'package:turbo_flutter_template/core/auth/forms/register_form.dart';
import 'package:turbo_flutter_template/core/auth/globals/g_now.dart';
import 'package:turbo_flutter_template/core/auth/services/auth_service.dart';
import 'package:turbo_flutter_template/core/auth/services/email_service.dart';
import 'package:turbo_flutter_template/core/environment/enums/environment.dart';
import 'package:turbo_flutter_template/core/environment/globals/g_env.dart';
import 'package:turbo_flutter_template/core/infrastructure/enums/t_route.dart';
import 'package:turbo_flutter_template/core/l10n/globals/g_context.dart';
import 'package:turbo_flutter_template/core/l10n/globals/g_strings.dart';
import 'package:turbo_flutter_template/core/shared/extensions/duration_extension.dart';
import 'package:turbo_flutter_template/core/state/manage-state/abstracts/t_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/extensions/context_extension.dart';
import 'package:turbo_flutter_template/core/state/manage-state/models/contextual_button_entry.dart';
import 'package:turbo_flutter_template/core/state/manage-state/utils/min_duration_completer.dart';
import 'package:turbo_flutter_template/core/storage/save-local-data/services/local_storage_service.dart';
import 'package:turbo_flutter_template/core/ui/constants/t_durations.dart';
import 'package:turbo_flutter_template/core/ux/services/dialog_service.dart';
import 'package:turbo_flutter_template/core/ux/services/toast_service.dart';
import 'package:turbo_flutter_template/core/ux/services/url_launcher_service.dart';
import 'package:turbo_forms/turbo_forms.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/t_notifier.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbolytics/turbolytics.dart';

import '../../../state/manage-state/extensions/completer_extension.dart';
import '../../../state/manage-state/utils/mutex.dart';

class AuthViewModel extends TViewModel
    with Turbolytics, TBusyServiceManagement {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static AuthViewModel get locate => GetIt.I.get();
  static void registerFactory() => GetIt.I.registerFactory(AuthViewModel.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  DialogService get _dialogService => DialogService.locate;
  final _authService = AuthService.locate;
  final _emailService = EmailService.locate;
  final _firebaseAuth = FirebaseAuth.instance;
  final _localStorageService = LocalStorageService.locate;
  final _toastService = ToastService.locate;
  final _urlLauncherService = UrlLauncherService.locate;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await _authService.isReady;
    await _canInit.future;
    _authViewMode.addListener(_onAuthViewModeChanged);
    _showAgreeToPrivacyCheckBox.addListener(_onShowAgreePrivacyCheckbox);
    _onAuthViewModeChanged();
    _onShowAgreePrivacyCheckbox();
    if (Environment.isEmulators) {
      _loginForm.email.updateValue('appboy@apewpew.app');
      _loginForm.password.updateValue('123123123');
    }
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  Future<void> dispose() async {
    _authViewMode.removeListener(_onAuthViewModeChanged);
    _showAgreeToPrivacyCheckBox.removeListener(_onShowAgreePrivacyCheckbox);
    loginButtonFocusNode.dispose();
    registerButtonFocusNode.dispose();
    _resetPasswordTimer?.cancel();
    await super.dispose();
  }

  TRoute? get contextualButtonsRoute => null;

  List<ContextualButtonEntry> get contextualButtons => const [];

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  DateTime? _forgotPasswordAt;
  Timer? _resetPasswordTimer;
  bool _isResetPasswordCooldownActive = false;
  final Completer _canInit = Completer();
  final FocusNode loginButtonFocusNode = FocusNode();
  final FocusNode registerButtonFocusNode = FocusNode();
  final FocusNode sendForgotPasswordFocusNode = FocusNode();
  final _authViewMode = TNotifier<AuthViewMode>(AuthViewMode.defaultValue);
  final _forgotPasswordForm = ForgotPasswordForm.locate;
  final _loginForm = LoginForm.locate;
  final _registerForm = RegisterForm.locate;
  final _showAgreeToPrivacyCheckBox = TNotifier<bool>(false);

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  final _animationDurationCompleter = MinDurationCompleter(
    TDurations.animation,
  );
  final _mutex = Mutex();
  static const _kResetPasswordCooldown = Duration(minutes: 1);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  int get _remainingSeconds => _forgotPasswordAt == null
      ? 0
      : _kResetPasswordCooldown.inSeconds -
            gNow.difference(_forgotPasswordAt!).inSeconds;

  bool canPop({required BuildContext context}) => context.canPop();

  DateTime? get acceptedPrivacyAndTermsAt =>
      (_registerForm.agreePrivacy.data.value ?? false) ? gNow : null;

  ValueListenable<bool> get showAgreeToPrivacyCheckBox =>
      _showAgreeToPrivacyCheckBox;
  ValueListenable<AuthViewMode> get authViewMode => _authViewMode;

  TFormFieldConfig<String> get emailField {
    switch (_authViewMode.value) {
      case AuthViewMode.login:
        return _loginForm.email;
      case AuthViewMode.register:
        return _registerForm.email;
      case AuthViewMode.forgotPassword:
        return _forgotPasswordForm.email;
    }
  }

  TFormFieldConfig<String> get passwordField {
    switch (_authViewMode.value) {
      case AuthViewMode.login:
        return _loginForm.password;
      case AuthViewMode.register:
        return _registerForm.password;
      case AuthViewMode.forgotPassword:
        return _loginForm.password;
    }
  }

  TFormFieldConfig<String> get confirmPasswordField =>
      _registerForm.confirmPassword;
  TFormFieldConfig<bool> get agreePrivacyField => _registerForm.agreePrivacy;

  bool get isResetPasswordCooldownActive => _isResetPasswordCooldownActive;

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\

  void _updateAuthViewMode(AuthViewMode authViewMode) {
    // Clear focus immediately before changing mode
    FocusManager.instance.primaryFocus?.unfocus();
    _authViewMode.update(authViewMode);
  }

  void _restoreFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb) {
        await TDurations.animation.asFuture;
      }
      switch (authViewMode.value) {
        case AuthViewMode.login:
          if (_loginForm.email.valueTrimIsEmpty) {
            _loginForm.email.requestFocus();
          } else if (_loginForm.password.valueTrimIsEmpty) {
            _loginForm.password.requestFocus();
          } else {
            loginButtonFocusNode.requestFocus();
          }
          break;
        case AuthViewMode.register:
          if (_registerForm.email.valueTrimIsEmpty) {
            _registerForm.email.requestFocus();
          } else if (_registerForm.password.valueTrimIsEmpty) {
            _registerForm.password.requestFocus();
          } else if (_registerForm.confirmPassword.valueTrimIsEmpty) {
            _registerForm.confirmPassword.requestFocus();
          } else {
            registerButtonFocusNode.requestFocus();
          }
          break;
        case AuthViewMode.forgotPassword:
          if (_forgotPasswordForm.email.valueTrimIsEmpty) {
            _forgotPasswordForm.email.requestFocus();
          } else {
            sendForgotPasswordFocusNode.requestFocus();
          }
          break;
      }
    });
  }

  Future<void> _tryCreateUserDocAndNextView({
    required String userId,
    required String email,
  }) async {
    await _authService.isReady;
    await _localStorageService.isReady;
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void _onShowAgreePrivacyCheckbox() =>
      _registerForm.agreePrivacy.focusNode.skipTraversal =
          !_showAgreeToPrivacyCheckBox.value;

  void _onAuthViewModeChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      switch (_authViewMode.value) {
        case AuthViewMode.login:
          loginButtonFocusNode.skipTraversal = false;
          _loginForm.email.focusNode.skipTraversal = false;
          _loginForm.password.focusNode.skipTraversal = false;
          registerButtonFocusNode.skipTraversal = false;
          _registerForm.confirmPassword.focusNode.skipTraversal = true;
          sendForgotPasswordFocusNode.skipTraversal = true;
          _registerForm.agreePrivacy.focusNode.skipTraversal = true;
          break;
        case AuthViewMode.register:
          _registerForm.email.focusNode.skipTraversal = false;
          _registerForm.password.focusNode.skipTraversal = false;
          _registerForm.confirmPassword.focusNode.skipTraversal = false;
          registerButtonFocusNode.skipTraversal = false;
          _registerForm.agreePrivacy.focusNode.skipTraversal = false;
          loginButtonFocusNode.skipTraversal = true;
          sendForgotPasswordFocusNode.skipTraversal = true;
          break;
        case AuthViewMode.forgotPassword:
          _forgotPasswordForm.email.focusNode.skipTraversal = false;
          sendForgotPasswordFocusNode.skipTraversal = false;
          loginButtonFocusNode.skipTraversal = false;
          _loginForm.password.focusNode.skipTraversal = true;
          _registerForm.password.focusNode.skipTraversal = true;
          _registerForm.confirmPassword.focusNode.skipTraversal = true;
          registerButtonFocusNode.skipTraversal = true;
          _registerForm.agreePrivacy.focusNode.skipTraversal = true;
          break;
      }
    });
  }

  Future<void> onPrivacyPolicyPressed({required BuildContext context}) async {
    try {
      final shouldVisit = await _dialogService.showOkCancelDialog(
        title: context.strings.privacyPolicy,
        message: context.strings.doYouWantToVisitThePrivacyPolicy,
        context: context,
      );
      if (shouldVisit != true) return;

      setBusy(isBusy, busyType: TBusyType.indicatorBackdropIgnorePointer);
      await _urlLauncherService.tryLaunchUrl(url: TValues.noAuthId);
    } catch (error, stackTrace) {
      log.error(
        'Unexpected ${error.runtimeType} caught while trying to launch privacy policy url!',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> onTermsOfServicePressed({required BuildContext context}) async {
    try {
      final shouldVisit = await _dialogService.showOkCancelDialog(
        title: context.strings.termsOfService,
        message: context.strings.doYouWantToVisitTheTermsOfService,
        context: context,
      );
      if (shouldVisit != true) return;

      setBusy(isBusy, busyType: TBusyType.indicatorBackdropIgnorePointer);
      await _urlLauncherService.tryLaunchUrl(url: gConfig.privacyPolicyUrl);
    } catch (error, stackTrace) {
      log.error(
        'Unexpected ${error.runtimeType} caught while trying to launch terms of service url!',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> onForgotPasswordBackPressed() async {
    _updateAuthViewMode(AuthViewMode.login);
    _animationDurationCompleter.start();

    _loginForm.email.updateValue(_forgotPasswordForm.email.cValue);

    await _animationDurationCompleter.future;
  }

  Future<void> onLoginPressed({
    required AuthViewMode authViewMode,
    required BuildContext context,
  }) async {
    if (isBusy) {
      return;
    }
    await _mutex.lockAndRun(
      run: (unlock) async {
        try {
          switch (authViewMode) {
            case AuthViewMode.login:
              if (_loginForm.isValid) {
                setBusy(
                  true,
                  busyType: TBusyType.indicatorBackdropIgnorePointer,
                );

                final email = _loginForm.email.cValue!;
                final password = _loginForm.password.cValue!;
                final authResponse = await _emailService.login(
                  email: email,
                  password: password,
                );

                authResponse.when(
                  success: (response) {
                    _toastService.showToast(
                      context: gContext ?? context,
                      title: gStrings.loggedInTitle,
                      subtitle: gStrings.welcomeBackTitle,
                    );
                  },
                  fail: (response) {
                    _toastService.showToast(
                      context: gContext ?? context,
                      title: gStrings.failedToLogInTitle,
                      subtitle: response.message,
                    );
                  },
                );

                if (!authResponse.isSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loginForm.password.requestFocus();
                  });
                }
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_loginForm.email.isNotValid) {
                    _loginForm.email.requestFocus();
                  } else if (_loginForm.password.isNotValid) {
                    _loginForm.password.requestFocus();
                  }
                });
              }
              break;
            case AuthViewMode.register:
              _updateAuthViewMode(AuthViewMode.login);
              _animationDurationCompleter.start();

              _loginForm.email.updateValue(_registerForm.email.cValue);
              _loginForm.password.updateValue(_registerForm.password.cValue);

              await _animationDurationCompleter.future;
              break;
            case AuthViewMode.forgotPassword:
              await onForgotPasswordBackPressed();
              break;
          }
        } catch (error, stackTrace) {
          log.error(
            'Exception caught while trying to register!',
            error: error,
            stackTrace: stackTrace,
          );
        } finally {
          unlock();
          setBusy(false);
          _restoreFocus();
        }
      },
    );
  }

  Future<void> onRegisterPressed({
    required AuthViewMode authViewMode,
    required BuildContext context,
  }) async => await _mutex.lockAndRun(
    run: (unlock) async {
      try {
        switch (authViewMode) {
          case AuthViewMode.login:
            _updateAuthViewMode(AuthViewMode.register);
            _animationDurationCompleter.start();

            _registerForm.email.updateValue(_loginForm.email.cValue);
            _registerForm.password.updateValue(_loginForm.password.cValue);

            await _animationDurationCompleter.future;
            break;
          case AuthViewMode.register:
            try {
              if (_registerForm.isValid) {
                setBusy(
                  true,
                  busyType: TBusyType.indicatorBackdropIgnorePointer,
                );

                final email = _registerForm.email.cValue!;
                final password = _registerForm.password.cValue!;
                final authResponse = await _emailService.register(
                  email: email,
                  password: password,
                );

                authResponse.when(success: (response) {}, fail: (response) {});

                await authResponse.when(
                  success: (response) async {
                    _toastService.showToast(
                      context: gContext ?? context,
                      title: gStrings.accountCreatedTitle,
                    );
                    final userId = authResponse.result.uid;
                    await _tryCreateUserDocAndNextView(
                      userId: userId,
                      email: email,
                    );
                  },
                  fail: (response) {
                    _toastService.showToast(
                      context: gContext ?? context,
                      title: gStrings.accountCreationFailedTitle,
                      subtitle: response.message,
                    );
                  },
                );
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_registerForm.email.isNotValid) {
                    _registerForm.email.requestFocus();
                  } else if (_registerForm.password.isNotValid) {
                    _registerForm.password.requestFocus();
                  } else if (_registerForm.confirmPassword.isNotValid) {
                    _registerForm.confirmPassword.requestFocus();
                  } else if (_registerForm.agreePrivacy.isNotValid) {
                    _registerForm.agreePrivacy.requestFocus();
                  }
                });
              }
            } catch (error, stackTrace) {
              log.error(
                'Unexpected ${error.runtimeType} caught while registering with email',
                error: error,
                stackTrace: stackTrace,
              );
            }
            break;
          case AuthViewMode.forgotPassword:
            _updateAuthViewMode(AuthViewMode.login);
            _animationDurationCompleter.start();

            _loginForm.email.updateValue(_forgotPasswordForm.email.cValue);

            await _animationDurationCompleter.future;
            break;
        }
      } catch (error, stackTrace) {
        log.error(
          'Exception caught while trying to register!',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        unlock();
        setBusy(false);
        _restoreFocus();
      }
    },
  );

  Future<void> onForgotPasswordPressed() async {
    await _mutex.lockAndRun(
      run: (unlock) async {
        try {
          _updateAuthViewMode(AuthViewMode.forgotPassword);
          _animationDurationCompleter.start();
          _forgotPasswordForm.email.updateValue(_loginForm.email.cValue);
          await _animationDurationCompleter.future;
        } catch (error, stackTrace) {
          log.error(
            'Exception caught while switching to forgot password mode',
            error: error,
            stackTrace: stackTrace,
          );
        } finally {
          unlock();
          setBusy(false);
          _restoreFocus();
        }
      },
    );
  }

  Future<void> onForgotPasswordSendPressed({
    required BuildContext context,
  }) async {
    try {
      if (_isResetPasswordCooldownActive) {
        final minutes = _remainingSeconds ~/ 60;
        final seconds = _remainingSeconds % 60;
        final message = minutes > 0
            ? gStrings.resetPasswordCooldownMessage(
                minutes.toString(),
                minutes == 1 ? gStrings.minute : gStrings.minutes,
                seconds.toString(),
                seconds == 1 ? gStrings.second : gStrings.seconds,
              )
            : gStrings.resetPasswordCooldownMessageSeconds(
                seconds.toString(),
                seconds == 1 ? gStrings.second : gStrings.seconds,
              );

        await _dialogService.showOkDialog(
          context: context,
          title: gStrings.pleaseWait,
          message: message,
        );
        return;
      }

      if (_forgotPasswordForm.email.isValid) {
        log.info('Sending password reset email.');
        _isResetPasswordCooldownActive = true;
        _forgotPasswordAt = gNow;
        _resetPasswordTimer?.cancel();
        _resetPasswordTimer = Timer(_kResetPasswordCooldown, () {
          _isResetPasswordCooldownActive = false;
        });

        unawaited(
          _firebaseAuth.sendPasswordResetEmail(
            email: _forgotPasswordForm.email.cValue!,
          ),
        );

        await _dialogService.showOkDialog(
          context: context,
          title: gStrings.resetPassword,
          message: gStrings.ifRegisteredWeSend(
            _forgotPasswordForm.email.cValue!,
          ),
        );
        if (context.mounted) {
          _updateAuthViewMode(AuthViewMode.login);
        }
        log.info('Password reset email sent.');
        _restoreFocus();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _forgotPasswordForm.email.requestFocus();
        });
      }
    } catch (error, stackTrace) {
      log.error(
        'Unexpected ${error.runtimeType} caught while sending password reset email.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      setBusy(false);
    }
  }

  void onConfirmPasswordChanged(String? value) =>
      _showAgreeToPrivacyCheckBox.update(value?.isNotEmpty == true);

  void onEmailSubmitted({required BuildContext context}) {
    switch (_authViewMode.value) {
      case AuthViewMode.login:
        if (_loginForm.email.isValid) {
          _loginForm.password.requestFocus();
        }
        break;
      case AuthViewMode.register:
        if (_registerForm.email.isValid) {
          _registerForm.password.requestFocus();
        }
        break;
      case AuthViewMode.forgotPassword:
        if (_forgotPasswordForm.email.isValid) {
          onForgotPasswordSendPressed(context: context);
        }
        break;
    }
  }

  void onPasswordSubmitted({
    required String value,
    required BuildContext context,
  }) {
    switch (_authViewMode.value) {
      case AuthViewMode.login:
        if (_loginForm.password.isValid) {
          onLoginPressed(authViewMode: _authViewMode.value, context: context);
        }
        break;
      case AuthViewMode.register:
        if (_registerForm.password.isValid) {
          _registerForm.confirmPassword.requestFocus();
        }
        break;
      case AuthViewMode.forgotPassword:
        break;
    }
  }

  void onConfirmPasswordSubmitted(String? _) {
    if (_registerForm.confirmPassword.isValid) {
      _registerForm.agreePrivacy.requestFocus();
    }
  }

  void onAppleAuthPressed() {}

  void onGoogleAuthPressed() {}

  Future<void> onComplete(AnimationController _) async {
    await TDurations.animation.asFuture;
    _canInit.completeIfNotComplete();
  }
}
