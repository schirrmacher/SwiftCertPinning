//
//  ViewController.swift
//  CertPinning
//
//  Created by Marvin Schirrmacher on 12.10.17.
//  Copyright © 2017 Marvin Schirrmacher. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, URLSessionDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        guard let url = URL(string: "https://shop.rewe.de/") else { return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let data = data, let contents = String(data: data, encoding: String.Encoding.utf8) {
                print(contents)
            }
            
        }
        
        task.resume()
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
             
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            SecTrustEvaluate(serverTrust, nil) == errSecSuccess,
            let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                
                reject(with: completionHandler)
                return
        }
        
        let serverCertData = SecCertificateCopyData(serverCert) as Data
        
        guard
            let localCertPath = Bundle.main.path(forResource: "shop.rewe.de", ofType: "cer"),
            let localCertData = NSData(contentsOfFile: localCertPath) as Data?,
        
            localCertData == serverCertData else {
                
                reject(with: completionHandler)
                return
        }
        
        accept(with: serverTrust, completionHandler)
        
    }
    
    func reject(with completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    func accept(with serverTrust: SecTrust, _ completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
}
