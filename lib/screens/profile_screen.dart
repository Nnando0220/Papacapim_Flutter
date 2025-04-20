import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/user_service.dart';
import '../models/post.dart';
import '../routes/app_routes.dart';
import '../widgets/bottom_navigation.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String login;

  const ProfileScreen({super.key, required this.login});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final fetchedUser = await _userService.fetchUser(widget.login);
      final fetchedCurrentUser = await _authService.loadCurrentUser();

      if (!mounted) return;
      setState(() {
        user = fetchedUser;
        currentUser = fetchedCurrentUser;
      });

      await _checkIfFollowing();
      await _loadMorePosts();
    } catch (e) {
      if (mounted) _showError('Erro ao carregar dados do perfil');
    }
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
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) _showError('Erro ao carregar publicações');
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 40,
                    child: Text(user!.login[0].toUpperCase(), style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 10),
                  Text('@${user!.login}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        child: Text(_isFollowing ? 'Deixar de seguir' : 'Seguir'),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat('Seguidores', _followersCount),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
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

  void _handleDelete(Post post) {
    setState(() {
      _posts.remove(post);
    });
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

  Widget _buildStat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}