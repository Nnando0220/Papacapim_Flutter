// main.dart
import 'package:flutter/material.dart';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/screens/comment_screen.dart';
import 'package:social_app/screens/edit_profile_screen.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/timeline_screen.dart';
import 'package:social_app/screens/create_post_screen.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/screens/signup_screen.dart';
import 'package:social_app/screens/search_user_screen.dart';

void main() {
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
        AppRoutes.timeline: (ctx) => const TimelineScreen(),
        AppRoutes.login: (ctx) => const LoginScreen(),
        AppRoutes.createPost: (ctx) => const CreatePostScreen(),
        AppRoutes.editProfile: (ctx) => const EditProfileScreen(),
        AppRoutes.searchUser: (ctx) => const SearchUserScreen(),
        AppRoutes.profile: (ctx) {
          final user = ModalRoute.of(ctx)!.settings.arguments as User? ?? User.getUserByUsername('João Silva');
          return ProfileScreen(user: user);
        },
        AppRoutes.comments: (ctx) {
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