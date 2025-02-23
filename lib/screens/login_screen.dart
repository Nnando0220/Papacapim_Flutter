import 'package:flutter/material.dart';
// import 'package:social_app/services/auth_service.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // void _login() async{
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final result = await _authService.login(
  //       _emailController.text,
  //       _passwordController.text
  //   );

  //   setState(() {
  //     _isLoading = false;
  //   });

  //   if (result['success']) {
  //     // Navegar para tela inicial
  //     Navigator.pushReplacementNamed(context, AppRoutes.timeline);
  //   } else {
  //     // Mostrar mensagem de erro
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(result['message']))
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou título
                Text(
                  'Bem-vindo',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo de Login
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Login',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // keyboardType: TextInputType.emailAddress,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Por favor, insira seu e-mail';
                  //   }
                  //   // Validação de e-mail simples
                  //   final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  //   if (!emailRegex.hasMatch(value)) {
                  //     return 'E-mail inválido';
                  //   }
                  //   return null;
                  // },
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
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility
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
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Por favor, insira sua senha';
                  //   }
                  //   // if (value.length < 6) {
                  //   //   return 'A senha deve ter no mínimo 6 caracteres';
                  //   // }
                  //   return null;
                  // },
                ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       Navigator.pushNamed(context, AppRoutes.resetPassword);
                //     },
                //     child: const Text(
                //       'Esqueceu a senha?',
                //       style: TextStyle(color: Colors.deepPurple),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),

                // Botão de Login
                _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.timeline);
                    // if (_formKey.currentState!.validate()) {
                    //   // _login();
                    //   // Lógica de login
                    //   // ScaffoldMessenger.of(context).showSnackBar(
                    //   //   const SnackBar(content: Text('Realizando login...')),
                    //   // );
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // Opção de Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}