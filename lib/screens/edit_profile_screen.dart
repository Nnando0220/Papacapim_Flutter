import 'package:flutter/material.dart';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/services/user_service.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _userService = UserService();

  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;

  void _editProfile() async {
    setState(() {
      _isLoading = true;
    });

    final data = {
      if (_nameController.text.isNotEmpty) 'name': _nameController.text,
      if (_loginController.text.isNotEmpty) 'login': _loginController.text,
      if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
      if (_confirmPasswordController.text.isNotEmpty) 'confirm_password': _confirmPasswordController.text,
    };

    final result = await _userService.editUser(
      data : data
    );
    
    if (!mounted) return;

    if (result['success']) {
      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );

      // Espera um tempo antes de redirecionar
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;

      // Navegar para tela inicial
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false, // Remove todas as anteriores
      );
    } else {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo de Nome Completo
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome completo';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de Login (Nome de Usuário)
            TextFormField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Login',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu login';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de Senha
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua senha';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua senha';
                }
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}