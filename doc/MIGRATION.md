# Migration Guide

Guide for migrating between different versions and configurations of TTL/ETag Cache.

## Table of Contents

- [Migrating to v1.0.0](#migrating-to-v100)
- [Enabling Encryption](#enabling-encryption)
- [Disabling Encryption](#disabling-encryption)
- [Changing Cache Keys](#changing-cache-keys)
- [Database Schema Changes](#database-schema-changes)

---

## Migrating to v1.0.0

### From No Caching Solution

If you're implementing caching for the first time:

**Step 1: Add Dependency**

```yaml
dependencies:
  ttl_etag_cache: ^1.0.0
```

**Step 2: Initialize**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TtlEtagCache.init();
  runApp(MyApp());
}
```

**Step 3: Create Repository**

```dart
final userRepo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/user',
  fromJson: (json) => User.fromJson(json),
  defaultTtl: Duration(minutes: 5),
);
```

**Step 4: Use in Widget**

```dart
StreamBuilder<CacheTtlEtagState<User>>(
  stream: userRepo.stream,
  builder: (context, snapshot) {
    final state = snapshot.data ?? CacheTtlEtagState<User>();
    // Handle states
  },
);
```

---

## Enabling Encryption

### On Fresh Install

Initialize with encryption enabled:

```dart
await TtlEtagCache.init(enableEncryption: true);
```

### On Existing Plain Cache

**Option 1: Migrate Existing Cache**

This preserves all cached data by encrypting it:

```dart
// Step 1: Enable encryption
await TtlEtagCache.migrateEncryption(enableEncryption: true);

// Step 2: Verify
print('Encryption enabled: ${TtlEtagCache.isEncryptionEnabled}');

// Step 3: Check statistics
final cache = ReactiveCacheDio();
final stats = await cache.getStatistics();
print('Encrypted entries: ${stats.encryptedEntries}');
```

**Option 2: Clear and Start Fresh**

This is faster but loses all cached data:

```dart
// Step 1: Clear existing cache
await TtlEtagCache.clearAll();

// Step 2: Reinitialize with encryption
await TtlEtagCache.init(enableEncryption: true);
```

**Recommended Approach:**

```dart
class CacheManager {
  static Future<void> enableEncryption() async {
    // Show loading indicator to user
    showLoadingDialog();
    
    try {
      // Migrate existing cache
      await TtlEtagCache.migrateEncryption(enableEncryption: true);
      
      // Save preference
      await SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool('cache_encryption', true),
      );
      
      showSuccessMessage('Encryption enabled successfully');
    } catch (e) {
      showErrorMessage('Failed to enable encryption: $e');
    } finally {
      hideLoadingDialog();
    }
  }
}
```

---

## Disabling Encryption

### Converting Encrypted Cache to Plain

```dart
// This decrypts all cache entries
await TtlEtagCache.migrateEncryption(enableEncryption: false);
```

**Important Notes:**

- Migration requires the original encryption key
- If the key is lost, you must clear cache instead
- Migration can take time with many entries

**If Key is Lost:**

```dart
// Clear cache and start fresh
await TtlEtagCache.clearAll();
await TtlEtagCache.init(enableEncryption: false);
```

---

## Changing Cache Keys

### From Simple URL to Custom Keys

If you need to change how cache keys are generated:

**Before:**
```dart
final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/user',
  fromJson: (json) => User.fromJson(json),
);
// Cache key: "https://api.example.com/user"
```

**After:**
```dart
final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/user',
  fromJson: (json) => User.fromJson(json),
  getCacheKey: (url, body) => 'user_cache_v2',
);
// Cache key: "user_cache_v2"
```

**Migration Strategy:**

```dart
// Step 1: Invalidate old cache
await TtlEtagCache.invalidate<User>(
  url: 'https://api.example.com/user',
);

// Step 2: Create new repository with custom key
final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/user',
  fromJson: (json) => User.fromJson(json),
  getCacheKey: (url, body) => 'user_cache_v2',
);

