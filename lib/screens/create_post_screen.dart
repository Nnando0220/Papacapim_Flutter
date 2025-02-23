import 'package:flutter/material.dart';
// import 'package:social_app/routes/app_routes.dart';
import '../widgets/bottom_navigation.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      currentIndex: 2,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Área de texto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'No que você está pensando?',
                  border: InputBorder.none,
                ),
              ),
            ),

            // Visualização da imagem selecionada
            if (_selectedImagePath != null)
              Image.network(
                _selectedImagePath!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

            // // Botões de mídia
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Row(
            //     children: [
            //       IconButton(
            //         icon: const Icon(Icons.photo_library),
            //         onPressed: _selectImage,
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.camera_alt),
            //         onPressed: _takePhoto,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // void _selectImage() {
  //   // Simulação de seleção de imagem
  //   setState(() {
  //     _selectedImagePath = 'https://picsum.photos/seed/newpost/600/400';
  //   });
  // }

  // void _takePhoto() {
  //   // Simulação de foto da câmera
  // }

  void _publishPost() {
    // Lógica para publicar o post
    Navigator.pop(context);
  }
}