import Foundation

final class NetworkingService {
    
    func makeRequest(with urlString: String, and bearerToken: String) -> URLRequest {
        guard
            let url = URL(string: urlString)
        else {
            return URLRequest(url: URL(fileURLWithPath: ""))
            
        }
        
        var request = URLRequest(url: url)
        request.setValue("\(bearerToken)", forHTTPHeaderField: "Authorization: Bearer <token>")
        return request
    }
    
    func getTodoItemList(from url: URL?) {
        let request = makeRequest(with: Constants.baseUrl, and: TokenStorage.token)
    }
}
