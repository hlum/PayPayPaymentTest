//
//  PaymentStatusResponse.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/09.
//


struct PaymentStatusResponse: Decodable {
    let data: PaymentStatusResponseData
}

struct PaymentStatusResponseData: Decodable {
    let status: String
}
