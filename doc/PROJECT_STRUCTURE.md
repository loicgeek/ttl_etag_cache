# Project Structure

Complete overview of the TTL/ETag Cache plugin structure.

```
ttl_etag_cache/
├── lib/
│   ├── ttl_etag_cache.dart          # Main library entry point
│   └── src/
│       ├── models/
│       │   ├── cached_ttl_etag_response.dart      # Isar model for cached data
│       │   ├── cached_ttl_etag_response.g.dart    # Generated Isar code
│       │   └── cache_ttl_etag_state.dart          # State management model
│       ├── services/
│       │   ├── reactive_ttl_etag_cache_dio.dart   # Core caching service
│       │   └── encryption_service.dart             # AES-256 encryption
│       └── repositories/
│           └── cached_ttl_etag_repository.dart    # Repository pattern
│
├── example/
│   └── lib/
│       └── main.dart                      # Example app with demos
│
├── doc/
│   ├── API.md                             # Complete API reference
│   └── MIGRATION.md                       # Migration guides
│
├── test/
│   ├── unit/
│   │   ├── encryption_service_test.dart
│   │   ├── cache_state_test.dart
│   │   └── repository_test.dart
│   └── integration/
│       └── cache_integration_test.dart
│
├── pubspec.yaml                           # Package dependencies
├── README.md                              # Main documentation
├── CHANGELOG.md                           # Version history
├── LICENSE                                # MIT License
└── analysis_options.yaml                  # Linting rules
```

## Core Components

### 1. Main Entry Point

**File:** `lib/ttl_etag_cache.dart`

The primary interface for the plugin. Exports all public APIs.

```dart
library ttl_etag_cache;

export 'src/services/reactive_ttl_etag_cache_dio.dart';
export 'src/services/encryption_service.dart';
export 'src/models/cached_ttl_etag_response.dart';
export 'src/models/cache_ttl_etag_state.dart';
export 'src/repositories/cached_ttl_etag_repository.dart';

class TtlEtagCache {
  static Future<void> init({...});
  static Future<void> refetch<T>({...});
  static Future<void> invalidate<T>({...});
  // ...
}
```

**Responsibilities:**
- Plugin initialization
- Static helper methods
- Public API exposure

---

### 2. Models

#### CachedTtlEtagResponse

**File:** `lib/src/models/cached_ttl_etag_response.dart`

Isar collection model for persistent storage.

```dart
@collection
class CachedTtlEtagResponse {
  Id id = Isar.autoIncrement;
  @Index(unique: true) late String url;
  String? data;
  String? encryptedData;
  String? iv;
  String? etag;
  late DateTime timestamp;
  late int ttlSeconds;
  late bool isStale;
  @Index() late bool isEncrypted;
}
```

**Responsibilities:**
- Database schema definition
- Cache entry structure
- Support for both plain and encrypted data

#### CacheTtlEtagState

**File:** `lib/src/models/cache_ttl_etag_state.dart`

Immutable state container for UI layer.

```dart
class CacheTtlEtagState<T> {
  final T? data;
  final bool isLoading;
  final bool isStale;
  final Object? error;
  final DateTime? timestamp;
  final int? ttlSeconds;
  final String? etag;
}
```

**Responsibilities:**
- UI state representation
- Computed properties (hasData, isEmpty, etc.)
- Immutable state updates via copyWith

---

### 3. Services

#### ReactiveCacheDio

**File:** `lib/src/services/reactive_ttl_etag_cache_dio.dart`

Core caching service with TTL and ETag support.

**Responsibilities:**
- HTTP request management
- Cache validation (TTL checking)
- ETag conditional requests
- Encryption/decryption coordination
- Database operations
- Stream broadcasting

**Key Methods:**
- `init()` - Initialize cache system
- `fetchReactive()` - Fetch with caching
- `invalidate()` - Delete cache entries
- `migrateEncryption()` - Change encryption mode

**Architecture:**
```
User Request
     ↓
Check Cache (Isar)
     ↓
Cache Valid? → Return Cached Data
     ↓ No
Mark as Stale
     ↓
HTTP Request (with ETag headers)
     ↓
304? → Update TTL, Return Cache
200? → Store New Data (with encryption)
     ↓
Broadcast Update
```

#### EncryptionService

**File:** `lib/src/services/encryption_service.dart`

AES-256 encryption management.

**Responsibilities:**
- Key generation and storage
- Data encryption/decryption
- Secure key management
- Per-user key support

**Security Features:**
- AES-256-CBC encryption
- Random IV per encryption
- Flutter Secure Storage for keys
- Key rotation support

---

### 4. Repository

#### CachedTtlEtagRepository

**File:** `lib/src/repositories/cached_ttl_etag_repository.dart`

Repository pattern implementation for cached data.

