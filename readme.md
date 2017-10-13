Save the certificate (as .cer file) of your website in the main bundle. Then use this URLSessionDelegate method:

```swift
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

```