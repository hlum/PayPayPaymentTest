//
//  ContentView.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/08.
//

import SwiftUI



class PayPayPayloader: ObservableObject {
    
    func makePayment(amount: String) async {
        do {
            let (paymentURL, merchantPaymentID) = try await BackendAPICaller.shared.createPaymentURL(amount: amount)
            
            if await UIApplication.shared.canOpenURL(paymentURL) {
                // あとで、支払いが成功したかを確認するため保存しとく
                MerchantPaymentIDManager.shared.saveMerchantPaymentID(merchantPaymentID)
                
                await UIApplication.shared.open(paymentURL, options: [:], completionHandler: nil)
             }
            
        } catch {
            print("Error making payment: \(error.localizedDescription)")
        }
    }
    
    
   
}

struct ContentView: View {
    @StateObject private var payPayPayloader = PayPayPayloader()
    @State private var amount:String = "100"
    @Binding var lastPaymentStatus: (merchantID: String, status: String)?
    var body: some View {
        VStack {

            Text("LastPayment merchantID: \(lastPaymentStatus?.merchantID ?? "")")
            Text("LastPayment status: \(lastPaymentStatus?.status ?? "")")
            
            let status = lastPaymentStatus?.status ?? ""
            
            Circle()
                .fill(status == "COMPLETED" ? .green : status == "" ? .gray :.red)
           
            
            TextField("Amount", text: $amount)
                .keyboardType(.numberPad)
                .padding()
            
            Button {
                Task {
                    await payPayPayloader.makePayment(amount: amount)
                }
            } label: {
                Text("Pay")
            }

        }
        .padding()
        .task {
            self.lastPaymentStatus = await PaymentManager.shared.fetchLastPaymentStatus()
        }
    }
}

