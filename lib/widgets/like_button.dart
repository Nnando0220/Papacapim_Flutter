import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onPressed;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            color: isLiked ? Colors.blue : null,
            size: 20,
          ),
          onPressed: onPressed,
        ),
        Text('$likeCount', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
