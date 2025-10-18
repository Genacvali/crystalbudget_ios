import Foundation
import Security
import CryptoKit
import SwiftUI

class CryptoManager {
    static let shared = CryptoManager()
    
    private let key: SymmetricKey
    
    private init() {
        // Generate or retrieve encryption key
        if let existingKeyData = KeychainManager().retrieve(key: "encryption_key") {
            self.key = SymmetricKey(data: existingKeyData)
        } else {
            // Generate new key
            self.key = SymmetricKey(size: .bits256)
            
            // Store key in keychain
            let keyData = key.withUnsafeBytes { Data($0) }
            _ = KeychainManager().store(key: "encryption_key", data: keyData)
        }
    }
    
    func encrypt(_ data: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    func decrypt(_ encryptedData: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
    
    func encrypt(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        guard let encryptedData = encrypt(data) else { return nil }
        return encryptedData.base64EncodedString()
    }
    
    func decrypt(_ encryptedString: String) -> String? {
        guard let encryptedData = Data(base64Encoded: encryptedString) else { return nil }
        guard let decryptedData = decrypt(encryptedData) else { return nil }
        return String(data: decryptedData, encoding: .utf8)
    }
}

// MARK: - Keychain Manager
class KeychainManager {
    private let service = "net.crystalbudget.app"
    
    func store(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieve(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Sensitive Data Encryption
    
    func storeEncrypted(key: String, data: Data) -> Bool {
        guard let encryptedData = CryptoManager.shared.encrypt(data) else {
            return false
        }
        
        return store(key: key, data: encryptedData)
    }
    
    func retrieveDecrypted(key: String) -> Data? {
        guard let encryptedData = retrieve(key: key) else {
            return nil
        }
        
        return CryptoManager.shared.decrypt(encryptedData)
    }
    
    func storeEncryptedString(key: String, string: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return storeEncrypted(key: key, data: data)
    }
    
    func retrieveDecryptedString(key: String) -> String? {
        guard let data = retrieveDecrypted(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Data Protection
class DataProtectionManager {
    static let shared = DataProtectionManager()
    
    private init() {}
    
    func protectSensitiveData(_ data: Data) -> Data? {
        return CryptoManager.shared.encrypt(data)
    }
    
    func unprotectSensitiveData(_ encryptedData: Data) -> Data? {
        return CryptoManager.shared.decrypt(encryptedData)
    }
    
    func protectString(_ string: String) -> String? {
        return CryptoManager.shared.encrypt(string)
    }
    
    func unprotectString(_ encryptedString: String) -> String? {
        return CryptoManager.shared.decrypt(encryptedString)
    }
}

// MARK: - Secure Storage
class SecureStorage {
    private let keychain = KeychainManager()
    
    func store<T: Codable>(_ object: T, forKey key: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            return keychain.storeEncrypted(key: key, data: data)
        } catch {
            print("Error encoding object: \(error)")
            return false
        }
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = keychain.retrieveDecrypted(key: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Error decoding object: \(error)")
            return nil
        }
    }
    
    func delete(forKey key: String) -> Bool {
        return keychain.delete(key: key)
    }
}

// MARK: - Biometric Authentication Helper
class BiometricHelper {
    static func isAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    static func biometricType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return context.biometryType
        }
        
        return .none
    }
    
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Использовать пароль"
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return result
        } catch {
            print("Biometric authentication failed: \(error)")
            return false
        }
    }
}

// MARK: - App Lock Manager
class AppLockManager: ObservableObject {
    @Published var isLocked = false
    @Published var lockReason: LockReason = .appBackgrounded
    
    enum LockReason {
        case appBackgrounded
        case manual
        case timeout
    }
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var lockTimer: Timer?
    
    func lockApp(reason: LockReason = .appBackgrounded) {
        isLocked = true
        lockReason = reason
        
        // Cancel any existing timer
        lockTimer?.invalidate()
        
        // Start background task to keep app alive briefly
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "AppLock") {
            self.endBackgroundTask()
        }
        
        // End background task after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.endBackgroundTask()
        }
    }
    
    func unlockApp() async -> Bool {
        let success = await BiometricHelper.authenticate(reason: "Разблокировать CrystalBudget")
        
        if success {
            await MainActor.run {
                isLocked = false
            }
        }
        
        return success
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func startLockTimer(timeout: TimeInterval = 300) { // 5 minutes default
        lockTimer?.invalidate()
        
        lockTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
            self.lockApp(reason: .timeout)
        }
    }
    
    func stopLockTimer() {
        lockTimer?.invalidate()
        lockTimer = nil
    }
}
