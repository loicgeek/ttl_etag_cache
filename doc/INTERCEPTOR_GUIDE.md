# Interceptor Guide - Zero-Code Integration

## 🚀 The Game Changer

The `CacheTtlEtagInterceptor` allows you to add caching to **existing apps** with just **3 lines of code**. No refactoring needed!

## ⚡ Quick Start

### Before (No Caching)

```dart
final dio = Dio();

// Your existing code - unchanged
final response = await dio.get('https://api.example.com/users');
final user = User.fromJson(response.data);
```

### After (With Caching!)

```dart
final dio = Dio();

// Add these 3 lines
dio.interceptors.add(
  CacheTtlEtagInterceptor(
    enableEncryption: true,
    defaultTtl: Duration(minutes: 5),
  ),
);

// Your existing code - UNCHANGED!
final response = await dio.get('https://api.example.com/users');
final user = User.fromJson(response.data);
```

**That's it!** All your API calls are now cached with TTL and ETag support.

## 📋 Features

✅ **Zero code changes** - Works with existing Dio calls
✅ **Automatic caching** - All GET requests cached by default
✅ **Smart strategies** - Configure per-endpoint behavior
✅ **ETag support** - Automatic 304 Not Modified handling
✅ **Offline fallback** - Returns stale cache on network errors
✅ **Optional encryption** - Toggle with one parameter
✅ **Custom rules** - Fine-grained control per endpoint

## 🎯 Use Cases

### 1. Drop-In for Existing Apps

**Perfect when:**
- You have an existing Dio-based app
- Don't want to refactor to repository pattern
- Need quick offline support
- Want to save bandwidth immediately

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize your Dio instance as usual
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
  ));
  
  // Add cache interceptor - that's it!
  dio.interceptors.add(
    CacheTtlEtagInterceptor(
      enableEncryption: true,
      defaultTtl: Duration(minutes: 5),
    ),
  );
  
  // Inject dio globally or via dependency injection
  GetIt.instance.registerSingleton<Dio>(dio);
  
  runApp(MyApp());
}
```

### 2. Mixed Strategy App

**Perfect when:**
- Some endpoints need caching
- Others need real-time data
- Different TTLs for different data

```dart
dio.interceptors.add(
  CacheTtlEtagInterceptor(
    enableEncryption: true,
    defaultStrategy: CacheStrategy.cacheFirst,
    rules: {
      // User profile - cache for 10 minutes
      '/users': CacheRule.cacheFirst(
        ttl: Duration(minutes: 10),
      ),
      
      // Posts feed - cache for 1 minute
      '/posts': CacheRule.cacheFirst(
        ttl: Duration(minutes: 1),
      ),
      
      // Real-time messages - never cache
      '/messages': CacheRule.networkOnly(),
      
      // Static content - cache for 24 hours
      '/content': CacheRule.cacheFirst(
        ttl: Duration(hours: 24),
      ),
    },
  ),
);
```

### 3. Gradual Migration

**Perfect when:**
- Migrating from no caching
- Want to test on specific endpoints first
- Need to prove value before full adoption

```dart
// Week 1: Only cache user endpoints
dio.interceptors.add(
  CacheTtlEtagInterceptor(
    defaultStrategy: CacheStrategy.networkOnly, // Don't cache by default
    rules: {
      '/users': CacheRule.cacheFirst(ttl: Duration(minutes: 5)),
    },
  ),
);

