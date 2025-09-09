//
//  PayPayPaymentTestApp.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/08.
//

import SwiftUI

@main
struct PayPayPaymentTestApp: App {
    
    @State private var lastPaymentStatus: (merchantID: String, status: String)? = nil
    
    var body: some Scene {
        WindowGroup {
            ContentView(lastPaymentStatus: $lastPaymentStatus)
                .onOpenURL { _ in
                    Task {
                        self.lastPaymentStatus = await PaymentManager.shared.fetchLastPaymentStatus()
                    }
                }
        }
    }
}
