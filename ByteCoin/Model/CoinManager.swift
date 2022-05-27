//  Sabah Naveed
//  CoinManager.swift
//  ByteCoin
//

import Foundation
protocol CoinManagerDelegate {
    func didUpdateCurrency(_ bitcoinP: Double, _ currencyName: String)
    func didFailWith(error: Error)
}
struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1695AB0E-7EA5-4415-B803-8F026CAFAE0E"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var currencyN = ""
    
    mutating func getCoinPrice (for currency: String) {
        currencyN = currency
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {data, response, error in
                if error != nil {
                    self.delegate?.didFailWith(error: error!)
                    return
                }
                if let safeData = data {
                    let bitcoinPrice = self.parseJSON(safeData)
                    self.delegate?.didUpdateCurrency(bitcoinPrice!, currencyN)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            let lastPrice = decodedData.rate
            print(String(format: "%.2f", lastPrice))
            return lastPrice
            
        } catch {
            print(error)
            return nil
        }
    }
}
