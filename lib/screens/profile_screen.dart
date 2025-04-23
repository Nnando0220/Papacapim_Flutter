import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart' as auth;
import 'package:social_app/services/user_service.dart' as user_service;
import '../models/post.dart';
import '../routes/app_routes.dart';
import '../widgets/bottom_navigation.dart';
import '../services/post_service.dart' as post;
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String login;

  const ProfileScreen({super.key, required this.login});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final post.PostService _postService = post.PostService();
  final user_service.UserService _userService = user_service.UserService();
  final auth.AuthService _authService = auth.AuthService();

  final ScrollController _scrollController = ScrollController();
  final List<Post> _posts = [];

  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  User? user;
  User? currentUser;
  bool _isFollowing = false;
  late List<String> _followers = [];
  int _followersCount = 0;

  bool _needsRefresh = false;
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final timeSinceLastRefresh = now.difference(_lastRefreshTime).inSeconds;
      
      if (mounted && 
          (ModalRoute.of(context)?.isCurrent == true) && 
          _needsRefresh && 
          timeSinceLastRefresh > 5) {
        _refreshProfile();
        _needsRefresh = false;
        _lastRefreshTime = now;
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);
      
      final results = await Future.wait([
        _userService.fetchUser(widget.login),
        _authService.loadCurrentUser(),
      ]);

      if (!mounted) return;
      
      setState(() {
        user = results[0];
        currentUser = results[1];
        _isLoading = false;
      });

      await _checkIfFollowing();
      await _loadMorePosts();
    } on user_service.NotFoundException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        _showError(e.message);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        
        if (e is user_service.NotFoundException) {
        } else if (e is Exception && e.toString().contains('autenticação')) {
          _showError(e.toString());
          _navigateToLogin();
        } else {
          _showError('Erro ao carregar dados do perfil: ${e.toString()}');
        }
      }
    }
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.login, 
          (route) => false
        );
      }
    });
  }

  Future<void> _checkIfFollowing() async {
    try {
      if (currentUser == null || user == null) return;

      final (fetchedFollowers, count) = await _userService.fetchFollowers(user!.login);

      if (!mounted) return;
      setState(() {
        _followers = fetchedFollowers;
        _followersCount = count;
        _isFollowing = _followers.contains(currentUser!.login);
      });
    } catch (e) {
      debugPrint('Erro ao verificar seguidores: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    try {
      if (_isLoading || !_hasMore || user == null) return;

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));

      final newPosts = await _postService.fetchUserPosts(
        login: user!.login,
        page: _currentPage,
      );

      await _markUserLikes(newPosts);

      if (!mounted) return;
      setState(() {
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(newPosts);
          _currentPage++;
        }
      });
    } catch (e) {
      if (mounted) _showError('Erro ao carregar publicações');
      setState(() => _hasMore = false); 
    } finally {
      if (mounted) setState(() => _isLoading = false); 
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _posts.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _checkIfFollowing();
    await _loadMorePosts();
    _lastRefreshTime = DateTime.now();
  }

  Future<void> _toggleFollow() async {
    try {
      if (_isFollowing) {
        await _userService.unfollowUser(user!.login);
      } else {
        await _userService.followUser(user!.login);
      }
      setState(() => _isFollowing = !_isFollowing);
      await _checkIfFollowing();
    } catch (e) {
      _showError('Erro ao atualizar status de seguir');
    }
  }

  Future<void> _markUserLikes(List<Post> posts) async {
    final login = currentUser?.login;
    if (login == null) return;

    for (var post in posts) {
      try {
        final likes = await _postService.fetchLikes(post.id);
        post.isLiked = likes.any((like) => like['user_login'] == login);
      } catch (e) {
        post.isLiked = false;
      }
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text('Tem certeza que deseja excluir sua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      try {
        await _userService.deleteUser();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) _showError('Erro ao excluir conta');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.login),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _isLoading 
                      ? 'Carregando perfil...' 
                      : 'Não foi possível carregar o perfil',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: _initializeData,
                  child: const Text('Tentar novamente'),
                ),
            ],
          ),
        ),
      );
    }

    final isCurrentUser = user!.login == currentUser!.login;

    return BottomNavigation(
      currentIndex: 3,
      login: currentUser!.login,
      appBar: AppBar(
        title: Text('@${user!.login}'),
        actions: [
          if (isCurrentUser)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.pushNamed(context, AppRoutes.editProfileScreen);
                    break;
                  case 'delete':
                    _deleteAccount();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar perfil')),
                const PopupMenuItem(value: 'delete', child: Text('Excluir conta')),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'profile-${user!.login}',
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            child: Text(
                              user!.login[0].toUpperCase(), 
                              style: const TextStyle(fontSize: 30, color: Colors.white)
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (user!.name.isNotEmpty)
                                Text(
                                  user!.name,
                                  style: const TextStyle(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                '@${user!.login}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildStat('Seguidores', _followersCount),
                                ],
                              ),
                              
                              // Adicionando informação de quando o perfil foi criado
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined, 
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Membro desde ${_formatTimestamp(user!.timestamp)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (!isCurrentUser)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: _isFollowing 
                                ? Colors.grey[300] 
                                : Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            _isFollowing ? 'Deixar de seguir' : 'Seguir',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isFollowing 
                                  ? Colors.black87 
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    
                    const Text(
                      'Publicações',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (_isLoading && _posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (_posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Nenhuma publicação encontrada')),
                      );
                    }

                    if (index < _posts.length) {
                      final post = _posts[index];
                      return PostCard(
                        post: post,
                        currentUser: currentUser,
                        onDelete: _handleDelete,
                        onLike: () => _handleLike(post),
                      );
                    }

                    if (_hasMore && _isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!_hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Não há mais publicações')),
                      );
                    }

                    return null;
                  },
                  childCount: _posts.isEmpty ? 1 : _posts.length + (_hasMore || _isLoading ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(Post post) async {
    if (currentUser!.login != post.login) {
      _showError('Você não pode excluir este post');
      return;
    }

    try {
      setState(() {
        _posts.removeWhere((p) => p.id == post.id);
      });
      
      await _postService.deletePost(post.id);
      _showSuccess('Post excluído com sucesso!');
      _refreshProfile();
    } catch (e) {
      _showError('Erro ao excluir post: $e');
      _needsRefresh = true;
    }
  }

  void _handleLike(Post post) async {
    final userLogin = currentUser?.login;
    if (userLogin == null) return;

    final hasLiked = await _hasLikedPost(post.id, userLogin);
    if (hasLiked) {
      await _unlikePost(post);
    } else {
      await _likePost(post);
    }
  }

  Future<void> _likePost(Post post) async {
    try {
      await _postService.likePost(post.id);
      if (!mounted) return;
      setState(() {
        post.isLiked = true;
        post.likes++;
      });
    } catch (e) {
      if (mounted) _showError('Erro ao curtir a postagem');
    }
  }

  Future<void> _unlikePost(Post post) async {
    try {
      await _postService.unlikePost(post.id);
      if (!mounted) return;
      setState(() {
        post.isLiked = false;
        post.likes--;
      });
    } catch (e) {
      if (mounted) _showError('Erro ao descurtir a postagem');
    }
  }

  Future<bool> _hasLikedPost(int postId, String userLogin) async {
    try {
      final likes = await _postService.fetchLikes(postId);
      return likes.any((like) => like['user_login'] == userLogin);
    } catch (e) {
      debugPrint('Erro ao verificar curtidas: $e');
      return false;
    }
  }

  void _showSuccess(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget _buildStat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value', 
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18
            )
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    
    return '${timestamp.day} de ${months[timestamp.month - 1]} de ${timestamp.year}';
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}