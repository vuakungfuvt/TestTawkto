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
    
    func getImage(url: String, completion: ((Data?) -> Void)? = nil) {
        if let data = ImageDataManager.shared.getData(url: url) {
            completion?(data)
        } else if downloadUrl.contains(url) {
            
        } else {
            downloadImage(url: url) { [weak self] data in
                if let data = data {
                    self?.coreDataService.save(entityName: "ImageData", dataDict: ["url": url, "data": data])
                }
                completion?(data)
            }
        }
    }
    
    private func downloadImage(url: String, completion: ((Data?) -> Void)? = nil) {
        downloadUrl.insert(url)
        apiService.downloadImage(url: url) { result in
            switch result {
            case .success(let data):
                completion?(data)
            case .failure(_):
                completion?(nil)
            }
        }
    }
    
    private func downloadMultiImage(urls: [String], completion: (([String: Data]) -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        var dictData: [String: Data] = [:]
        for url in urls {
            dispatchGroup.enter()
            downloadImage(url: url) { data in
                if let data = data {
                    dictData[url] = data
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion?(dictData)
        }
    }
    
    func prefetchImage(urls: [String]) {
        downloadMultiImage(urls: urls) { [weak self] dictData in
            for (url, data) in dictData {
                self?.coreDataService.save(entityName: "ImageData", dataDict: ["url": url, "data": data])
            }
        }
    }
}