// Week 2: Add product caching
// Week 3: Add feed caching
// Week 4: Make caching the default
```

## 🛠️ Configuration Options

### Basic Configuration

```dart
CacheTtlEtagInterceptor(
  // Enable AES-256 encryption
  enableEncryption: true,
  
  // Default TTL for all cached requests
  defaultTtl: Duration(minutes: 5),
  
  // Default strategy for all requests
  defaultStrategy: CacheStrategy.cacheFirst,
)
```

### Advanced Configuration

```dart
CacheTtlEtagInterceptor(
  enableEncryption: true,
  defaultTtl: Duration(minutes: 5),
  defaultStrategy: CacheStrategy.cacheFirst,
  
  // Per-endpoint rules
  rules: {
    '/api/users': CacheRule(
      strategy: CacheStrategy.cacheFirst,
      ttl: Duration(minutes: 10),
    ),
    '/api/posts': CacheRule(
      strategy: CacheStrategy.staleWhileRevalidate,
      ttl: Duration(minutes: 2),
    ),
    '/api/realtime': CacheRule.networkOnly(),
  },
  
  // Custom cache key generator
  getCacheKey: (url, body) {
    // Include user ID in cache key
    return '$url?userId=$currentUserId';
  },
)
```

## 📚 Cache Strategies

### 1. Cache First (Default)

Try cache first, fallback to network if not found or expired.

```dart
rules: {
  '/users': CacheRule.cacheFirst(ttl: Duration(minutes: 5)),
}
```

**Best for:**
- User profiles
- Settings
- Static content
- Slow-changing data

**Behavior:**
1. Check cache
2. If valid, return immediately
3. If stale/missing, fetch from network
4. Update cache

### 2. Network First

Try network first, fallback to cache on error.

```dart
rules: {
  '/posts': CacheRule.networkFirst(ttl: Duration(minutes: 1)),
}
```

**Best for:**
- Feeds with frequent updates
- Price data
- Inventory

**Behavior:**
1. Try network request
2. If successful, update cache and return
3. If fails, return stale cache (if available)

### 3. Cache Only

Only use cache, never make network requests.

```dart
rules: {
  '/static': CacheRule.cacheOnly(ttl: Duration(days: 30)),
}
```

**Best for:**
- App configuration (pre-loaded)
- Static assets
- Offline-only mode

**Behavior:**
1. Check cache
2. If found, return
3. If not found, throw error

### 4. Network Only

Never use cache, always make network requests.

```dart
rules: {
  '/messages': CacheRule.networkOnly(),
}
```

**Best for:**
- Real-time data
- Payment transactions
- Authentication

**Behavior:**
1. Always make network request
2. Never cache

### 5. Stale While Revalidate

Return stale cache immediately, refresh in background.

```dart
rules: {
  '/feed': CacheRule.staleWhileRevalidate(ttl: Duration(seconds: 30)),
}
```

**Best for:**
- News feeds
- Social media
- Dashboard data

**Behavior:**
1. Return stale cache immediately (if exists)
2. Fetch fresh data in background
3. Update cache for next request

## 💡 Per-Request Control

### Force Refresh

Bypass cache for a specific request:

```dart
final response = await dio.get(
  '/users/123',
  options: Options(
    headers: {'X-Force-Refresh': 'true'},
  ),
);
```

### Custom Strategy per Request

Override default strategy:

```dart
final response = await dio.get(
  '/critical-data',
  options: Options(
    headers: {'X-Cache-Strategy': 'networkFirst'},
  ),
);
```

## 🔍 Cache Inspection

### Check if Response Came from Cache

```dart
final response = await dio.get('/users');

if (response.headers.value('x-cache-hit') == 'true') {
  print('Loaded from cache!');
  print('Age: ${response.headers.value('x-cache-age')} seconds');
  print('Stale: ${response.headers.value('x-cache-stale')}');
}
```

### Invalidate Cache Programmatically

```dart
// Get interceptor instance
final cacheInterceptor = dio.interceptors
    .whereType<CacheTtlEtagInterceptor>()
    .first;

// Invalidate specific pattern
await cacheInterceptor.invalidate('/users');

// Or clear all
await cacheInterceptor.clearAll();
```

## 🎨 Common Patterns

### Pattern 1: User-Specific Caching

```dart
String? currentUserId;

dio.interceptors.add(
  CacheTtlEtagInterceptor(
    enableEncryption: true,
    getCacheKey: (url, body) {
      // Include user ID in cache key
      return currentUserId != null 
          ? '$url?user=$currentUserId'
          : url;
    },
  ),
);

// On logout, clear cache
await cacheInterceptor.clearAll();
```

### Pattern 2: Environment-Specific Rules

```dart
dio.interceptors.add(
  CacheTtlEtagInterceptor(
    enableEncryption: kReleaseMode, // Only encrypt in production
    defaultTtl: kDebugMode 
        ? Duration(seconds: 10)  // Short TTL in debug
        : Duration(minutes: 5),  // Normal TTL in production
    defaultStrategy: kDebugMode
        ? CacheStrategy.networkFirst  // Always fresh in debug
        : CacheStrategy.cacheFirst,   // Cache-first in production
  ),
);
```

### Pattern 3: Conditional Caching

```dart
dio.interceptors.add(
  CacheTtlEtagInterceptor(
    enableEncryption: true,
    defaultStrategy: CacheStrategy.cacheFirst,
    rules: {
      // Don't cache if query contains 'nocache'
      RegExp(r'nocache=true'): CacheRule.networkOnly(),
      
      // Cache profile pages longer
      RegExp(r'/users/\d+$'): CacheRule.cacheFirst(
        ttl: Duration(minutes: 15),
      ),
    },
  ),
);
```

### Pattern 4: Progressive Web App (PWA) Style

```dart
dio.interceptors.add(
  CacheTtlEtagInterceptor(
    enableEncryption: true,
    // Return cache immediately, refresh in background
    defaultStrategy: CacheStrategy.staleWhileRevalidate,
    defaultTtl: Duration(minutes: 5),
  ),
);