**Responsibilities:**
- Stream-based data access
- State management
- Automatic cache updates
- Resource cleanup

**Architecture:**
```
Repository
    ↓
Stream<CacheTtlEtagState<T>>
    ↓
StreamBuilder (UI)
    ↓
Automatic UI Updates
```

**Lifecycle:**
1. Constructor: Create state controller
2. _initialize(): Set up watchers
3. fetch(): Request data
4. _updateState(): Update stream
5. dispose(): Clean up resources

---

## Data Flow

### Read Flow

```
User Request
     ↓
Repository.fetch()
     ↓
ReactiveCacheDio.fetchReactive()
     ↓
Check Cache (Isar)
     ↓
Valid? → Return
Invalid? → HTTP Request
     ↓
Update Cache (with encryption if enabled)
     ↓
Emit Update Event
     ↓
Isar Watch Triggers
     ↓
Repository._updateState()
     ↓
Decrypt (if encrypted)
     ↓
Deserialize JSON
     ↓
Create State Object
     ↓
Stream Emits New State
     ↓
UI Updates
```

### Write Flow

```
HTTP Response
     ↓
Extract Data
     ↓
Encryption Enabled?
     ↓ Yes
EncryptionService.encryptData()
     ↓
Store Encrypted
     ↓ No
Store Plain
     ↓
Isar.put()
     ↓
Broadcast Update
```

---

## Dependencies

### Production Dependencies

```yaml
dio: ^5.4.0                      # HTTP client
isar_community: ^3.1.0+1         # Local database
rxdart: ^0.27.7                  # Reactive streams
encrypt: ^5.0.3                  # Encryption
flutter_secure_storage: ^9.0.0   # Secure key storage
crypto: ^3.0.3                   # Cryptographic functions
path_provider: ^2.1.1            # File system paths
```

### Development Dependencies

```yaml
build_runner: ^2.4.6             # Code generation
isar_generator_community: ^3.1.0+1  # Isar code gen
flutter_lints: ^3.0.0            # Linting rules
```

---

## Code Generation

### Required Generation

The plugin requires code generation for Isar models:

```bash
flutter pub run build_runner build
```

**Generated Files:**
- `cached_ttl_etag_response.g.dart` - Isar schema and adapters

**When to Regenerate:**
- After modifying `CachedTtlEtagResponse`
- After cloning the repository
- After updating Isar version

---

## Testing Structure

### Unit Tests

```
test/unit/
├── encryption_service_test.dart   # Encryption tests
├── cache_state_test.dart          # State model tests
├── repository_test.dart           # Repository tests
└── cache_dio_test.dart            # Core service tests
```

### Integration Tests

```
test/integration/
└── cache_integration_test.dart    # End-to-end tests
```

### Widget Tests

```
test/widget/
└── cached_widget_test.dart        # Widget integration tests
```

---

## Build Configuration

### analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: false
```

### pubspec.yaml Structure

```yaml
name: ttl_etag_cache
description: Reactive caching with TTL, ETag, and encryption
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  # Core dependencies

dev_dependencies:
  # Development tools
```

---

## Extension Points

### Custom Cache Keys

Users can provide custom cache key generators:

```dart
getCacheKey: (url, body) => 'custom_key_${body['id']}'
```

### Custom Data Extraction

Users can extract data from nested responses:

```dart
getDataFromResponseData: (responseData) => responseData['data']['user']
```

### Custom TTL

Users can override TTL calculation:

```dart
defaultTtl: Duration(minutes: 5)
```

---

## Performance Considerations

### Database Indexing

- `url` field: Unique index for fast lookups
- `isEncrypted` field: Index for filtering

### Memory Management

- Repositories: Must be disposed
- Streams: Automatically closed on dispose
- Subscriptions: Cancelled on dispose

### Optimization Tips

1. Use appropriate TTL values
2. Dispose repositories when done
3. Enable encryption only for sensitive data
4. Batch operations when possible
5. Monitor cache statistics

---

## Future Enhancements

Planned features for future versions:

- **Background Refresh**: Automatic cache updates
- **Cache Compression**: Reduce storage size
- **Size Limits**: Maximum cache size enforcement
- **Memory Cache**: Multi-level caching
- **Analytics**: Detailed cache metrics
- **WebSocket Support**: Real-time updates
- **GraphQL Support**: Query-based caching

---

## Contributing

When contributing:

1. Follow existing code structure
2. Add tests for new features
3. Update documentation
4. Run linter before committing
5. Maintain backward compatibility

---

## Resources

- [API Documentation](doc/API.md)
- [Migration Guide](doc/MIGRATION.md)
- [Example App](example/lib/main.dart)
- [README](README.md)
- [CHANGELOG](CHANGELOG.md)

---

For questions or issues, please open an issue on GitHub.