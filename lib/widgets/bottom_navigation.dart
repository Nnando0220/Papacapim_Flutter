import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import '../routes/app_routes.dart';

class BottomNavigation extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int currentIndex;

  const BottomNavigation({
    Key? key,
    this.appBar,
    required this.body,
    required this.currentIndex,
  }) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    String routeName;
    switch (index) {
      case 0:
        routeName = AppRoutes.timeline;
        break;
      case 1:
        routeName = AppRoutes.searchUser;
        break;
      case 2:
        routeName = AppRoutes.createPost;
        break;
      case 3:
        routeName = AppRoutes.profile;
        Navigator.pushNamed(
          context,
          AppRoutes.profile,
          arguments: User.getUserByUsername('João Silva'),
        );
        break;
      default:
        return;
    }

    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Criar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}