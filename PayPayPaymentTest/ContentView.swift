//
//  ContentView.swift
//  PayPayPaymentTest
//
//  Created by cmStudent on 2025/09/08.
//

import SwiftUI

struct PayloaderResponse: Decodable {
    let data: DetailData
}

struct DetailData: Decodable {
    let deeplink: String
    let merchantPaymentId: String
}

class PayPayPayloader: ObservableObject {
    

    
    func makePayment() async {
        do {
            let paymentURL = try await createPaymentURL()
            
            if await UIApplication.shared.canOpenURL(paymentURL) {
                await UIApplication.shared.open(paymentURL, options: [:], completionHandler: nil)
             }
            
        } catch {
            print("Error making payment: \(error.localizedDescription)")
        }
    }
    
    
    private func createPaymentURL() async throws -> URL {
        
        guard let apiKey = loadAPIKey() else {
            print("Unable to load api key.")
            throw URLError(.unknown)
        }
        
        var request = URLRequest(url: URL(string: "https://24cm0138.main.jp/paypay/create_payload.php")!)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization": apiKey]
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "product_name", value: "Test Product"),
            URLQueryItem(name: "quantity", value: "2"),
            URLQueryItem(name: "price", value: "100"),
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
            
            return url
            
        } catch {
            
            let rawDataString = String(data: data, encoding: .utf8) ?? "(No data)"
            print(rawDataString)
            
            throw URLError(.badServerResponse)
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

struct ContentView: View {
    @StateObject private var payPayPayloader = PayPayPayloader()
    var body: some View {
        VStack {
            Button {
                Task {
                    await payPayPayloader.makePayment()
                }
            } label: {
                Text("Pay")
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
