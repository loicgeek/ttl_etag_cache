import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';

/// Example showing the interceptor approach - drop-in caching for existing apps
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create your Dio instance
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: Duration(seconds: 30),
    ),
  );

  // Add the cache interceptor - that's it!
  dio.interceptors.add(
    CacheTtlEtagInterceptor(
      enableEncryption: true,
      defaultTtl: Duration(minutes: 5),
      defaultStrategy: CacheStrategy.cacheFirst,
      rules: {
        // User data - cache for 10 minutes
        '/users': CacheRule.cacheFirst(ttl: Duration(minutes: 10)),

        // Posts - cache for 2 minutes
        '/posts': CacheRule.cacheFirst(ttl: Duration(minutes: 2)),

        // Comments - always fresh
        '/comments': CacheRule.networkFirst(ttl: Duration(minutes: 1)),
      },
    ),
  );

  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;

  const MyApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interceptor Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomeScreen(dio: dio),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Dio dio;

  const HomeScreen({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Interceptor Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              // Clear cache
              final interceptor = dio.interceptors
                  .whereType<CacheTtlEtagInterceptor>()
                  .first;
              await interceptor.clearAll();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared!')));
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Users List'),
            subtitle: const Text('Cached for 10 minutes'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersScreen(dio: dio)),
              );
            },
          ),
          ListTile(
            title: const Text('Posts List'),
            subtitle: const Text('Cached for 2 minutes'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostsScreen(dio: dio)),
              );
            },
          ),
          ListTile(
            title: const Text('Cache Strategy Demo'),
            subtitle: const Text('Compare different strategies'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StrategyDemoScreen(dio: dio),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Example: Users list with automatic caching
class UsersScreen extends StatefulWidget {
  final Dio dio;

  const UsersScreen({super.key, required this.dio});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User>? users;
  bool isLoading = true;
  String? error;
  bool fromCache = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Your existing Dio code - unchanged!
      final response = await widget.dio.get('/users');

      // Check if from cache
      fromCache = response.headers.value('x-cache-hit') == 'true';
      final cacheAge = response.headers.value('x-cache-age');

      setState(() {
        users = (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
        isLoading = false;
      });

      if (fromCache && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded from cache ($cacheAge seconds old)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _forceRefresh() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Force refresh - bypass cache
      final response = await widget.dio.get(
        '/users',
        options: Options(headers: {'X-Force-Refresh': 'true'}),
      );

      setState(() {
        users = (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
        isLoading = false;
        fromCache = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loaded fresh data from network'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _forceRefresh),
        ],
      ),
      body: Column(
        children: [
          if (fromCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.green.shade100,
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Loaded from cache (instant!)'),
                ],
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (users == null || users!.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: users!.length,
      itemBuilder: (context, index) {
        final user = users![index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}

/// Example: Posts list
class PostsScreen extends StatefulWidget {
  final Dio dio;

  const PostsScreen({super.key, required this.dio});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Post>? posts;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => isLoading = true);

    try {
      // Existing code - just works!
      final response = await widget.dio.get('/posts');

      setState(() {
        posts = (response.data as List)
            .take(20)
            .map((json) => Post.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                itemCount: posts?.length ?? 0,
                itemBuilder: (context, index) {
                  final post = posts![index];
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
    );
  }
}

/// Example: Compare different cache strategies
class StrategyDemoScreen extends StatelessWidget {
  final Dio dio;

  const StrategyDemoScreen({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategy Comparison')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStrategyCard(
            context,
            'Cache First',
            'Returns cached data instantly if available',
            Colors.blue,
            () async {
              final stopwatch = Stopwatch()..start();

              // Uses default cache-first strategy
              final response = await dio.get('/users/1');

              stopwatch.stop();

              final fromCache = response.headers.value('x-cache-hit') == 'true';

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      fromCache
                          ? 'Cache hit! (${stopwatch.elapsedMilliseconds}ms)'
                          : 'Network fetch (${stopwatch.elapsedMilliseconds}ms)',
                    ),
                    backgroundColor: fromCache ? Colors.green : Colors.blue,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 16),

          _buildStrategyCard(
            context,
            'Network First',
            'Always tries network first, falls back to cache',
            Colors.orange,
            () async {
              final stopwatch = Stopwatch()..start();

              final response = await dio.get(
                '/users/1',
                options: Options(headers: {'X-Cache-Strategy': 'networkFirst'}),
              );

              stopwatch.stop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Network first: ${stopwatch.elapsedMilliseconds}ms',
                    ),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 16),

          _buildStrategyCard(
            context,
            'Force Refresh',
            'Bypasses cache completely',
            Colors.red,
            () async {
              final stopwatch = Stopwatch()..start();

              final response = await dio.get(
                '/users/1',
                options: Options(headers: {'X-Force-Refresh': 'true'}),
              );

              stopwatch.stop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Force refresh: ${stopwatch.elapsedMilliseconds}ms',
                    ),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Try each strategy multiple times to see the difference!',
            style: TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    Future<void> Function() onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 40, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Models
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
