import 'package:flutter/material.dart';
import '../models/post.dart';
import '../routes/app_routes.dart';
import '../widgets/bottom_navigation.dart';
import '../models/user.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final User user = User.getUserByUsername('João Silva');
  final List<Post> _posts = [];
  late List<Post> _filteredPosts = [];
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  static const int _postsPerPage = 5;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
    _loadMorePosts();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    // Obter posts da API/banco de dados
    final newPosts = Post.getPosts().skip(_currentPage * _postsPerPage).take(_postsPerPage).toList();

    setState(() {
      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        _posts.addAll(newPosts);
        _currentPage++;
        _applySearch(); // Atualiza os posts filtrados
      }
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    _applySearch();
  }

  void _applySearch() {
    setState(() {
      _filteredPosts = _posts
          .where((post) =>
              post.content.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _refreshTimeline() async {
    setState(() {
      _posts.clear();
      _filteredPosts.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadMorePosts();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      currentIndex: 0,
      body: RefreshIndicator(
        onRefresh: _refreshTimeline,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar posts',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _filteredPosts.length) {
                      return _buildPostCard(_filteredPosts[index]);
                    } else if (_hasMore && _isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (!_hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Não há mais posts para carregar'),
                        ),
                      );
                    }
                    return null;
                  },
                  childCount: _filteredPosts.length + (_hasMore || _isLoading ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.profile,
                  arguments: User.getUserByUsername(post.username),
                );
              },
              child: Text(
                post.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              _formatTimestamp(post.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: post.username == user.username
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showProfileOptions(context, post),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.content),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: post.isLiked ? Colors.blue : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          if (post.isLiked) {
                            post.likes--;
                            post.isLiked = false;
                          } else {
                            post.likes++;
                            post.isLiked = true;
                          }
                        });
                      },
                    ),
                    Text('${post.likes} Curtidas'),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    IconButton(
                      icon: Icon(
                        post.isDesliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                        color: post.isDesliked ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          if (post.isDesliked) {
                            post.deslikes--;
                            post.isDesliked = false;
                          } else {
                            post.deslikes++;
                            post.isDesliked = true;
                          }
                        });
                      },
                    ),
                    Text('${post.deslikes} Deslikes'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.comments,
                          arguments: post,
                        );
                      },
                    ),
                    Text('${post.comments.length} Comentários'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }

  void _showProfileOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Deseja excluir a publicação?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancelar'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Deletar'),
            onTap: () {
              setState(() {
                _posts.remove(post);
                _filteredPosts.remove(post);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}