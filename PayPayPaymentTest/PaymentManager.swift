//
//  PaymentManager.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/09.
//

import Foundation


class PaymentManager {
    static let shared = PaymentManager()
    
    private init() {}
    
    
    func fetchLastPaymentStatus() async -> (merchantID: String, status: String)? {
        
        guard let recentMerchantPaymentID = MerchantPaymentIDManager.shared.fetchMerchantPaymentID() else {
            print("No recent payment to check.")
            return nil
        }
        print("Recent merchant Payment ID: \(recentMerchantPaymentID)")
        
            guard let paymentStatus = try? await BackendAPICaller.shared.fetchPaymentStatus(recentMerchantPaymentID) else {
                print("Can't fetch payment status!")
                return nil
            }
        
            MerchantPaymentIDManager.shared.deleteMerchantPaymentID()
            
            return (recentMerchantPaymentID, paymentStatus)
        
    }
}
