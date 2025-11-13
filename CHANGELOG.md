# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-11-13

### Added
- Added `CachedTtlEtagConfig` class for better configuration management
- Added `copyWith()` method to `CachedTtlEtagConfig` for easy configuration modification

### Changed
- **BREAKING**: `CachedTtlEtagRepository` now accepts a single `CachedTtlEtagConfig` parameter instead of multiple individual parameters
- Improved repository configuration pattern for better code organization and reusability

### Migration Guide
```dart
// Before (v1.0.x)
final repository = CachedTtlEtagRepository<MyModel>(
  url: 'https://api.example.com/data',
  fromJson: (json) => MyModel.fromJson(json),
  method: 'GET',
  headers: {'Authorization': 'Bearer token'},
  defaultTtl: Duration(minutes: 5),
);

// After (v1.0.2)
final config = CachedTtlEtagConfig<MyModel>(
  url: 'https://api.example.com/data',
  fromJson: (json) => MyModel.fromJson(json),
  method: 'GET',
  headers: {'Authorization': 'Bearer token'},
  defaultTtl: Duration(minutes: 5),
);
final repository = CachedTtlEtagRepository<MyModel>(config);
```

## [1.0.1] - 2025-11-10

### Added
- Added support for interceptor pattern

## [1.0.0] - 2025-11-10

### Added
- Initial release of Neero TTL/ETag Cache
- TTL (Time To Live) based cache expiration
- ETag support for conditional HTTP requests
- Optional AES-256 encryption for cached data
- Reactive stream-based architecture with RxDart
- Repository pattern implementation
- Isar database for persistent storage
- CacheTtlEtagState for comprehensive UI state management
- Support for custom cache keys
- Support for nested response data extraction
- GET and POST request support
- Cache migration between encryption modes
- Cache statistics and monitoring
- Automatic stale cache marking
- Network optimization with 304 Not Modified
- Offline-first capabilities
- Comprehensive documentation and examples
- Type-safe generic implementation
- BroadcastStream for multi-listener support

### Features
- `NeeroTtlEtagCache.init()` - Initialize cache system
- `NeeroTtlEtagCache.refetch()` - Fetch with caching
- `NeeroTtlEtagCache.invalidate()` - Delete cache entries
- `NeeroTtlEtagCache.clearAll()` - Clear all cache
- `NeeroTtlEtagCache.clearAndResetEncryption()` - Reset encryption
- `NeeroTtlEtagCache.migrateEncryption()` - Migrate encryption mode
- `CachedTtlEtagRepository` - Repository pattern implementation
- `CacheTtlEtagState` - Comprehensive state management
- `EncryptionService` - AES-256 encryption service
- `ReactiveCacheDio` - Core caching service

### Documentation
- Complete README with examples
- API reference documentation
- Advanced usage patterns
- Security best practices
- Troubleshooting guide
- Performance optimization tips
- Testing guidelines

## [Unreleased]

### Planned Features
- Background cache refresh
- Batch cache operations
- Cache compression
- Cache size limits
- Multi-level cache (memory + disk)
- Custom cache strategies
- Cache analytics and metrics
- WebSocket support
- GraphQL support

---

For migration guides and breaking changes, see [MIGRATION.md](MIGRATION.md)