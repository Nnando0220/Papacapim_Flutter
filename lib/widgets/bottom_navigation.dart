import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
class BottomNavigation extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int currentIndex;
  final String login; 

  const BottomNavigation({
    super.key,
    this.appBar,
    required this.body,
    required this.currentIndex,
    required this.login, 
  });

  void _onItemTapped(BuildContext context, int index) {
    String routeName;
    dynamic arguments;
    
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
        arguments = login;
        break;
      default:
        return;
    }

    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushNamed(
        context,
        routeName,
        arguments: arguments,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: arguments,
      );
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