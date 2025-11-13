# Neero TTL/ETag Cache

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License">
</p>

A powerful, reactive caching solution for Flutter applications with TTL (Time To Live), ETag support, and optional AES-256 encryption. Perfect for building offline-first applications with intelligent data synchronization.

## ✨ Features

- 🚀 **Reactive Caching** - Stream-based architecture with automatic UI updates
- ⏰ **TTL Support** - Automatic cache expiration based on server headers or custom values
- 🔄 **ETag Validation** - Conditional requests with `If-None-Match` and `If-Modified-Since`
- 🔐 **Optional Encryption** - AES-256 encryption with secure key storage
- 📱 **Offline-First** - Serve stale cache when network is unavailable
- 🎯 **Type-Safe** - Full generic type support with Dart's type system
- 💾 **Persistent Storage** - Uses Isar for fast, local database storage
- 🔔 **Reactive Updates** - BroadcastStream notifies all listeners of cache changes
- 🎨 **Clean Architecture** - Repository pattern with separation of concerns
- 🌐 **Network Optimization** - Reduces bandwidth with 304 Not Modified responses

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  neero_ttl_etag_cache: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Method 1: Interceptor (Easiest - 3 Lines!)

Perfect for adding caching to **existing apps** with zero code changes:

```dart
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dio = Dio();
  
  // Add these 3 lines - that's it!
  dio.interceptors.add(
    CacheTtlEtagInterceptor(
      enableEncryption: true,
      defaultTtl: Duration(minutes: 5),
    ),
  );
  
  runApp(MyApp());
}

// Your existing Dio code works unchanged!
final response = await dio.get('https://api.example.com/users');
// ✨ Now automatically cached with TTL and ETag support!
```

**That's it!** All your GET requests are now cached. [See Interceptor Guide →](doc/INTERCEPTOR_GUIDE.md)

---

### Method 2: Repository Pattern (Recommended for New Code)

For clean architecture with reactive state management:

```dart
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize without encryption
  await NeeroTtlEtagCache.init();
  
  // OR with encryption enabled
  await NeeroTtlEtagCache.init(enableEncryption: true);
  
  runApp(MyApp());
}
```

### 2. Create a Repository

```dart
import 'package:neero_ttl_etag_cache/neero_ttl_etag_cache.dart';

class UserRepository {
  late final CachedTtlEtagRepository<User> _repository;
  
  UserRepository(String userId) {
    _repository = CachedTtlEtagRepository<User>(
      config: CachedTtlEtagConfig<User>(
        url: 'https://api.example.com/users/$userId',
        fromJson: (json) => User.fromJson(json),
        defaultTtl: Duration(minutes: 5),
      ),
    );
  }
  
  Stream<CacheTtlEtagState<User>> get stream => _repository.stream;
  
  Future<void> fetch() => _repository.fetch();
  Future<void> refresh() => _repository.refresh();
  
  void dispose() => _repository.dispose();
}
```

### 3. Use in Your Widget

```dart
class UserProfileScreen extends StatefulWidget {
  final String userId;
  
  const UserProfileScreen({required this.userId});
  
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserRepository _userRepo;
  
  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(widget.userId);
  }
  
  @override
  void dispose() {
    _userRepo.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _userRepo.refresh(),
          ),
        ],
      ),
      body: StreamBuilder<CacheTtlEtagState<User>>(
        stream: _userRepo.stream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? CacheTtlEtagState<User>();
          
          // Show loading indicator
          if (state.isEmpty && state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          // Show error screen
          if (state.hasError && !state.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _userRepo.fetch(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          // Show data with loading/stale indicators
          if (state.hasData) {
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => _userRepo.refresh(),
                  child: ListView(
                    children: [
                      // Stale data indicator
                      if (state.isStale)
                        Container(
                          color: Colors.orange.shade100,
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, size: 16),
                              SizedBox(width: 8),
                              Text('Data is outdated, refreshing...'),
                            ],
                          ),
                        ),
                      
                      // User data
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(state.data!.avatarUrl),
                        ),
                        title: Text(state.data!.name),
                        subtitle: Text(state.data!.email),
                      ),
                      
                      // Cache metadata
                      if (state.timestamp != null)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Last updated: ${state.timestamp!.toLocal()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Loading indicator overlay
                if (state.isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          }
          
          return Center(child: Text('No data available'));
        },
      ),
    );
  }
}
```

### Which Approach Should I Use?

