//
//  Data+extension.swift
//  AntPlayerH
//
//  Created by i564407 on 7/17/24.
//

import Foundation
import CommonCrypto

extension Data {
    func encryptAES256(key: Data, iv: Data, options: Int = kCCModeOptionCTR_BE) -> Data? {
        let paddedData = zeroPad(data: self)

        return aesCrypt(operation: kCCEncrypt,
                        algorithm: kCCAlgorithmAES,
                        options: 0,
                        key: key,
                        initializationVector: iv,
                        dataIn: paddedData)
    }
    
    func zeroPad(data: Data) -> Data {
        let blockSize = 16
        let padding = blockSize - (data.count % blockSize)
        return data + Data(repeating: 0, count: padding)
    }
    
    private func aesCrypt(operation: Int, algorithm: Int, options: Int, key: Data, initializationVector: Data, dataIn: Data) -> Data? {
        return key.withUnsafeBytes { keyUnsafeRawBufferPointer in
            return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
                return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                    let dataOutSize: Int = dataIn.count + kCCBlockSizeAES128
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize, alignment: 1)
                    defer { dataOut.deallocate() }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(CCOperation(operation),
                                         CCAlgorithm(algorithm),
                                         CCOptions(options),
                                         keyUnsafeRawBufferPointer.baseAddress, key.count,
                                         ivUnsafeRawBufferPointer.baseAddress,
                                         dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                                         dataOut, dataOutSize,
                                         &dataOutMoved)
                    guard status == kCCSuccess else { return nil }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }
}
