import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/services/post_service.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final Post post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Comment> _comments = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  bool _needsRefresh = false;
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreComments();
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
        _refreshComments();
        _needsRefresh = false;
        _lastRefreshTime = now;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 && !_isLoading && _hasMore) {
      _loadMoreComments();
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newComments = await _postService.fetchComments(widget.post.id, _currentPage);

      setState(() {
        if (newComments.isEmpty) {
          _hasMore = false;
        } else {
          final previousSize = _comments.length;
          _comments.addAll(newComments);
          _currentPage++;
          
          if (_comments.length == previousSize) {
            _hasMore = false;
          }
        }
      });
    } catch (e) {
      _showError('Erro ao carregar comentários: $e');
      setState(() => _hasMore = false); 
    } finally {
      setState(() {
        _isLoading = false;
        _isInitialLoading = false; 
      });
    }
  }

  void _retryLoading() {
    setState(() {
      _hasMore = true;
      _isLoading = false;
    });
    _loadMoreComments();
  }

  Future<void> _refreshComments() async {
    setState(() {
      _comments.clear();
      _currentPage = 0;
      _hasMore = true;
      _isInitialLoading = true;
    });
    await _loadMoreComments();
    _lastRefreshTime = DateTime.now();
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showError('O comentário não pode estar vazio');
      return;
    }

    try {
      final tempComment = Comment(
        id: -1,
        postId: widget.post.id,
        username: 'Enviando...', 
        content: content,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _comments.insert(0, tempComment);
        _commentController.clear();
      });

      final newComment = await _postService.createComment(widget.post.id, content);
      
      setState(() {
        final index = _comments.indexOf(tempComment);
        if (index != -1) {
          _comments[index] = newComment;
        } else {
          _comments.insert(0, newComment);
        }
      });
    } catch (e) {
      _showError('Erro ao postar comentário: $e');
      _needsRefresh = true;
    }
  }

  void _showError(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildOriginalPost(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshComments,
              child: _isInitialLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Nenhum comentário ainda. Seja o primeiro!',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                if (!_hasMore) 
                                  TextButton(
                                    onPressed: _retryLoading,
                                    child: const Text('Tentar novamente'),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _comments.length + (_hasMore && _isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _comments.length) {
                              return _buildCommentItem(_comments[index]);
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildOriginalPost() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.post.login[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.login,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _formatTimestamp(widget.post.timestamp),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.post.message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile, arguments: comment.username);
                  },
                  child: Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 4),
                Text(_formatTimestamp(comment.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Adicione um comentário...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
              ),
            ),
            TextButton(
              onPressed: _postComment,
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final dateTime = DateTime.parse(timestamp.toString());
    return timeago.format(dateTime, locale: 'pt_BR');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}