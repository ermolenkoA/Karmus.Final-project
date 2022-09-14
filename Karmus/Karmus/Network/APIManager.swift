//
//  APIManager.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import Foundation
import UIKit

class APIManager {

    static let shared = APIManager()
    
}
    func getImage(picName: String, completion: @escaping (UIImage) -> Void) {
        let storage = Storage.storage()
        let reference = storage.reference()
        let pathRef = reference.child("pictures")
        
        var image: UIImage = UIImage(named: "tmb_215871_399815")!
        
        let fileRef = pathRef.child(picName + ".jpeg")
        fileRef.getData(maxSize: 1024*1024, completion: { data, error in
            guard error == nil else { completion(image); return}
            image = UIImage(data: data!)!
            completion(image)
            })
        }
    
