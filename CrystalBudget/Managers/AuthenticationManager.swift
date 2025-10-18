import Foundation
import LocalAuthentication
import Security
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isBiometricAvailable = false
    @Published var biometricType: LABiometryType = .none
    @Published var isLocked = false
    
    private let keychain = KeychainManager()
    private let context = LAContext()
    
    init() {
        checkBiometricAvailability()
        checkAuthenticationStatus()
    }
    
    // MARK: - Biometric Authentication
    
    func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAvailable = true
            biometricType = context.biometryType
        } else {
            isBiometricAvailable = false
            biometricType = .none
        }
    }
    
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Использовать пароль"
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Разблокировать CrystalBudget"
            )
            
            if result {
                await MainActor.run {
                    isAuthenticated = true
                    isLocked = false
                }
            }
            
            return result
        } catch {
            print("Biometric authentication failed: \(error)")
            return false
        }
    }
    
    func authenticateWithPasscode() async -> Bool {
        let context = LAContext()
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Разблокировать CrystalBudget"
            )
            
            if result {
                await MainActor.run {
                    isAuthenticated = true
                    isLocked = false
                }
            }
            
            return result
        } catch {
            print("Passcode authentication failed: \(error)")
            return false
        }
    }
    
    // MARK: - App Lock Management
    
    func lockApp() {
        isLocked = true
        isAuthenticated = false
    }
    
    func unlockApp() async -> Bool {
        if isBiometricAvailable {
            return await authenticateWithBiometrics()
        } else {
            return await authenticateWithPasscode()
        }
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() {
        // Check if user has completed onboarding
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            // Check if biometric is enabled
            let biometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
            
            if biometricEnabled && isBiometricAvailable {
                // App should start locked
                isLocked = true
                isAuthenticated = false
            } else {
                // No biometric, user is authenticated
                isAuthenticated = true
                isLocked = false
            }
        } else {
            // First launch, not authenticated
            isAuthenticated = false
            isLocked = false
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Enable biometric by default if available
        if isBiometricAvailable {
            UserDefaults.standard.set(true, forKey: "biometricEnabled")
            isLocked = true
            isAuthenticated = false
        } else {
            UserDefaults.standard.set(false, forKey: "biometricEnabled")
            isAuthenticated = true
            isLocked = false
        }
    }
    
    func enableBiometric() {
        UserDefaults.standard.set(true, forKey: "biometricEnabled")
        checkBiometricAvailability()
    }
    
    func disableBiometric() {
        UserDefaults.standard.set(false, forKey: "biometricEnabled")
        isBiometricAvailable = false
    }
    
    // MARK: - Passkeys Support (Future Implementation)
    
    func setupPasskeys() async -> Bool {
        // Future implementation for WebAuthn/Passkeys
        // This would integrate with the backend for WebAuthn registration
        return false
    }
    
    func authenticateWithPasskeys() async -> Bool {
        // Future implementation for WebAuthn/Passkeys authentication
        return false
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
        // Encrypt data before storing
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
}

// MARK: - Crypto Manager
class CryptoManager {
    static let shared = CryptoManager()
    
    private let key: Data
    
    private init() {
        // Generate or retrieve encryption key
        if let existingKey = KeychainManager().retrieve(key: "encryption_key") {
            self.key = existingKey
        } else {
            // Generate new key
            var keyData = Data(count: 32)
            let result = keyData.withUnsafeMutableBytes { bytes in
                SecRandomCopyBytes(kSecRandomDefault, 32, bytes.bindMemory(to: UInt8.self).baseAddress!)
            }
            
            if result == errSecSuccess {
                self.key = keyData
                _ = KeychainManager().store(key: "encryption_key", data: keyData)
            } else {
                // Fallback key (not secure, but prevents crashes)
                self.key = "fallback_key_32_bytes_long".data(using: .utf8)!
            }
        }
    }
    
    func encrypt(_ data: Data) -> Data? {
        // Simple XOR encryption for demo purposes
        // In production, use proper encryption like AES
        var encrypted = Data()
        let keyBytes = key.withUnsafeBytes { $0.bindMemory(to: UInt8.self) }
        let dataBytes = data.withUnsafeBytes { $0.bindMemory(to: UInt8.self) }
        
        for (index, byte) in dataBytes.enumerated() {
            let keyByte = keyBytes[index % keyBytes.count]
            encrypted.append(byte ^ keyByte)
        }
        
        return encrypted
    }
    
    func decrypt(_ encryptedData: Data) -> Data? {
        // XOR decryption (same as encryption)
        return encrypt(encryptedData)
    }
}
