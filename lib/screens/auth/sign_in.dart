import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/auth/auth_bloc.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/input_text_field.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:hajedi/widgets/text.dart';

class SignIn extends StatefulWidget {
	const SignIn({super.key});

	@override
	State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
	final _nameController = TextEditingController();
	final _passwordController = TextEditingController();

	@override
	void dispose() {
		_nameController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	void _login() {
		final name = _nameController.text.trim();
		final password = _passwordController.text;

		if (name.isEmpty || password.isEmpty) {
			final l10n = AppLocalizations.of(context)!;
			showAnimatedSnackBar(
				context,
				l10n.please_fill_all_fields,
				isSuccess: false,
			);
			return;
		}

		context.read<AuthBloc>().add(
					LoginRequested(
						name: name,
						password: password,
					),
				);
	}

	@override
	Widget build(BuildContext context) {
		final l10n = AppLocalizations.of(context)!;

		return Scaffold(
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 12),
						child: ConstrainedBox(
							constraints: const BoxConstraints(maxWidth: 420),
							child: BlocConsumer<AuthBloc, AuthState>(
								listener: (context, state) {
									if (state is LoginSuccessfully) {
										showAnimatedSnackBar(context, state.message);
                    Navigator.pushReplacementNamed(
                      context,
                      '/dashboard',
                    );
									} else if (state is LoginFailure) {
										showAnimatedSnackBar(
											context,
											state.message,
											isSuccess: false,
										);
									}
								},
								builder: (context, state) {
									return Column(
										mainAxisSize: MainAxisSize.min,
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											// Center(child: SimpleText(label: l10n.appTitle)),
											Center(
                        child: Text(l10n.appTitle,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ),
											const SizedBox(height: 32),
                      SimpleText(label: '${l10n.name}:'),
											InputTextField(
												controller: _nameController,
												labelText: l10n.name,
												hintText: l10n.name,
												keyboardType: TextInputType.name,
											),
											const SizedBox(height: 16),
                      SimpleText(label: '${l10n.password}:'),
											InputTextField(
												controller: _passwordController,
												labelText: l10n.password,
												hintText: l10n.password,
												obscureText: true,
											),
											const SizedBox(height: 24),
											PrimaryButton(
												onPressed: _login,
												label: l10n.login,
                        isLoading: state is LoginLoading,
											),
										],
									);
								},
							),
						),
					),
				),
			),
		);
	}
}