// Step 3: Fetch fresh data
await repo.fetch();
```

---

## Database Schema Changes

### Regenerating Isar Schema

If you modify the `CachedTtlEtagResponse` model:

**Step 1: Update Model**

```dart
@collection
class CachedTtlEtagResponse {
  // Add your changes
  late String newField;
}
```

**Step 2: Run Code Generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: Handle Migration**

```dart
// Clear cache if schema is incompatible
await TtlEtagCache.clearAll();

// Reinitialize
await TtlEtagCache.init();
```

---

## User Logout

### Proper Cleanup on Logout

```dart
Future<void> logout() async {
  // Clear all cache and reset encryption
  await TtlEtagCache.clearAndResetEncryption();
  
  // Or if using per-user encryption
  final encryption = EncryptionService();
  await encryption.deleteUserKey(currentUserId);
  
  // Navigate to login
  Navigator.of(context).pushReplacementNamed('/login');
}
```

---

## Multi-User Support

### Per-User Cache Keys

**Option 1: Include User ID in URL**

```dart
final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/users/$userId/profile',
  fromJson: (json) => User.fromJson(json),
);
```

**Option 2: Custom Cache Keys**

```dart
final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/profile',
  fromJson: (json) => User.fromJson(json),
  getCacheKey: (url, body) => 'user_${userId}_profile',
);
```

**Option 3: Per-User Encryption**

```dart
// On login
final encryption = EncryptionService();
await encryption.initForUser(userId);

// On logout
await encryption.deleteUserKey(userId);
```

---

## Version-Specific Cache

### Cache Versioning for API Changes

```dart
class ApiConfig {
  static const int apiVersion = 2;
}

final repo = CachedTtlEtagRepository<User>(
  url: 'https://api.example.com/v${ApiConfig.apiVersion}/user',
  fromJson: (json) => User.fromJson(json),
  getCacheKey: (url, body) => 'user_v${ApiConfig.apiVersion}',
);
```

---

## Performance Optimization

### Batch Operations

```dart
Future<void> refreshAllUserData() async {
  final repos = [
    userProfileRepo,
    userSettingsRepo,
    userStatsRepo,
  ];
  
  // Parallel refresh
  await Future.wait(repos.map((r) => r.refresh()));
}
```

### Cleanup Strategy

```dart
// Periodic cleanup
Timer.periodic(Duration(days: 1), (_) async {
  final cache = ReactiveCacheDio();
  
  // Remove duplicates
  await cache.cleanupDuplicates();
  
  // Check statistics
  final stats = await cache.getStatistics();
  if (stats.expiredEntries > 100) {
    // Optionally clear expired entries
    // (they're automatically refreshed on access)
  }
});
```

---

## Troubleshooting Migrations

### Common Issues

**1. "Failed to decrypt"**

```dart
// Solution: Clear cache and start fresh
await TtlEtagCache.clearAll();
await TtlEtagCache.init(enableEncryption: true);
```

**2. "Duplicate cache entries"**

```dart
// Solution: Run cleanup
final cache = ReactiveCacheDio();
await cache.cleanupDuplicates();
```

**3. "Cache not updating"**

```dart
// Solution: Force refresh
await repository.refresh();

// Or invalidate and refetch
await repository.invalidate();
await repository.fetch();
```

**4. "Memory usage too high"**

```dart
// Solution: Clear old cache
await TtlEtagCache.clearAll();

// Reduce TTL values
defaultTtl: Duration(minutes: 1)  // instead of hours
```

---

## Testing Migrations

```dart
void main() {
  group('Migration Tests', () {
    test('should migrate to encrypted cache', () async {
      // Setup plain cache
      await TtlEtagCache.init(enableEncryption: false);
      await TtlEtagCache.refetch<User>(
        url: 'https://api.example.com/user',
        fromJson: (json) => User.fromJson(json),
      );
      
      // Migrate to encrypted
      await TtlEtagCache.migrateEncryption(enableEncryption: true);
      
      // Verify
      expect(TtlEtagCache.isEncryptionEnabled, true);
      
      final stats = await ReactiveCacheDio().getStatistics();
      expect(stats.encryptedEntries, greaterThan(0));
    });
  });
}
```

---

For more help, see [README.md](../README.md) or open an issue on GitHub.