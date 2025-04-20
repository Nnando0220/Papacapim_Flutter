import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/post_service.dart';
import 'package:social_app/widgets/post_card.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../widgets/bottom_navigation.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _postService = PostService();
  final _authService = AuthService();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  final List<Post> _posts = [];
  List<Post> _filteredPosts = [];

  User? _currentUser;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isSearching = false;
  bool _hasMore = true;
  String _lastSearchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    await _loadMorePosts();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.loadCurrentUser();
      setState(() => _currentUser = user);
    } catch (e) {
      _showError('Erro ao carregar usuário');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final newPosts = await _postService.fetchPosts(page: _currentPage);
      await _markUserLikes(newPosts);

      setState(() {
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(newPosts);
          _currentPage++;
        }
        _applySearch(_searchController.text.trim());
      });
    } catch (e) {
      _showError('Erro ao carregar posts');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      _applySearch(query);
    });
  }

  Future<void> _applySearch(String query) async {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.isEmpty) {
      setState(() {
        _filteredPosts = List.from(_posts);
        _lastSearchQuery = '';
        _isSearching = false;
      });
      return;
    }

    if (lowerQuery == _lastSearchQuery) return;

    setState(() => _isSearching = true);

    try {
      final searchedPosts = await _postService.fetchPostsSearch(query: lowerQuery);
      await _markUserLikes(searchedPosts);
      setState(() {
        _filteredPosts = searchedPosts;
        _lastSearchQuery = lowerQuery;
      });
    } catch (e) {
      _showError('Erro ao buscar posts');
      setState(() => _filteredPosts = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _filteredPosts.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadMorePosts();
  }

  void _handleDelete(Post post) {
    if (_currentUser?.login != post.login) {
      _showError('Você não pode excluir este post');
      return;
    }

    try {
      _postService.deletePost(post.id).then((_) {
        _showSuccess('Post excluído com sucesso!');
        setState(() {
          _posts.removeWhere((p) => p.id == post.id);
          _filteredPosts.removeWhere((p) => p.id == post.id);
        });
      }).catchError((error) {
        _showError('Erro ao excluir post: $error');
      });
    } catch (e) {
      _showError('Erro ao excluir post: $e');
    }
  }

  Future<void> _handleLike(Post post) async {
    final userLogin = _currentUser?.login;
    if (userLogin == null) return;

    try {
      final hasLiked = await _postService.fetchLikes(post.id).then(
            (likes) => likes.any((like) => like['user_login'] == userLogin),
          );

      if (hasLiked) {
        await _postService.unlikePost(post.id);
        setState(() {
          post.isLiked = false;
          post.likes--;
        });
      } else {
        await _postService.likePost(post.id);
        setState(() {
          post.isLiked = true;
          post.likes++;
        });
      }
    } catch (e) {
      _showError('Erro ao atualizar curtida');
    }
  }

  Future<void> _markUserLikes(List<Post> posts) async {
    final login = _currentUser?.login;
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BottomNavigation(
      currentIndex: 0,
      login: _currentUser!.login,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar posts',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            if (_isSearching && _posts.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final list = _filteredPosts;

                    if (list.isEmpty) {
                      if (_isLoading && _posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Nenhum post encontrado')),
                      );
                    }

                    if (index < list.length) {
                      final post = list[index];
                      return PostCard(
                        post: post,
                        currentUser: _currentUser,
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
                        child: Center(child: Text('Não há mais posts')),
                      );
                    }

                    return null;
                  },
                  childCount: _filteredPosts.isEmpty
                      ? 1
                      : _filteredPosts.length + (_hasMore || _isLoading ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
