//
//  CodeGenerate.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

class Code {
    
    static var shared = Code()
    
    var randomCode: String {
       let charactersForCode = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
       var code = ""
       for _ in 1...6{
           code += String(charactersForCode.randomElement() ?? "0")
       }
       return code
    }
    
    func messageWithCode(name: String) -> (messageBody: String, code: String){
        ("Karmus\n\nЗдравствуйте, \(name).\nВаш код активации: ", self.randomCode)
    }
    
}

