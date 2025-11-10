# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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