import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../routes/app_routes.dart';
import '../widgets/bottom_navigation.dart';


class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  late List<Post> _userPosts = [];
  late List<Post> _filteredPosts = [];

  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  static const int _postsPerPage = 5;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _userPosts = Post.getPosts().where((post) => post.username == user.username).toList();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
    loadMorePosts();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      loadMorePosts();
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final allUserPosts = Post.getPosts().where((post) => post.username == user.username).toList();
    final newPosts = allUserPosts
        .skip(_currentPage * _postsPerPage)
        .take(_postsPerPage)
        .toList();

    setState(() {
      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        _userPosts.addAll(newPosts);
        _currentPage++;
        _applySearch();
      }
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    _applySearch();
  }

  void _applySearch() {
    setState(() {
      _filteredPosts = _userPosts
          .where((post) =>
              post.content.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _userPosts.clear();
      _filteredPosts.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await loadMorePosts();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      currentIndex: user.isCurrentUser 
      ? 3 : 0,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 185,
              actions: user.isCurrentUser 
              ? [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showProfileOptions(context),
                ),
              ] : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              user.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Publicações', user.posts),
                              _buildStatColumn('Seguidores', user.followers),
                              _buildStatColumn('Seguindo', user.following),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: user.isCurrentUser
                              ? [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppRoutes.editProfile);
                                    },
                                    child: const Text('Editar Perfil'),
                                  ),
                                ),
                              ]
                              : [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Follow user
                                    },
                                    child: const Text('Seguir'),
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
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                          child: Text('Não há mais publicações'),
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

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              post.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _formatTimestamp(post.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: user.isCurrentUser
            ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showConfirmDeletePost(context, post),
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
                        Navigator.of(context).pushNamed(
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

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar Perfil'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Deletar Conta'),
            onTap: () {
              _showConfirmDeleteAccount(context);
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Deseja excluir a conta?',
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmDeletePost(BuildContext context, Post post) {
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
                _userPosts.remove(post);
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