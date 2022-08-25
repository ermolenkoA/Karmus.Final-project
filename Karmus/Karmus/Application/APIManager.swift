//
//  APIManager.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import Foundation
import UIKit

class APIManager {

    static let shared = APIManager()

    private func configureFB() -> Firestore {
        var datebase: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        datebase = Firestore.firestore()
        return datebase
    }
    
    func getPost(collection: String, docName: String, completion: @escaping (Document?) -> Void) {
        let datebase = configureFB()
        datebase.collection(collection).document(docName).getDocument(completion: { (document, error) in
            guard error == nil else { completion(nil); return }
            let doc = Document(field1: document?.get("field1") as! String, field2: document?.get("field2") as! String)
            completion(doc)
        })
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
    }

