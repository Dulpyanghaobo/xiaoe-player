//
//  URL+Extension.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#else
import MobileCoreServices
#endif
extension URL {
        func mimeType() -> String {
            if let type = UTType(filenameExtension: self.pathExtension) {
                return type.preferredMIMEType ?? "application/octet-stream"
            }
            return "application/octet-stream"
        }
    
    var getFileModificationDate: Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
}
