//
//  APILayer.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol RequestType {
    var path: String { get set }
    var method: HTTPMethod { get set }
    var headerParams: [String: Any]? { get set }
    var bodyParams: [String: Any]? { get set }
    
    func makeUrlRequest(_ domain: String) -> URLRequest?
}

extension RequestType {
    func makeUrlRequest(_ domain: String) -> URLRequest? {
        func makeUrl(_ urlString: String, params: [String: Any]?) -> URL? {
            if params?.isEmpty ?? true {
                return URL(string: urlString)
            }
            var components = URLComponents(string: urlString)
            components?.queryItems = params?.map { element in URLQueryItem(name: element.key, value: "\(element.value)") }
            if let newUrl = components?.url?.absoluteString {
                return URL(string: newUrl)
            }
            return URL(string: urlString)
        }
        let urlString = "\(domain)\(path)"
        var urlRequest: URLRequest
        if method == .get {
            urlRequest = URLRequest(url: makeUrl(urlString, params: bodyParams)!)
        } else {
            urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpBody = bodyParams?.percentEncoded()
        }
        urlRequest.httpMethod = method.rawValue
        for header in headerParams ?? [:] {
            urlRequest.setValue("\(header.value)", forHTTPHeaderField: header.key)
        }
        return urlRequest
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
