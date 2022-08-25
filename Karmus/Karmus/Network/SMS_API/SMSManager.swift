//
//  SMSManager.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

final class SMSManager {
    
    private static let defaultSession = URLSession.shared
    private static var dataTask: URLSessionDataTask?
    
    static func sendSMS(phone: String, message: String, _ completion: @escaping (SMSResult) -> Void ) {
        
        guard phone ~= "^\\+375([\\d]{0,9})$" else {
            print("\n<SMSManager\\sendSMS> ERROR: wrong phone - \(phone)\n")
            completion(.error)
            return
        }
        
        guard message.count <= 100 else {
            print("\n<SMSManager\\sendSMS> ERROR: message is too long\n")
            completion(.error)
            return
        }
        
        guard var urlComponents = URLComponents(string: SMSAPIConstants.baseURL + SMSAPIConstants.comandSend) else {
            print("\n<SMSManager\\sendSMS> ERROR: wrong URL - \(SMSAPIConstants.baseURL + SMSAPIConstants.comandSend)\n")
            completion(.error)
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: SMSAPIConstants.token, value: SMSAPIConstants.tokenValue),
            URLQueryItem(name: SMSAPIConstants.message, value: message),
            URLQueryItem(name: SMSAPIConstants.phone, value: String(phone.dropFirst()))
        ]
        
        guard let url = urlComponents.url else {
            print("\n<SMSManager\\sendSMS> ERROR: URL with this components isn't exist\n")
            completion(.error)
            return
        }
        
        defaultSession.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else{
                print("\n<SMSManager\\sendSMS> ERROR: \(error!.localizedDescription)\n")
                completion(.error)
                return
            }
            
            if response != nil {
                // print("\n<SMSManager\\sendSMS> RESPONSE: \(response!.debugDescription)\n")
            }
            
            if data != nil{
                completion(.sent)
            }

        }.resume()
        
    }
    
    static func isBalanceEnough(_ completion: @escaping (Any?, Bool?) -> Void) {
        
        guard var urlComponents = URLComponents(string: SMSAPIConstants.baseURL + SMSAPIConstants.conandBalace) else {
            print("\n<SMSManager\\isBalanceEnough> ERROR: wrong URL - \(SMSAPIConstants.baseURL + SMSAPIConstants.conandBalace)\n")
            completion(Error.self, nil)
            return
        }
        
        urlComponents.queryItems = [ URLQueryItem(name: SMSAPIConstants.token, value: SMSAPIConstants.tokenValue) ]
        
        guard let url = urlComponents.url else {
            print("\n<SMSManager\\isBalanceEnough> ERROR: URL with this components isn't exist\n")
            completion(Error.self, nil)
            return
        }
        
        defaultSession.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else{
                print("\n<SMSManager\\isBalanceEnough> ERROR: \(error!.localizedDescription)\n")
                completion(Error.self, nil)
                return
            }
            
            if response != nil {
                // print("\n<SMSManager\\isBalanceEnough> RESPONSE: \(response!.debugDescription)\n")
            }
            
            if let data = data {
                guard let balanceInfo = try? JSONDecoder().decode(BalanceModel.self, from: data) else {
                    print("\n<SMSManager\\isBalanceEnough> DATA DECODE ERROR: check BalanceModel.swift\n")
                    return
                }
                let balance = Double(balanceInfo.result.first?.balance ?? "0.0") ?? 0.0
                let isBalanceEnough = balance >= 0.12
                completion(nil, isBalanceEnough)
            }

        }.resume()
        
    }
    
}
