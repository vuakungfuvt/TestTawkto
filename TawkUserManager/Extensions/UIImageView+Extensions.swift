//
//  UIImageView+Extensions.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import UIKit

class DownloadImageView: UIImageView {
    var url: String?
    
    func setImage(with url: String, isInverted: Bool = false) {
        if self.url == url {
            return
        }
        image = nil
        self.url = url
        if let data = ImageDataManager.shared.getData(url: url) {
            image = isInverted ? UIImage(data: data)?.inverseImage() : UIImage(data: data)
        } else {
            ImageDataManager.shared.downloadImage(url: url) { [weak self] data in
                if let data = data, url == self?.url  {
                    DispatchQueue.main.async {
                        self?.image = isInverted ? UIImage(data: data)?.inverseImage() : UIImage(data: data)
                    }
                }
            }
        }
    }
}

extension UIImage {
    func inverseImage() -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
    }
}
