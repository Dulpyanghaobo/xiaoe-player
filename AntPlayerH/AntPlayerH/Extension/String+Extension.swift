//
//  String+Extension.swift
//  AntPlayerH
//
//  Created by i564407 on 7/17/24.
//

import Foundation
import CommonCrypto
import CryptoKit

extension String {
    func aesEncrypt(key: String, iv: String) -> String? {
        guard let data = self.data(using: .utf8),
              let key = key.data(using: .utf8),
              let iv = iv.data(using: .utf8),
              let encrypt = data.encryptAES256(key: key, iv: iv) else { return nil }
        let base64Data = encrypt.base64EncodedData()
        return String(data: base64Data, encoding: .utf8)
    }
    func md5() -> String {
        guard let data = data(using: .utf8) else {
            return self
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    var MD5: String {
            let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
            return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
