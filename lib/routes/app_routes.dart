class AppRoutes {
  static const String initial = 'https://api.papacapim.just.pro.br';
  static const String login = '/sessions';
  static const String signup = '/users';
  // static const String logout = '/sessions/1';
  static const String deleteUser = '/users/1';
  static const String timeline = '/posts';
  static const String post = '/posts';
  static String deletePost(postId) => '/posts/$postId';
  static const String createPost = '/create-post';
  static String like(int postId) => '/posts/$postId/likes';
  static String likesPost(int postId) => '/posts/$postId/likes';
  static String unlike(int postId) => '/posts/$postId/likes/1';
  static String commentScreen = '/comment-screen';
  static String comment(int postId) => '/posts/$postId/replies';
  static String comments(int postId) => '/posts/$postId/replies';
  static String postUser(String login) => '/users/$login/posts';
  static const String profile = '/profile';
  static const String searchUser = '/search-user';
  static const String editProfileScreen = '/edit-profile';
  static const String users = '/users';
  static String editUser = '/users/1';
  static String user(String login) => '/users/$login';
  static String follower(String login) => '/users/$login/followers';
  static String followers(String login) => '/users/$login/followers';
  static String unfollow(String login) => '/users/$login/followers/1';
}