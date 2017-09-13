//
//  BillingInfo.swift
//  mavryc
//
//  Created by Todd Hopkinson on 9/12/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

struct Billing {
    
    private static let creditCardNumberKey = "creditCardNumberKey"
    private static let expirationDateKey = "expirationDateKey"
    private static let ccvKey = "ccvKey"
    private static let cardholderNameKey = "cardholderNameKey"
    
    let creditCardNumber: String
    let expirationDate: String
    let ccv: String
    let cardholderName: String
    
    static func storedBillingInfo() -> Billing? {
        
        if let ccNumber: String = UserDefaults.standard.string(forKey: creditCardNumberKey),
            let expiration: String = UserDefaults.standard.string(forKey: expirationDateKey),
            let ccv: String = UserDefaults.standard.string(forKey: ccvKey),
            let ccholderName: String = UserDefaults.standard.string(forKey: cardholderNameKey) {

            return Billing(creditCardNumber: ccNumber, expirationDate: expiration, ccv: ccv, cardholderName: ccholderName)
        }
        
        return nil
    }
    
    func save() {
        UserDefaults.standard.set(self.creditCardNumber, forKey: Billing.creditCardNumberKey)
        UserDefaults.standard.set(self.expirationDate, forKey: Billing.expirationDateKey)
        UserDefaults.standard.set(self.ccv, forKey: Billing.ccvKey)
        UserDefaults.standard.set(self.cardholderName, forKey: Billing.cardholderNameKey)

    }
}
