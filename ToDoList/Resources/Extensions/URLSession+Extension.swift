import Foundation

private enum NetworkError: Error {
    case noData
    case codeError
}

extension URLSession {
    func fetchData(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                task = self.dataTask(with: urlRequest) { (data, response, error) in
                    if let response = response as? HTTPURLResponse, let data = data {
                        if (200...299).contains(response.statusCode) {
                            continuation.resume(returning: (data, response))
                        } else if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: NetworkError.codeError)
                        }
                    } else {
                        continuation.resume(throwing: NetworkError.noData)
                    }
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
    }
}
