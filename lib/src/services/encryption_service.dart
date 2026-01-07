import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for handling AES-256 encryption of cached data
///
/// This singleton service manages encryption keys securely using
/// Flutter Secure Storage and provides methods for encrypting and
/// decrypting cached data with AES-256 in CBC mode.
class EncryptionService {
  static EncryptionService? _instance;
  encrypt.Key? _key;
  encrypt.Encrypter? _encrypter;
  final _secureStorage = const FlutterSecureStorage();

  static const String _keyStorageKey = 'ttl_etag_cache_encryption_key';
  bool _isInitialized = false;

  EncryptionService._();

  /// Get the singleton instance
  factory EncryptionService() => _instance ??= EncryptionService._();

  /// Whether the encryption service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the encryption service
  ///
  /// This loads an existing encryption key from secure storage or generates
  /// a new one if none exists. Must be called before any encryption operations.
  ///
  /// Throws [Exception] if initialization fails
  Future<void> init() async {
    if (_isInitialized) return;

    await _loadOrGenerateKey();
    _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
    _isInitialized = true;
  }

  /// Load existing key or generate a new 256-bit key
  Future<void> _loadOrGenerateKey() async {
    final existingKey = await _secureStorage.read(key: _keyStorageKey);

    if (existingKey != null) {
      _key = encrypt.Key.fromBase64(existingKey);
    } else {
      // Generate new 256-bit (32 byte) key
      _key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: _keyStorageKey,
        value: _key!.base64,
      );
    }
  }

  /// Encrypt data with a randomly generated IV
  ///
  /// [plainText] - The plain text data to encrypt
  ///
  /// Returns [EncryptedData] containing the encrypted text and IV
  ///
  /// Throws [Exception] if encryption service is not initialized
  ///
  /// Example:
  /// ```dart
  /// final encrypted = encryptionService.encryptData('{"name": "John"}');
  /// print(encrypted.encryptedText); // Base64 encrypted data
  /// print(encrypted.iv); // Base64 IV
  /// ```
  EncryptedData encryptData(String plainText) {
    if (!_isInitialized) {
      throw Exception('EncryptionService not initialized. Call init() first.');
    }

    // Generate random 128-bit IV for each encryption
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter!.encrypt(plainText, iv: iv);

    return EncryptedData(
      encryptedText: encrypted.base64,
      iv: iv.base64,
    );
  }

  /// Decrypt data using the provided IV
  ///
  /// [encryptedText] - Base64 encoded encrypted data
  /// [ivString] - Base64 encoded initialization vector
  ///
  /// Returns the decrypted plain text
  ///
  /// Throws [Exception] if encryption service is not initialized
  /// Throws [FormatException] if the encrypted data or IV is invalid
  ///
  /// Example:
  /// ```dart
  /// final decrypted = encryptionService.decryptData(
  ///   encrypted.encryptedText,
  ///   encrypted.iv,
  /// );
  /// print(decrypted); // {"name": "John"}
  /// ```
  String decryptData(String encryptedText, String ivString) {
    if (!_isInitialized) {
      throw Exception('EncryptionService not initialized. Call init() first.');
    }

    final iv = encrypt.IV.fromBase64(ivString);
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);

    return _encrypter!.decrypt(encrypted, iv: iv);
  }

  /// Reset the encryption key
  ///
  /// This generates a new random key and stores it securely.
  /// **Warning:** This will invalidate all existing encrypted cache data.
  ///
  /// Use this method when:
  /// - Security requires a key rotation
  /// - User logs out and new user logs in
  /// - Recovering from a compromised key
  ///
  /// Example:
  /// ```dart
  /// await encryptionService.resetKey();
  /// // All previously encrypted data is now unreadable
  /// ```
  Future<void> resetKey() async {
    _key = encrypt.Key.fromSecureRandom(32);
    await _secureStorage.write(
      key: _keyStorageKey,
      value: _key!.base64,
    );
    _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
  }

  /// Delete the encryption key from secure storage
  ///
  /// This completely removes the encryption key. Use this on:
  /// - App uninstall/reset
  /// - User account deletion
  /// - Security incident requiring complete cleanup
  ///
  /// After calling this, you must call [init()] again before using encryption.
  ///
  /// Example:
  /// ```dart
  /// await encryptionService.deleteKey();
  /// // Encryption service is now uninitialized
  /// ```
  Future<void> deleteKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    _isInitialized = false;
    _key = null;
    _encrypter = null;
  }

  /// Initialize encryption for a specific user
  ///
  /// This allows different encryption keys per user, useful for multi-user apps.
  ///
  /// [userId] - Unique identifier for the user
  ///
  /// Example:
  /// ```dart
  /// await encryptionService.initForUser('user123');
  /// // Cache is now encrypted with user123's key
  /// ```
  Future<void> initForUser(String userId) async {
    final userKeyKey = '${_keyStorageKey}_$userId';

    final existingKey = await _secureStorage.read(key: userKeyKey);

    if (existingKey != null) {
      _key = encrypt.Key.fromBase64(existingKey);
    } else {
      _key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: userKeyKey,
        value: _key!.base64,
      );
    }

    _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
    _isInitialized = true;
  }

  /// Delete a specific user's encryption key
  ///
  /// [userId] - The user ID whose key should be deleted
  ///
  /// Example:
  /// ```dart
  /// await encryptionService.deleteUserKey('user123');
  /// ```
  Future<void> deleteUserKey(String userId) async {
    await _secureStorage.delete(key: '${_keyStorageKey}_$userId');
  }
}

/// Container for encrypted data and its initialization vector
class EncryptedData {
  /// Base64 encoded encrypted text
  final String encryptedText;

  /// Base64 encoded initialization vector
  final String iv;

  const EncryptedData({
    required this.encryptedText,
    required this.iv,
  });

  @override
  String toString() => 'EncryptedData(length: ${encryptedText.length})';
}
