//
//  BackendAPICaller.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/09.
//

import Foundation


class BackendAPICaller {
    static let shared = BackendAPICaller()
    
    private init() {}
    
    
    func createPaymentURL(amount: String) async throws -> (paypayURL: URL, merchantPaymentID: String) {
        
        guard let apiKey = loadAPIKey() else {
            print("Unable to load api key.")
            throw URLError(.unknown)
        }
        
        var request = URLRequest(url: URL(string: "https://24cm0138.main.jp/paypay/create_payload.php")!)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization": apiKey]
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "method", value: APIMethods.createPaymentURL.rawValue),
            URLQueryItem(name: "product_name", value: "Test Product"),
            URLQueryItem(name: "quantity", value: "1"),
            URLQueryItem(name: "price", value: amount),
            URLQueryItem(name: "redirect_url", value: "PayPayPaymentTest://")
        ]
        
        request.httpBody = components.query?.data(using: .utf8)


        let (data, response) = try await URLSession.shared.data(for: request)
        
                
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let rawDataString = String(data: data, encoding: .utf8) ?? "(No data)"
            print(rawDataString)
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(PayloaderResponse.self, from: data)
            
            guard let url = URL(string: decodedResponse.data.deeplink) else {
                print("Unable to parse URL.")
                throw URLError(.badURL)
            }
            
            return (url, decodedResponse.data.merchantPaymentId)
            
        } catch {
            
            let rawDataString = String(data: data, encoding: .utf8) ?? "(No data)"
            print(rawDataString)
            
            throw URLError(.badServerResponse)
        }
    }
    
    
    func fetchPaymentStatus(_ merchantPaymentID: String) async throws -> String {
        guard let apiKey = loadAPIKey() else {
            print("Unable to load api key.")
            throw URLError(.unknown)
        }
        print("merchantID: \(merchantPaymentID)")
        var request = URLRequest(url: URL(string: "https://24cm0138.main.jp/paypay/create_payload.php")!)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization": apiKey]
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "method", value: APIMethods.checkPaymentStatus.rawValue),
            URLQueryItem(name: "merchantID", value: merchantPaymentID)
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let rawDataString = String(data: data, encoding: .utf8) ?? "(No data)"
        print(rawDataString)

                
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let rawDataString = String(data: data, encoding: .utf8) ?? "(No data)"
            print(rawDataString)
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(PaymentStatusResponse.self, from: data)
            
            return decodedResponse.data.status
            
        } catch {
            print("Decoding error \(error.localizedDescription)")
            return ""
        }
        
    }
    
    
    private func loadAPIKey() -> String? {
        if let url = Bundle.main.url(forResource: "API_KEY", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           
           let key = dict["API_KEY"] as? String {
            return key
        }
        return nil
    }
}
