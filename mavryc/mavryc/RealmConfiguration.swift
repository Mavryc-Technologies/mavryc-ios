//
//  RealmConfiguration.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Security

// This class provides a realm configuration that handles both enryption and migration
class RealmConfiguration {
    
    // Ensures the default realm configuration is encrypted
    // ref: https://realm.io/docs/swift/latest/#encryption
    // ref: https://github.com/realm/realm-cocoa/blob/master/examples/ios/swift-2.2/Encryption/ViewController.swift
    class func setDefaultConfigurationEncrypted() {
        
        let configuration = Realm.Configuration(encryptionKey: getKey() as Data,
            
           // Update scheme version per database change; migrationBlock won't be called unless this is updated
           schemaVersion: 1,
           
           migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            
            if (oldSchemaVersion < 1) {
                // support any new necessary migration changes per https://realm.io/docs/swift/latest/#migrations
            }
            
            //                migration.enumerate(SomeClass.className()) { oldObject, newObject in
            //                    // EXAMPLES
            //                    // Add the `abc` property only to Realms with a schema version of 0
            //                    if oldSchemaVersion < 1 {
            //                        //newObject!["yourNewObjectName"] = ""
            //                    }
            //
            //                    // Add the `xyz` property to Realms with a schema version of 0 or 1
            //                    if oldSchemaVersion < 2 {
            //                        //newObject!["testingMigrationString"] = ""
            //                    }
            //
            //                    if oldSchemaVersion < 3 {
            //                        //newObject!["testingMigrationString"] = ""
            //                        newObject?["optinID"] = nil
            //                    }
            //                }
        })
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = configuration
        let _ = try! Realm()
    }
    
    private class func getKey() -> NSData {
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "com.mavryc.primary-realm-encryption-key"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // First check in the keychain for an existing key
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]
        
        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }
        
        // No pre-existing key from this application, so generate a new one
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")
        
        // Store the key in the keychain
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData
    }
}
