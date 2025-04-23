import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/post_service.dart';
import '../widgets/bottom_navigation.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      currentIndex: 2,
      login: _currentUser?.login ?? '',
      appBar: AppBar(
        title: const Text(
          'Criar Publicação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => {
            Navigator.pop(context)
          },
        ),
        actions: [
          TextButton(
            onPressed: _publishPost,
            child: const Text(
              'Publicar',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Área de texto
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  maxLength: 280,
                  decoration: const InputDecoration(
                    hintText: 'No que você está pensando?',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _publishPost() {
    final message = _contentController.text.trim();
    if (message.isEmpty) {
      _showError('O conteúdo não pode estar vazio!');
      return;
    }
    
    if (message.length > 280) {
      _showError('A mensagem não pode ter mais que 280 caracteres!');
      return;
    }

    try {
      _postService.createPost(message).then((_) {
        _showSuccess('Publicação criada com sucesso!');
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.timeline, arguments: _currentUser?.login);
        }
      }).catchError((error) {
        _showError('Erro ao criar publicação: $error');
      });
    } catch (e) {
      _showError('Erro ao criar publicação: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final fetchedCurrentUser = await _authService.loadCurrentUser();
      setState(() {
        _currentUser = fetchedCurrentUser;
      });
    } catch (e) {
      _showError('Erro ao carregar usuário');
      debugPrint('Erro ao carregar usuário: $e');
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }
}