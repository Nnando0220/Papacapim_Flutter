import 'package:flutter/material.dart';
import 'package:social_app/widgets/like_button.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final Post post;
  final User? currentUser;
  final Function(Post) onDelete;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onDelete,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = currentUser != null && post.login == currentUser!.login;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Align(
              alignment: Alignment.centerLeft, // ou onde quiser
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.profile,
                    arguments: post.login,
                  );
                },
                child: Text(
                  '@${post.login}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),          
            subtitle: Text(
              _formatTimestamp(post.timestamp),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: isOwnPost
                ? IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPostOptions(context),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.message),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like & Dislike
                LikeButton(
                  isLiked: post.isLiked,
                  likeCount: post.likes,
                  onPressed: onLike,
                ),
                // Comentários
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: Text('${post.comments}', style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.commentScreen,
                      arguments: post,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final dateTime = DateTime.parse(timestamp.toString());
    return timeago.format(dateTime, locale: 'pt_BR');
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Deletar Publicação', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
