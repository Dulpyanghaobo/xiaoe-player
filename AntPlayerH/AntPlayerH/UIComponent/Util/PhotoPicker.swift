//
//  PhotoPicker.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//
import PhotosUI

class PhotoPicker {
    
    typealias PhotoPickerCompletion = (([UIImage]) -> Void)
    
    static func presentPhotoPicker(from viewController: UIViewController, selectionLimit: Int = 1, completion: @escaping PhotoPickerCompletion) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = PhotoPickerDelegate.shared
        PhotoPickerDelegate.shared.completion = completion
        
        viewController.present(picker, animated: true)
    }
}

class PhotoPickerDelegate: NSObject, PHPickerViewControllerDelegate {
    
    static let shared = PhotoPickerDelegate()
    var completion: PhotoPicker.PhotoPickerCompletion?
    
    private override init() {}
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []
        
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                defer { dispatchGroup.leave() }
                if let image = object as? UIImage {
                    images.append(image)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.completion?(images)
        }
    }
}
