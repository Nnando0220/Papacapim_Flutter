// main.dart
import 'package:flutter/material.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/screens/comment_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/screens/edit_profile_screen.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/timeline_screen.dart';
import 'package:social_app/screens/create_post_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/screens/signup_screen.dart';
import 'package:social_app/screens/search_user_screen.dart';


void main() {
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  runApp(const SocialApp());
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.signup: (ctx) => const SignUpScreen(),
        AppRoutes.login: (ctx) => const LoginScreen(),
        AppRoutes.timeline: (ctx) => const TimelineScreen(),
        AppRoutes.profile: (ctx) {
          final login = ModalRoute.of(ctx)!.settings.arguments as String;
          return ProfileScreen(login: login);
        },
        AppRoutes.createPost: (ctx) => const CreatePostScreen(),
        AppRoutes.searchUser: (ctx) => const SearchUserScreen(),
        AppRoutes.editProfileScreen: (ctx) => const EditProfileScreen(),
        AppRoutes.commentScreen: (ctx) {
          final post = ModalRoute.of(ctx)!.settings.arguments as Post;
          return CommentsScreen(post: post);
        },
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página não encontrada')),
            body: const Center(child: Text('Ops! Página não existe')),
          ),
        );
      },
    );
  }
}