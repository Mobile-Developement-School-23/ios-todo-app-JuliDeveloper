import Foundation

private enum NetworkError: Error {
    case noData
    case codeError
}

extension URLSession {
//    func fetchData(
//        for urlRequest: URLRequest,
//        completion: @escaping @Sendable (Result<(Data, URLResponse), Error>) -> Void
//    ) -> URLSessionTask {
//        let task = dataTask(with: urlRequest) { (data, response, error) in
//            if let response = response as? HTTPURLResponse {
//                if response.statusCode >= 200 && response.statusCode < 300 {
//                    if let data = data {
//                        completion(.success((data, response)))
//                    } else {
//                        completion(.failure(NetworkError.noData))
//                    }
//                } else if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.failure(NetworkError.codeError))
//                }
//            }
//        }
//        task.resume()
//
//        return task
//    }
    
        func fetchData(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
            return try await withCheckedThrowingContinuation { continuation in
                let task = self.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: NetworkError.noData)
                }
            }
            task.resume()
        }
    }
}
