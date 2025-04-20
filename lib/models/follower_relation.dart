class FollowerRelation {
  final String followerLogin;
  final String followedLogin;
  final int followers;

  FollowerRelation({
    required this.followerLogin,
    required this.followedLogin,
    required this.followers,
  });

  FollowerRelation copyWith({
    String? followerLogin,
    String? followedLogin,
    int? followers,
  }) {
    return FollowerRelation(
      followerLogin: followerLogin ?? this.followerLogin,
      followedLogin: followedLogin ?? this.followedLogin,
      followers: followers ?? this.followers,
    );
  }
}
