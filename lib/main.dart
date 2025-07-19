import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/data/post_model.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';
import 'package:social_media_app/ui/bloc/auth_cubit.dart';
import 'package:social_media_app/ui/bloc/reels_cubit.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/ui/pages/chat_page.dart';
import 'package:social_media_app/ui/pages/create_post_page.dart';
import 'package:social_media_app/ui/pages/explore_reels_page.dart';
import 'package:social_media_app/ui/pages/home_page.dart';
import 'package:social_media_app/ui/pages/post_detail_page.dart';
import 'package:social_media_app/ui/pages/profile_page.dart';
import 'package:social_media_app/ui/pages/search_page.dart';
import 'package:social_media_app/ui/pages/login_page.dart';
import 'package:social_media_app/ui/pages/signup_page.dart';
import 'package:social_media_app/ui/widgets/auth_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PostCubit()),
        BlocProvider(create: (context) => AuthCubit(AuthService())),
        BlocProvider(create: (context) => ReelsCubit()),
      ],
      child: MaterialApp(
        title: 'Social Media App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case NamedRoutes.homeScreen:
              final args = settings.arguments;
              String username = 'User';
              if (args is Map<String, dynamic>) {
                username = args['username'] ?? 'User';
              } else if (args is String) {
                username = args;
              }
              return MaterialPageRoute(
                builder: (context) => HomePage(username: username),
              );
            case NamedRoutes.profileScreen:
              return MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              );
            case NamedRoutes.reelsScreen:
              return MaterialPageRoute(
                builder: (context) => const ExploreReelsPage(),
              );
            case NamedRoutes.searchScreen:
              return MaterialPageRoute(
                builder: (context) => const SearchPage(),
              );
            case NamedRoutes.chatScreen:
              return MaterialPageRoute(
                builder: (context) => const ChatPage(),
              );
            case NamedRoutes.createPostScreen:
              return MaterialPageRoute(
                builder: (context) => const CreatePostPage(),
              );
            case NamedRoutes.postDetailScreen:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => PostDetailPage(
                  post: args['post'] as PostModel,
                  postIndex: args['postIndex'] as int,
                ),
              );
            case NamedRoutes.loginScreen:
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
              );
            case NamedRoutes.signupScreen:
              return MaterialPageRoute(
                builder: (context) => const SignupPage(),
              );
            default:
              return MaterialPageRoute(builder: (context) => const LoginPage());
          }
        },
      ),
    );
  }
}
