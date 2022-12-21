//
//  JoKeychain.swift
//  SMS-13033
//
//  Created by Ioanna Z. on 17/11/20.
//

import UIKit
import Security

class KeychainService {

    static func updatePassword(_ password: String, serviceKey: String) {
        guard let dataFromString = password.data(using: .utf8) else { return }

        let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                           kSecAttrService: serviceKey,
                                           kSecValueData: dataFromString]
        
        removePassword(serviceKey: serviceKey)
    
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        checkError(status)
    }
    
    static func removePassword(serviceKey: String) {
        let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                               kSecAttrService: serviceKey,
                                               kSecReturnData: kCFBooleanTrue as Any]
        let status = SecItemDelete(keychainQuery as CFDictionary)
        checkError(status)
    }
    
    
    static func loadPassword(serviceKey: String) -> String? {
        var dataTypeRef: CFTypeRef?
        let keychainQuery: [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                             kSecAttrService : serviceKey,
                                             kSecReturnData: kCFBooleanTrue as Any,
                                             kSecMatchLimit: kSecMatchLimitOne]
        
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            guard let retrievedData = dataTypeRef as? Data else { return nil }
            return String(data: retrievedData, encoding: .utf8)
        } else {
            checkError(status)
            return nil
        }
    }
    
    static func checkError(_ status: OSStatus) {
        if status != errSecSuccess {
            let err = SecCopyErrorMessageString(status, nil)
            print("Operation failed. Error: \(String(describing: err))")
        } else {
            print("All good, no error found (errSecSuccess = \(status))")
        }
    }
    
    // works but is missing a checkError
    static func flush()  {
        let secItemClasses =  [kSecClassGenericPassword]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }

}

