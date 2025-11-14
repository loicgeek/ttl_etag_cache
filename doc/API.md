# API Documentation

Complete API reference for TTL/ETag Cache.

## Table of Contents

- [TtlEtagCache](#ttletagcache)
- [CachedTtlEtagRepository](#cachedttletagrepository)
- [CacheTtlEtagState](#cachettle tagstate)
- [ReactiveCacheDio](#reactivecachedeo)
- [EncryptionService](#encryptionservice)
- [CachedTtlEtagResponse](#cachedttletagresponse)

---

## TtlEtagCache

Main entry point for cache operations.

### Static Methods

#### `init`

Initialize the cache system.

```dart
static Future<void> init({
  Dio? dio,
  bool enableEncryption = false,
})
```

**Parameters:**
- `dio` (optional): Custom Dio instance for HTTP requests
- `enableEncryption` (optional): Enable AES-256 encryption (default: false)

**Example:**
```dart
await TtlEtagCache.init(enableEncryption: true);
```

---

#### `refetch`

Fetch or refetch data with caching.

```dart
static Future<void> refetch<T>({
  required String url,
  String method = 'GET',
  Map<String, dynamic>? body,
  Map<String, String>? headers,
  Duration? defaultTtl,
  bool forceRefresh = false,
  required T Function(dynamic) fromJson,
  String Function(String url, Map<String, dynamic>? body)? getCacheKey,
  String Function(dynamic responseData)? getDataFromResponseData,
})
```

**Parameters:**
- `url` (required): The URL to fetch
- `method`: HTTP method (default: 'GET')
- `body`: Request body for POST/PUT requests
- `headers`: Additional HTTP headers
- `defaultTtl`: Default cache time-to-live
- `forceRefresh`: Force network request ignoring cache
- `fromJson` (required): Deserialization function
- `getCacheKey`: Custom cache key generator
- `getDataFromResponseData`: Extract data from nested responses

**Example:**
```dart
await TtlEtagCache.refetch<User>(
  url: 'https://api.example.com/user/123',
  defaultTtl: Duration(minutes: 5),
  fromJson: (json) => User.fromJson(json),
  forceRefresh: true,
);
```

---

#### `invalidate`

Delete a specific cache entry.

```dart
static Future<void> invalidate<T>({
  required String url,
  Map<String, dynamic>? body,
  String Function(String url, Map<String, dynamic>? body)? getCacheKey,
})
```

**Example:**
```dart
await TtlEtagCache.invalidate<User>(
  url: 'https://api.example.com/user/123',
);
```

---

#### `clearAll`

Clear all cached data.

```dart
static Future<void> clearAll()
```

**Example:**
```dart
await TtlEtagCache.clearAll();
```

---

#### `clearAndResetEncryption`

Clear all cache and reset the encryption key.

```dart
static Future<void> clearAndResetEncryption()
```

**Example:**
```dart
// On user logout
await TtlEtagCache.clearAndResetEncryption();
```

---

#### `migrateEncryption`

Migrate cache between encryption modes.

```dart
static Future<void> migrateEncryption({
  required bool enableEncryption,
})
```

**Parameters:**
- `enableEncryption`: True to enable encryption, false to disable

**Example:**
```dart
// Enable encryption on existing cache
await TtlEtagCache.migrateEncryption(enableEncryption: true);

// Disable encryption
await TtlEtagCache.migrateEncryption(enableEncryption: false);
```

---

### Static Properties

#### `isEncryptionEnabled`

Check if encryption is currently enabled.

```dart
static bool get isEncryptionEnabled
```

**Example:**
```dart
if (TtlEtagCache.isEncryptionEnabled) {
  print('Cache is encrypted');
}
```

---

## CachedTtlEtagRepository

Repository pattern implementation for cached data access.

### Constructor

```dart
CachedTtlEtagRepository<T>({
  required String url,
  required T Function(dynamic) fromJson,
  ReactiveCacheDio? cache,
  String method = 'GET',
  Map<String, dynamic>? body,
  Map<String, String>? headers,
  Duration? defaultTtl,
  String Function(String url, Map<String, dynamic>? body)? getCacheKey,
  String Function(dynamic responseData)? getDataFromResponseData,
})
```

**Type Parameters:**
- `T`: The type of data to cache

**Parameters:**
- `url` (required): The API endpoint
- `fromJson` (required): Function to deserialize JSON to type T
- `cache`: Custom ReactiveCacheDio instance (optional)
- `method`: HTTP method (default: 'GET')
- `body`: Request body
- `headers`: HTTP headers
- `defaultTtl`: Cache time-to-live
- `getCacheKey`: Custom cache key generator
- `getDataFromResponseData`: Response data extractor

**Example:**
```dart
final userRepo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/user/123',
  fromJson: (json) => User.fromJson(json),
  defaultTtl: Duration(minutes: 5),
  headers: {'Authorization': 'Bearer $token'},
);
```

---

### Properties

#### `stream`

Stream of cache state updates.

```dart
Stream<CacheTtlEtagState<T>> get stream
```

**Returns:** Stream that emits new states on cache updates

**Example:**
```dart
userRepo.stream.listen((state) {
  if (state.hasData) {
    print('User: ${state.data!.name}');
  }
});
```

---

#### `state`

Current state snapshot.

```dart
CacheTtlEtagState<T> get state
```

**Returns:** Current cache state

**Example:**
```dart
final currentState = userRepo.state;
print('Has data: ${currentState.hasData}');
```

---

### Methods

#### `fetch`

Fetch data from the network.

```dart
Future<void> fetch({bool forceRefresh = false})
```

**Parameters:**
- `forceRefresh`: If true, bypasses cache validation

**Example:**
```dart
// Normal fetch (uses cache if valid)
await userRepo.fetch();

// Force refresh
await userRepo.fetch(forceRefresh: true);
```

---

#### `refresh`

Force refresh from the network.

```dart
Future<void> refresh()
```

Shorthand for `fetch(forceRefresh: true)`.

**Example:**
```dart
await userRepo.refresh();
```

---

#### `invalidate`

Delete the cache entry.

```dart
Future<void> invalidate()
```

**Example:**
```dart
await userRepo.invalidate();
```

---

#### `dispose`

Clean up resources.

```dart
void dispose()
```

**Important:** Always call this when the repository is no longer needed to prevent memory leaks.

**Example:**
```dart
@override
void dispose() {
  userRepo.dispose();
  super.dispose();
}
```

---

## CacheTtlEtagState

Immutable state container for cached data.

### Constructor

```dart
const CacheTtlEtagState<T>({
  T? data,
  bool isLoading = false,
  bool isStale = false,
  Object? error,
  DateTime? timestamp,
  int? ttlSeconds,
  String? etag,
})
```

---

### Properties

#### `data`

The cached data of type T.

```dart
final T? data
```

---

#### `isLoading`

Whether a fetch operation is in progress.

```dart
final bool isLoading
```

---

#### `isStale`

Whether the cache has exceeded its TTL.

```dart
final bool isStale
```

---

#### `error`

Any error that occurred during operations.

```dart
final Object? error
```

---

#### `timestamp`

When the data was last updated.

```dart
final DateTime? timestamp
```

---

#### `ttlSeconds`

Time-to-live in seconds.

```dart
final int? ttlSeconds
```

---

#### `etag`

ETag value from the server.

```dart
final String? etag
```

---

### Computed Properties

#### `hasData`

Returns true if data is available.

```dart
bool get hasData => data != null
```

---

#### `hasError`

Returns true if an error occurred.

```dart
bool get hasError => error != null
```

---

#### `isEmpty`

Returns true if no data, not loading, and no error.

```dart
bool get isEmpty => data == null && !isLoading && error == null
```

---

#### `isExpired`

Returns true if cache has exceeded its TTL.

```dart
bool get isExpired
```

---

#### `timeUntilExpiry`

Remaining time until cache expires.

```dart
Duration? get timeUntilExpiry
```

**Returns:** Duration until expiry, or null if timestamp/ttl unavailable

---

### Methods

#### `copyWith`

Create a copy with modified fields.

```dart
CacheTtlEtagState<T> copyWith({
  T? data,
  bool? isLoading,
  bool? isStale,
  Object? error,
  DateTime? timestamp,
  int? ttlSeconds,
  String? etag,
})
```

**Example:**
```dart
final newState = state.copyWith(isLoading: false, error: null);
```

---

## ReactiveCacheDio

Core caching service (typically used internally by repositories).

### Methods

#### `init`

Initialize the cache system.

```dart
Future<void> init({
  Dio? dio,
  bool enableEncryption = false,
})
```

---

#### `fetchReactive`

Fetch data with reactive caching.

```dart
Future<void> fetchReactive<T>({
  required String url,
  String method = 'GET',
  Map<String, dynamic>? body,
  Map<String, String>? headers,
  Duration? defaultTtl,
  bool forceRefresh = false,
  required T Function(dynamic) fromJson,
  String Function(String url, Map<String, dynamic>? body)? getCacheKey,
  String Function(dynamic responseData)? getDataFromResponseData,
})
```

---

#### `invalidate`

Delete a cache entry.

```dart
Future<void> invalidate<T>({
  required String url,
  Map<String, dynamic>? body,
  String Function(String url, Map<String, dynamic>? body)? getCacheKey,
})
```

---

#### `clearAll`

Clear all cache.

```dart
Future<void> clearAll()
```

---

#### `clearAndResetEncryption`

Clear cache and reset encryption.

```dart
Future<void> clearAndResetEncryption()
```

---

#### `migrateEncryption`

Migrate between encryption modes.

```dart
Future<void> migrateEncryption({
  required bool enableEncryption,
})
```

---

#### `cleanupDuplicates`

Remove duplicate cache entries.

```dart
Future<void> cleanupDuplicates()
```

---

#### `getStatistics`

Get cache statistics.

```dart
Future<CacheStatistics> getStatistics()
```

**Returns:** CacheStatistics object with cache metrics

**Example:**
```dart
final stats = await cache.getStatistics();
print('Total entries: ${stats.totalEntries}');
print('Encrypted: ${stats.encryptedEntries}');
```

---

### Properties

#### `updateStream`

Stream that emits on cache updates.

```dart
Stream<void> get updateStream
```

---

#### `isEncryptionEnabled`

Whether encryption is enabled.

```dart
bool get isEncryptionEnabled
```

---

#### `isar`

Isar database instance.

```dart
late Isar isar
```

---

## EncryptionService

Service for AES-256 encryption.

### Methods

#### `init`

Initialize the encryption service.

```dart
Future<void> init()
```

**Example:**
```dart
final encryption = EncryptionService();
await encryption.init();
```

---

#### `initForUser`

Initialize with user-specific key.

```dart
Future<void> initForUser(String userId)
```

**Example:**
```dart
await encryption.initForUser('user123');
```

---

#### `encryptData`

Encrypt plain text data.

```dart
EncryptedData encryptData(String plainText)
```

**Returns:** EncryptedData with encrypted text and IV

**Example:**
```dart
final encrypted = encryption.encryptData('{"name": "John"}');
print(encrypted.encryptedText);
print(encrypted.iv);
```

---

#### `decryptData`

Decrypt encrypted data.

```dart
String decryptData(String encryptedText, String ivString)
```

**Returns:** Decrypted plain text

**Example:**
```dart
final plain = encryption.decryptData(
  encrypted.encryptedText,
  encrypted.iv,
);
```

---

#### `resetKey`

Generate new encryption key.

```dart
Future<void> resetKey()
```

**Warning:** Invalidates all existing encrypted cache.

---

#### `deleteKey`

Delete the encryption key.

```dart
Future<void> deleteKey()
```

---

#### `deleteUserKey`

Delete user-specific key.

```dart
Future<void> deleteUserKey(String userId)
```

---

### Properties

#### `isInitialized`

Whether the service is initialized.

```dart
bool get isInitialized
```

---

## CachedTtlEtagResponse

Isar collection model for cached responses.

### Properties

#### `id`

Unique identifier (auto-incremented).

```dart
Id id
```

---

#### `url`

Cache key (unique index).

```dart
late String url
```

---

#### `data`

Plain text data (when encryption disabled).

```dart
String? data
```

---

#### `encryptedData`

Encrypted data (when encryption enabled).

```dart
String? encryptedData
```

---

#### `iv`

Initialization vector for encryption.

```dart
String? iv
```

---

#### `etag`

ETag from server.

```dart
String? etag
```

---

#### `timestamp`

Last update time.

```dart
late DateTime timestamp
```

---

#### `ttlSeconds`

Time-to-live in seconds.

```dart
late int ttlSeconds
```

---

#### `isStale`

Whether cache exceeded TTL.

```dart
late bool isStale
```

---

#### `isEncrypted`

Whether entry is encrypted.

```dart
late bool isEncrypted
```

---

### Computed Properties

#### `ageInSeconds`

Cache age in seconds.

```dart
int get ageInSeconds
```

---

#### `isExpired`

Whether cache has expired.

```dart
bool get isExpired
```

---

#### `remainingTtl`

Remaining TTL in seconds.

```dart
int get remainingTtl
```

---

## Type Definitions

### CacheStatistics

```dart
class CacheStatistics {
  final int totalEntries;
  final int encryptedEntries;
  final int plainEntries;
  final int staleEntries;
  final int expiredEntries;
}
```

---

### EncryptedData

```dart
class EncryptedData {
  final String encryptedText;  // Base64 encoded
  final String iv;             // Base64 encoded
}
```

---

## Error Handling

All async methods may throw exceptions. Common errors:

- `Exception('EncryptionService not initialized')` - Encryption not initialized
- `Exception('Cache is encrypted but encryption is not enabled')` - Mismatch
- `DioException` - Network errors
- `FormatException` - Invalid encrypted data

**Example:**
```dart
try {
  await repository.fetch();
} on DioException catch (e) {
  print('Network error: ${e.message}');
} on Exception catch (e) {
  print('Error: $e');
}
```

---

## Best Practices

1. **Always dispose repositories**
   ```dart
   @override
   void dispose() {
     repository.dispose();
     super.dispose();
   }
   ```

2. **Use appropriate TTL values**
   ```dart
   // Fast-changing data
   defaultTtl: Duration(minutes: 1)
   
   // Slow-changing data
   defaultTtl: Duration(hours: 24)
   ```

3. **Handle all state cases**
   ```dart
   if (state.isEmpty && state.isLoading) { /* loading */ }
   if (state.hasError && !state.hasData) { /* error */ }
   if (state.hasData) { /* show data */ }
   ```

4. **Enable encryption for sensitive data**
   ```dart
   await TtlEtagCache.init(enableEncryption: true);
   ```

5. **Clear cache on logout**
   ```dart
   await TtlEtagCache.clearAndResetEncryption();
   ```

---

For more examples, see [../README.md](../README.md) and [../example/lib/main.dart](../example/lib/main.dart).