// This gives users instant load times while keeping data fresh
```

## ⚠️ Important Notes

### What Gets Cached

By default, only **GET requests** are cached. This is intentional because:
- POST/PUT/DELETE are typically not idempotent
- They modify server state
- Caching them can lead to unexpected behavior

To cache POST requests (use carefully!):

```dart
// Not recommended - shown for completeness
// You'd need to modify the interceptor's _isCacheable method
```

### Headers Added to Responses

When a response comes from cache, these headers are added:

- `x-cache-hit: true` - Response came from cache
- `x-cache-age: <seconds>` - Age of cached data
- `x-cache-stale: <true|false>` - Whether cache was stale

Use these for debugging and analytics.

### Performance Considerations

1. **Encryption adds ~10ms per request** - Only enable for sensitive data
2. **First request always hits network** - Cache needs to be populated
3. **Large responses take longer to cache** - Consider compression
4. **Cache size grows over time** - Implement cleanup strategy

## 🧪 Testing

### Mock the Interceptor

```dart
// In tests, use a mock Dio without the interceptor
final testDio = Dio();

// Or use MockDio from dio_test package
final mockDio = MockDio();
```

### Test Cache Behavior

```dart
test('should return cached response', () async {
  final dio = Dio();
  dio.interceptors.add(
    CacheTtlEtagInterceptor(
      defaultTtl: Duration(hours: 1),
    ),
  );
  
  // First request - hits network
  final response1 = await dio.get('/test');
  expect(response1.headers.value('x-cache-hit'), isNull);
  
  // Second request - hits cache
  final response2 = await dio.get('/test');
  expect(response2.headers.value('x-cache-hit'), 'true');
});
```

## 🚀 Migration Guide

### From No Caching

1. Add interceptor to existing Dio instance
2. Test on one endpoint first
3. Gradually expand to all endpoints
4. Monitor performance and cache hit rates

### From Other Caching Solutions

1. Remove old caching code
2. Add interceptor
3. Configure rules to match old behavior
4. Test thoroughly
5. Remove old cache storage

### From Repository Pattern

You can **use both** approaches:
- Interceptor for automatic caching
- Repository for complex state management

```dart
// Interceptor handles basic caching
dio.interceptors.add(CacheTtlEtagInterceptor(...));

// Repository adds state management
final userRepo = CachedTtlEtagRepository<User>(
  url: '/users/me',
  fromJson: User.fromJson,
  cache: ReactiveCacheDio(),  // Uses same underlying cache
);
```

## 💡 Pro Tips

1. **Start conservative** - Use short TTLs initially
2. **Monitor cache hits** - Use headers to track effectiveness
3. **Clear on logout** - Always clear cache when user logs out
4. **Test offline** - Verify behavior with network disabled
5. **Encrypt sensitive data** - Enable encryption for user data
6. **Use strategies wisely** - Match strategy to data freshness needs
7. **Invalidate on mutations** - Clear cache after POST/PUT/DELETE
8. **Set reasonable defaults** - Don't cache everything forever

## 🎯 Best Practices

### DO

✅ Use short TTLs for frequently changing data
✅ Use longer TTLs for static content
✅ Clear cache on logout
✅ Test offline behavior
✅ Monitor cache effectiveness
✅ Use network-only for sensitive operations
✅ Invalidate related caches on mutations

### DON'T

❌ Cache everything forever
❌ Cache sensitive authentication data without encryption
❌ Forget to test with network disabled
❌ Use cache-only without fallback
❌ Cache POST/PUT/DELETE requests
❌ Ignore cache headers from server
❌ Set TTL longer than server's cache-control

## 📊 Comparison: Interceptor vs Repository

| Feature | Interceptor | Repository |
|---------|------------|------------|
| Code changes | Minimal (3 lines) | Moderate (refactor to repos) |
| Existing code | Works as-is | Requires refactoring |
| State management | No | Yes (with streams) |
| UI updates | Manual | Automatic (reactive) |
| Learning curve | Low | Medium |
| Flexibility | Good | Excellent |
| Best for | Quick wins | Clean architecture |

**Recommendation:** Use interceptor for quick integration, repository for new features or refactored code.

## 🔗 Related Documentation

- [Repository Pattern Guide](../README.md#repository-pattern)
- [Cache Strategies Deep Dive](./CACHE_STRATEGIES.md)
- [Performance Optimization](./PERFORMANCE.md)
- [API Reference](./API.md)

---

**The interceptor is perfect for getting started quickly. You can always refactor to the repository pattern later!** 🚀