| Feature | Interceptor 🚀 | Repository Pattern 🏗️ |
|---------|---------------|----------------------|
| **Setup Time** | 3 lines of code | Moderate refactoring |
| **Existing Code** | Works as-is ✅ | Requires changes |
| **State Management** | Manual | Automatic (reactive) |
| **UI Updates** | Call setState() | StreamBuilder auto-updates |
| **Learning Curve** | Minimal | Medium |
| **Best For** | Quick wins, existing apps | Clean architecture, new features |

**Quick Decision:**
- 🚀 **Use Interceptor** if you want caching NOW with zero refactoring
- 🏗️ **Use Repository** if you're building new features or want reactive streams
- 💡 **Use Both!** They work together perfectly

[→ Interceptor Guide](doc/INTERCEPTOR_GUIDE.md) | [→ Repository Guide](#2-create-a-repository)

## 📚 Core Concepts

### Cache State

The `CacheTtlEtagState<T>` class contains all information needed by your UI:

```dart
class CacheTtlEtagState<T> {
  final T? data;              // Cached data
  final bool isLoading;       // Fetch in progress
  final bool isStale;         // Cache exceeded TTL
  final Object? error;        // Error if fetch failed
  final DateTime? timestamp;  // Last update time
  final int? ttlSeconds;      // Time-to-live
  final String? etag;         // ETag value
  
  bool get hasData;           // Has cached data
  bool get hasError;          // Has error
  bool get isEmpty;           // No data, not loading
  bool get isExpired;         // Cache has expired
  Duration? get timeUntilExpiry; // Remaining cache time
}
```

### Cache Lifecycle

```
┌─────────────────────────────────────────────────────┐
│                   Fetch Request                     │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │   Check Local Cache    │
         └────────┬───────────────┘
                  │
      ┌───────────┴───────────┐
      │                       │
      ▼                       ▼
┌──────────┐          ┌──────────────┐
│  Fresh   │          │  Stale/Empty │
│  Cache   │          │    Cache     │
└────┬─────┘          └───────┬──────┘
     │                        │
     │                        ▼
     │              ┌─────────────────┐
     │              │ Network Request │
     │              │  with ETag/IMS  │
     │              └────────┬────────┘
     │                       │
     │          ┌────────────┴────────────┐
     │          │                         │
     │          ▼                         ▼
     │    ┌──────────┐            ┌────────────┐
     │    │   304    │            │    200     │
     │    │Not Modified          │  New Data  │
     │    └────┬─────┘            └─────┬──────┘
     │         │                        │
     │         ▼                        ▼
     │  ┌──────────────┐      ┌────────────────┐
     │  │Update TTL &  │      │  Update Cache  │
     │  │  Timestamp   │      │  with New Data │
     │  └──────┬───────┘      └────────┬───────┘
     │         │                       │
     └─────────┴───────────────────────┘
                     │
                     ▼
            ┌────────────────┐
            │  Emit Update   │
            │   to Streams   │
            └────────────────┘
```

## 🔐 Encryption

### Enable Encryption

Enable encryption during initialization:

```dart
await NeeroTtlEtagCache.init(enableEncryption: true);
```

### How It Works

- **AES-256-CBC** encryption algorithm
- **Secure key storage** using Flutter Secure Storage
- **Unique IV** for each cache entry
- **Transparent** encryption/decryption in repositories
- **Per-user keys** supported (optional)

### Migrate Existing Cache

Convert between encrypted and plain cache:

```dart
// Enable encryption on existing plain cache
await NeeroTtlEtagCache.migrateEncryption(enableEncryption: true);

// Disable encryption
await NeeroTtlEtagCache.migrateEncryption(enableEncryption: false);
```

### Security Best Practices

```dart
// On user logout - clear cache and reset key
await NeeroTtlEtagCache.clearAndResetEncryption();

// Per-user encryption
final encryption = EncryptionService();
await encryption.initForUser(userId);

// Delete user's key on logout
await encryption.deleteUserKey(userId);
```

## 🎯 Advanced Usage

### Custom Cache Keys

```dart
final repo = CachedTtlEtagRepository<List<Post>>(
  url: 'https://api.example.com/posts',
  body: {'category': 'tech', 'limit': 10},
  fromJson: (json) => (json as List).map((e) => Post.fromJson(e)).toList(),
  getCacheKey: (url, body) {
    // Custom key generation
    return '$url?category=${body!['category']}&limit=${body['limit']}';
  },
);
```

### Extract Data from Response

```dart
final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/user',
  fromJson: (json) => User.fromJson(json),
  getDataFromResponseData: (responseData) {
    // Extract data from nested response
    return responseData['data']['user'];
  },
);
```

### Custom TTL

```dart
// Use server's cache headers
final repo = CachedTtlEtagRepository<News>(
  url: 'https://api.example.com/news',
  fromJson: (json) => News.fromJson(json),
  // No defaultTtl - uses Cache-Control: max-age or Expires header
);

// Override with custom TTL
final repo = CachedTtlEtagRepository<Weather>(
  url: 'https://api.example.com/weather',
  fromJson: (json) => Weather.fromJson(json),
  defaultTtl: Duration(minutes: 10), // Cache for 10 minutes
);
```

### Force Refresh

```dart
// Force refresh bypassing cache
await repository.refresh();

// OR
await repository.fetch(forceRefresh: true);
```

### POST Requests

```dart
final repo = CachedTtlEtagRepository<SearchResult>(
  url: 'https://api.example.com/search',
  method: 'POST',
  body: {'query': 'flutter', 'page': 1},
  fromJson: (json) => SearchResult.fromJson(json),
);
```

### Manual Cache Control

```dart
// Invalidate specific cache
await NeeroTtlEtagCache.invalidate<User>(
  url: 'https://api.example.com/user/123',
);

// Clear all cache
await NeeroTtlEtagCache.clearAll();

// Manual refetch
await NeeroTtlEtagCache.refetch<User>(
  url: 'https://api.example.com/user/123',
  fromJson: (json) => User.fromJson(json),
  forceRefresh: true,
);
```

### Cache Statistics

```dart
final cache = ReactiveCacheDio();
final stats = await cache.getStatistics();

print('Total entries: ${stats.totalEntries}');
print('Encrypted: ${stats.encryptedEntries}');
print('Plain: ${stats.plainEntries}');
print('Stale: ${stats.staleEntries}');
print('Expired: ${stats.expiredEntries}');
```

## 🔄 Combining Multiple Repositories

### Parallel Data Loading

```dart
import 'package:rxdart/rxdart.dart';

class DashboardRepository {
  final userRepo = CachedTtlEtagRepository<User>(/*...*/);
  final postsRepo = CachedTtlEtagRepository<List<Post>>(/*...*/);
  final statsRepo = CachedTtlEtagRepository<Stats>(/*...*/);
  
  Stream<DashboardData> get combinedStream {
    return Rx.combineLatest3(
      userRepo.stream,
      postsRepo.stream,
      statsRepo.stream,
      (userState, postsState, statsState) {
        return DashboardData(
          user: userState.data,
          posts: postsState.data,
          stats: statsState.data,
          isLoading: userState.isLoading || 
                     postsState.isLoading || 
                     statsState.isLoading,
          isStale: userState.isStale || 
                   postsState.isStale || 
                   statsState.isStale,
        );
      },
    );
  }
  
  Future<void> refreshAll() {
    return Future.wait([
      userRepo.refresh(),
      postsRepo.refresh(),
      statsRepo.refresh(),
    ]);
  }
  
  void dispose() {
    userRepo.dispose();
    postsRepo.dispose();
    statsRepo.dispose();
  }
}
```

### Dependent Data Loading

```dart
class UserPostsRepository {
  final userRepo = CachedTtlEtagRepository<User>(/*...*/);
  late CachedTtlEtagRepository<List<Post>> postsRepo;
  
  Stream<CombinedState> get stream {
    return userRepo.stream.switchMap((userState) {
      if (userState.hasData) {
        postsRepo = CachedTtlEtagRepository<List<Post>>(
          url: 'https://api.example.com/users/${userState.data!.id}/posts',
          fromJson: (json) => (json as List).map((e) => Post.fromJson(e)).toList(),
        );
        
        return postsRepo.stream.map((postsState) {
          return CombinedState(
            user: userState.data,
            posts: postsState.data,
            isLoading: userState.isLoading || postsState.isLoading,
          );
        });
      }
      
      return Stream.value(CombinedState(user: userState.data));
    });
  }
}
```

## 🧪 Testing

### Mock the Cache

```dart
class MockReactiveCacheDio extends Mock implements ReactiveCacheDio {}

void main() {
  group('UserRepository', () {
    late MockReactiveCacheDio mockCache;
    late UserRepository repository;
    
    setUp(() {
      mockCache = MockReactiveCacheDio();
      repository = UserRepository(cache: mockCache);
    });
    
    test('fetch should load user data', () async {
      when(() => mockCache.fetchReactive<User>(
        url: any(named: 'url'),
        fromJson: any(named: 'fromJson'),
      )).thenAnswer((_) async {});
      
      await repository.fetch();
      
      verify(() => mockCache.fetchReactive<User>(
        url: any(named: 'url'),
        fromJson: any(named: 'fromJson'),
      )).called(1);
    });
  });
}
```

## 🛠️ Configuration

### Custom Dio Instance

```dart
final customDio = Dio(
  BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  ),
);

customDio.interceptors.add(LogInterceptor());

await NeeroTtlEtagCache.init(
  dio: customDio,
  enableEncryption: true,
);
```

### Environment-Based Configuration

```dart
class CacheConfig {
  static Future<void> initialize() async {
    // Enable encryption only in production
    final enableEncryption = kReleaseMode;
    
    await NeeroTtlEtagCache.init(
      enableEncryption: enableEncryption,
    );
    
    print('Cache initialized with encryption: $enableEncryption');
  }
}
```

## 📊 Performance Considerations

### Best Practices

1. **Choose appropriate TTL values**
   ```dart
   // Frequently changing data - short TTL
   defaultTtl: Duration(minutes: 1)
   
   // Stable data - longer TTL
   defaultTtl: Duration(hours: 24)
   ```

2. **Dispose repositories** when no longer needed
   ```dart
   @override
   void dispose() {
     repository.dispose();
     super.dispose();
   }
   ```

3. **Use conditional requests** for bandwidth optimization
   - The cache automatically uses `If-None-Match` (ETag) and `If-Modified-Since` headers
   - Server should respond with `304 Not Modified` when possible

4. **Enable encryption selectively**
   - Only enable encryption for sensitive data
   - Plain cache is faster but less secure

5. **Clean up duplicates** after migration
   ```dart
   final cache = ReactiveCacheDio();
   await cache.cleanupDuplicates();
   ```

## 🐛 Troubleshooting

### Common Issues

**1. "EncryptionService not initialized"**
```dart
// Solution: Initialize cache with encryption enabled
await NeeroTtlEtagCache.init(enableEncryption: true);
```

**2. "Cache is encrypted but encryption is not enabled"**
```dart
// Solution: Either enable encryption or migrate to plain cache
await NeeroTtlEtagCache.migrateEncryption(enableEncryption: false);
```

**3. Data not updating**
```dart
// Solution: Check TTL and force refresh if needed
await repository.refresh();
```

**4. Memory leaks**
```dart
// Solution: Always dispose repositories
@override
void dispose() {
  repository.dispose();
  super.dispose();
}
```

## 📝 API Reference

### NeeroTtlEtagCache

Main entry point for cache operations.

| Method | Description |
|--------|-------------|
| `init({dio, enableEncryption})` | Initialize the cache system |
| `refetch<T>({...})` | Fetch data with caching |
| `invalidate<T>({url, body})` | Delete specific cache entry |
| `clearAll()` | Clear all cached data |
| `clearAndResetEncryption()` | Clear cache and reset encryption key |
| `migrateEncryption({enableEncryption})` | Migrate between encryption modes |
| `isEncryptionEnabled` | Check if encryption is enabled |

### CachedTtlEtagRepository<T>

Repository for accessing cached data.

| Property/Method | Description |
|-----------------|-------------|
| `stream` | Stream of state updates |
| `state` | Current state snapshot |
| `fetch({forceRefresh})` | Fetch data from network |
| `refresh()` | Force refresh from network |
| `invalidate()` | Delete cache entry |
| `dispose()` | Clean up resources |

### CacheTtlEtagState<T>

State container for cached data.

| Property | Description |
|----------|-------------|
| `data` | Cached data of type T |
| `isLoading` | Fetch in progress |
| `isStale` | Cache exceeded TTL |
| `error` | Error if fetch failed |
| `timestamp` | Last update time |
| `ttlSeconds` | Time-to-live |
| `etag` | ETag value |
| `hasData` | Has cached data |
| `hasError` | Has error |
| `isEmpty` | No data, not loading |
| `isExpired` | Cache has expired |
| `timeUntilExpiry` | Remaining cache time |

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with [Isar Database](https://isar.dev/)
- Encryption powered by [encrypt](https://pub.dev/packages/encrypt)
- HTTP client using [Dio](https://pub.dev/packages/dio)
- Reactive streams with [RxDart](https://pub.dev/packages/rxdart)

## 📧 Support

For issues, questions, or suggestions, please open an issue on our GitHub repository.

---

Made with ❤️ by the Neero Team