//
//  URLSessionPinningDelegate.swift
//  BoostAI
//
//  Created by Bjornar.Tollaksen on 04/08/2022.
//  Copyright © 2022 boost.ai. All rights reserved.
//

import Foundation
import CommonCrypto

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    private let pinnedCertificateHashes = [
        "LlrVljiqk5ZEfsC1ItTymp603detugMezt9AqyPa52g=", // Amazon Root CA 1
        "yg/aNKQno55MIpzRK73vlrfViZVLtygkdUswD4TLor0=", // Amazon Root CA 2
        "Sog2HYnR5Obf0YaYfPgO3ijCbbB69xeSOkZa8NeT9Nc=", // Amazon Root CA 3
        "M2JnfiPkZTh9dazqcmEcucCmAk9QFLkF3S5UMfAnSFY=", // Amazon Root CA 4
        "h6QLZxZtXyDd/wmZh+HepUC71JOODXmiZ24xwZydOE8=" // Starfield Services Root Certificate Authority - G2
    ]
 
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return;
        }
        
        /*
        // Calculate hashes
        let certificates = ["AmazonRootCA1", "AmazonRootCA2", "AmazonRootCA3", "AmazonRootCA4", "SFSRootCAG2"]
        let hashes = certificates.map { resource in
            return sha256(data: try! Data(contentsOf: Bundle(for: URLSessionPinningDelegate.self).url(forResource: resource, withExtension: "cer")!))
        }
         */

        // Set SSL policies for domain name check
        let policies = NSMutableArray();
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)));
        SecTrustSetPolicies(serverTrust, policies);

        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil);

        if (isServerTrusted) {
            // Get the root CA cerficate (last in chain)
            if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, SecTrustGetCertificateCount(serverTrust) - 1) {
                
                let serverCertificateData: NSData = SecCertificateCopyData(serverCertificate)
                let serverCertificatHash = sha256(data: serverCertificateData as Data)
                
                if (pinnedCertificateHashes.contains(serverCertificatHash)) {
                    // Valid certficate
                    completionHandler(.useCredential, URLCredential(trust:serverTrust))
                    return
                }
            }
        }

        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
    private let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ];
    
    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
 
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }
 
        return Data(hash).base64EncodedString()
    }
}
