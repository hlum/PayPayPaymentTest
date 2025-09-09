//
//  PayloaderResponse.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/09.
//

import Foundation

struct PayloaderResponse: Decodable {
    let data: DetailData
}

struct DetailData: Decodable {
    let deeplink: String
    let merchantPaymentId: String
}
