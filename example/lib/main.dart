import 'package:flutter/material.dart';
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cache with encryption
  await NeeroTtlEtagCache.init(enableEncryption: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neero Cache Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neero Cache Examples')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('User Profile'),
            subtitle: const Text('Simple cached user data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(userId: '1'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Posts List'),
            subtitle: const Text('List with pagination'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostsListScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Combined Data'),
            subtitle: const Text('Multiple repositories'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Cache Settings'),
            subtitle: const Text('Manage cache and encryption'),
            trailing: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CacheSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Example 1: Simple User Profile
class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final CachedTtlEtagRepository<User> _repository;

  @override
  void initState() {
    super.initState();
    _repository = CachedTtlEtagRepository<User>(
      url: 'https://jsonplaceholder.typicode.com/users/${widget.userId}',
      headers: {"accept": "application/json"},
      fromJson: (json) => User.fromJson(json),
      defaultTtl: const Duration(minutes: 5),
    );
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _repository.refresh(),
          ),
        ],
      ),
      body: StreamBuilder<CacheTtlEtagState<User>>(
        stream: _repository.stream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const CacheTtlEtagState<User>();

          if (state.isEmpty && state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError && !state.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _repository.fetch(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.hasData) {
            return Stack(
              children: [
                ListView(
                  children: [
                    if (state.isStale)
                      Container(
                        color: Colors.orange.shade100,
                        padding: const EdgeInsets.all(8),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber, size: 16),
                            SizedBox(width: 8),
                            Text('Data is stale, refreshing...'),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.data!.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(state.data!.email),
                          Text(state.data!.phone),
                          const SizedBox(height: 16),
                          if (state.timestamp != null)
                            Text(
                              'Last updated: ${state.timestamp!.toLocal()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          if (state.timeUntilExpiry != null)
                            Text(
                              'Expires in: ${state.timeUntilExpiry!.inMinutes} minutes',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (state.isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}

// Example 2: Posts List
class PostsListScreen extends StatefulWidget {
  const PostsListScreen({super.key});

  @override
  State<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  late final CachedTtlEtagRepository<List<Post>> _repository;

  @override
  void initState() {
    super.initState();
    _repository = CachedTtlEtagRepository<List<Post>>(
      url: 'https://jsonplaceholder.typicode.com/posts',
      method: "GET",
      headers: {"accept": "application/json"},
      fromJson: (json) => (json as List).map((e) => Post.fromJson(e)).toList(),
      defaultTtl: const Duration(minutes: 10),
    );
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _repository.refresh(),
          ),
        ],
      ),
      body: StreamBuilder<CacheTtlEtagState<List<Post>>>(
        stream: _repository.stream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const CacheTtlEtagState<List<Post>>();

          if (state.isEmpty && state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasData) {
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => _repository.refresh(),
                  child: ListView.builder(
                    itemCount: state.data!.length,
                    itemBuilder: (context, index) {
                      final post = state.data![index];
                      return ListTile(
                        title: Text(post.title),
                        subtitle: Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),

                if (state.isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          }

          return const Center(child: Text('No posts'));
        },
      ),
    );
  }
}

// Example 3: Dashboard with Multiple Data Sources
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final CachedTtlEtagRepository<User> _userRepo;
  late final CachedTtlEtagRepository<List<Post>> _postsRepo;

  @override
  void initState() {
    super.initState();
    _userRepo = CachedTtlEtagRepository<User>(
      url: 'https://jsonplaceholder.typicode.com/users/1',
      fromJson: (json) => User.fromJson(json),
      defaultTtl: const Duration(minutes: 5),
    );
    _postsRepo = CachedTtlEtagRepository<List<Post>>(
      url: 'https://jsonplaceholder.typicode.com/posts',
      fromJson: (json) =>
          (json as List).take(5).map((e) => Post.fromJson(e)).toList(),
      defaultTtl: const Duration(minutes: 5),
    );
  }

  @override
  void dispose() {
    _userRepo.dispose();
    _postsRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _userRepo.refresh();
              _postsRepo.refresh();
            },
          ),
        ],
      ),
      body: StreamBuilder<CacheTtlEtagState<User>>(
        stream: _userRepo.stream,
        builder: (context, userSnapshot) {
          return StreamBuilder<CacheTtlEtagState<List<Post>>>(
            stream: _postsRepo.stream,
            builder: (context, postsSnapshot) {
              final userState =
                  userSnapshot.data ?? const CacheTtlEtagState<User>();
              final postsState =
                  postsSnapshot.data ?? const CacheTtlEtagState<List<Post>>();

              final isLoading = userState.isLoading || postsState.isLoading;

              return Stack(
                children: [
                  ListView(
                    children: [
                      if (userState.hasData)
                        Card(
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${userState.data!.name}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(userState.data!.email),
                              ],
                            ),
                          ),
                        ),

                      if (postsState.hasData)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Recent Posts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),

                      if (postsState.hasData)
                        ...postsState.data!.map(
                          (post) => ListTile(
                            title: Text(post.title),
                            subtitle: Text(
                              post.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// Cache Settings Screen
class CacheSettingsScreen extends StatefulWidget {
  const CacheSettingsScreen({super.key});

  @override
  State<CacheSettingsScreen> createState() => _CacheSettingsScreenState();
}

class _CacheSettingsScreenState extends State<CacheSettingsScreen> {
  bool _encryptionEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _encryptionEnabled = NeeroTtlEtagCache.isEncryptionEnabled;
  }

  Future<void> _toggleEncryption(bool value) async {
    setState(() => _isLoading = true);

    try {
      await NeeroTtlEtagCache.migrateEncryption(enableEncryption: value);
      setState(() {
        _encryptionEnabled = value;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Encryption enabled successfully'
                  : 'Encryption disabled successfully',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _clearCache() async {
    await NeeroTtlEtagCache.clearAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cache Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Encryption'),
            subtitle: Text(
              _encryptionEnabled
                  ? 'Cache is encrypted with AES-256'
                  : 'Cache is stored in plain text',
            ),
            value: _encryptionEnabled,
            onChanged: _isLoading ? null : _toggleEncryption,
          ),

          if (_isLoading) const LinearProgressIndicator(),

          const Divider(),

          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove all cached data'),
            trailing: const Icon(Icons.delete_outline),
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }
}

// Models
class User {
  final int id;
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }
}

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
