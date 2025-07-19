import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/ui/bloc/auth_cubit.dart';
import 'package:social_media_app/ui/bloc/auth_state.dart';
import 'package:social_media_app/ui/pages/login_page.dart';
import 'package:social_media_app/ui/pages/home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when the app starts
    context.read<AuthCubit>().checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Show loading screen while checking authentication
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AuthAuthenticated) {
          // User is authenticated, show home page
          return HomePage(username: state.user['username'] ?? 'User');
        } else {
          // User is not authenticated, show login page
          return const LoginPage();
        }
      },
    );
  }
}
