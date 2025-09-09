//
//  MerchantPaymentIDManager.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/09.
//

import Foundation

class MerchantPaymentIDManager {
    static let shared = MerchantPaymentIDManager()
    
    private init() {}
    
    func saveMerchantPaymentID(_ merchantPaymentID: String) {
        // 本番ではUserDefaultsで保存するのはいけません。
        UserDefaults.standard.set(merchantPaymentID, forKey: UserDefaultsKeys.recentMerchantID.rawValue)
        print("MerchantId saved: \(merchantPaymentID)")
    }
    
    
    func fetchMerchantPaymentID() -> String? {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.recentMerchantID.rawValue)
    }
    
    
    func deleteMerchantPaymentID() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.recentMerchantID.rawValue)
    }
}
