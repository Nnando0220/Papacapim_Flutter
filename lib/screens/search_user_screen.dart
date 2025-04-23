import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_app/services/auth_service.dart';
import '../models/user.dart';
import '../routes/app_routes.dart';
import '../services/user_service.dart';
import '../widgets/bottom_navigation.dart';


class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  SearchUserScreenState createState() => SearchUserScreenState();
}

class SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  User? _currentUser;

  List<User> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _searchUsers();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 && !_isLoading && _hasMore) {
      _searchUsers(loadMore: true);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchResults.clear();
        _currentPage = 0;
        _hasMore = true;
      });
      _searchUsers();
    });
  }

  Future<void> _searchUsers({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final users = await _userService.fetchUsers(
        search: _searchController.text.trim(),
        page: _currentPage,
      );

      setState(() {
        if (loadMore) {
          _searchResults.addAll(users);
        } else {
          _searchResults = users;
        }
        if (users.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar usuários')),
        );
      }
      debugPrint('Erro ao buscar usuários: $e');
      setState(() => _hasMore = false); 
    } finally {
      setState(() => _isLoading = false); 
    }
  }

  void _retrySearch() {
    setState(() {
      _hasMore = true;
      _currentPage = 0;
    });
    _searchUsers();
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

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      currentIndex: 1,
      login: _currentUser?.login ?? '',
      appBar: AppBar(
        title: const Text(
          'Buscar Usuários',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuários...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Nenhum usuário encontrado'),
                            TextButton(
                              onPressed: _retrySearch,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                    controller: _scrollController,
                    itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _searchResults.length) {
                        return _buildUserCard(_searchResults[index]);
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('@${user.login}'),
        trailing: TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.profile,
              arguments: user.login,
            );
          },
          child: const Text('Ver Perfil'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
