import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' hide Digest;

// Handles AES-GCM encryption and decryption for project password verification.
class PasswordCrypto {
  static const String _masterSecret = 'project_admin_master_secret_2026_change_me';
  static const int _tagLengthBits = 128;

  static final Uint8List _keyBytes = _buildKey();

  // Derives a 256-bit AES key from the master secret using SHA-256.
  static Uint8List _buildKey() {
    Digest digest = sha256.convert(utf8.encode(_masterSecret));
    return Uint8List.fromList(digest.bytes);
  }

  // Decrypts AES-GCM encrypted text using the provided IV.
  static String? _decryptWithAesGcm({
    required String encryptedText,
    required String ivText,
  }) {
    try {
      // Decode the IV and encrypted bytes from base64.
      Uint8List ivBytes = base64Decode(ivText);
      Uint8List encryptedBytes = base64Decode(encryptedText);

      // Initialize the AES-GCM cipher for decryption.
      GCMBlockCipher cipher = GCMBlockCipher(AESEngine());
      cipher.init(
        false,
        AEADParameters(
          KeyParameter(_keyBytes),
          _tagLengthBits,
          ivBytes,
          Uint8List(0),
        ),
      );

      // Process and decode the decrypted bytes.
      Uint8List plainBytes = cipher.process(encryptedBytes);
      return utf8.decode(plainBytes);
    } catch (_) {
      return null;
    }
  }

  // Encrypts plain text using AES-GCM with the provided IV.
  static String? _encryptWithAesGcm({
    required String plainText,
    required String ivText,
  }) {
    try {
      // Decode the IV and encode the plain text.
      Uint8List ivBytes = base64Decode(ivText);
      Uint8List plainBytes = Uint8List.fromList(utf8.encode(plainText));

      // Initialize the AES-GCM cipher for encryption.
      GCMBlockCipher cipher = GCMBlockCipher(AESEngine());
      cipher.init(
        true,
        AEADParameters(
          KeyParameter(_keyBytes),
          _tagLengthBits,
          ivBytes,
          Uint8List(0),
        ),
      );

      // Process and encode the encrypted bytes.
      Uint8List encryptedBytes = cipher.process(plainBytes);
      return base64Encode(encryptedBytes);
    } catch (_) {
      return null;
    }
  }

  // Verifies a plain text password against an encrypted stored value.
  static bool matchesStoredValue({
    required String plainText,
    required String storedValue,
  }) {
    // Check that the stored value uses the expected encryption format.
    String value = storedValue.trim();
    if (!value.startsWith('enc:')) {
      return false;
    }

    // Split into parts: "enc", IV, and cipher text.
    List<String> parts = value.split(':');
    if (parts.length != 3) {
      return false;
    }

    String ivText = parts[1].trim();
    String cipherText = parts[2].trim();
    if (ivText.isEmpty || cipherText.isEmpty) {
      return false;
    }

    // First try: encrypt the input with the same IV and compare cipher text.
    String? encryptedInput = _encryptWithAesGcm(
      plainText: plainText,
      ivText: ivText,
    );
    if ((encryptedInput ?? '').trim() == cipherText) {
      return true;
    }

    // Second try: decrypt the stored cipher text and compare with input.
    String? decrypted = _decryptWithAesGcm(
      encryptedText: cipherText,
      ivText: ivText,
    );
    return (decrypted ?? '').trim() == plainText.trim();
  }
}

