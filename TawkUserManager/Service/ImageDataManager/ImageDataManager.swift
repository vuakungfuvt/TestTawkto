//
//  ImageDataManager.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Foundation

class ImageDataManager {
    static let shared: ImageDataManager = {
        return ImageDataManager(coreDataService: CoreDataService.shared, apiService: APIService.shared)
    }()
    private let coreDataService: CoreDataService
    private let apiService: APIService
    private var downloadUrl: Set<String> = Set()
    
    private init(coreDataService: CoreDataService, apiService: APIService) {
        self.coreDataService = coreDataService
        self.apiService = apiService
    }
    
    func fetchData() {
        guard let datas: [ImageData] = coreDataService.fetch(entityName: "ImageData") else {
            return
        }
        for data in datas {
            if let url = data.url {
                downloadUrl.insert(url)
            }
        }
    }
    
    func getData(url: String) -> Data? {
        let predicate = NSPredicate(format: "url LIKE %@", url)
        let data = coreDataService.fetch(entityName: "ImageData", predicate: predicate, fetchLimit: 1)
        return (data?.first as? ImageData)?.data
    }
    
    func downloadImage(url: String, completion: ((Data?) -> Void)? = nil) {
        downloadUrl.insert(url)
        apiService.downloadImage(url: url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.coreDataService.save(entityName: "ImageData", dataDict: ["url": url, "data": data])
                completion?(data)
            case .failure(_):
                completion?(nil)
            }
        }
    }
    
    func prefetchImage(urls: [String]) {
        for url in urls {
            if downloadUrl.contains(url) {
                continue
            }
            downloadImage(url: url, completion: nil)
        }
    }
}
