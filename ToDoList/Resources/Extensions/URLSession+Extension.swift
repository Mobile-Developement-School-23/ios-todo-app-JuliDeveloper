//import Foundation
//
//private enum NetworkError: Error {
//    case noData
//    case codeError
//}
//
//extension URLSession {
//    func fetchData(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
//        //        return try await withCheckedThrowingContinuation { continuation in
//        //            let task = self.dataTask(with: urlRequest) { (data, response, error) in
//        //                if let response = response as? HTTPURLResponse {
//        //                    if response.statusCode >= 200 && response.statusCode < 300 {
//        //                        if let data = data {
//        //                            continuation.resume(returning: (data, response))
//        //                        } else {
//        //                            continuation.resume(throwing: NetworkError.noData)
//        //                            continuation.resume(throwing: NetworkError.codeError)
//        //                        }
//        //                    }
//        //                } else if let error = error {
//        //                    continuation.resume(throwing: error)
//        //                }
//        //            }
//        //            task.resume()
//        //        }
//
//        //        return try await withTaskCancellationHandler {
//        //            var task: URLSessionDataTask?
//        //            try await withCheckedThrowingContinuation { continuation in
//        //                task = self.dataTask(with: urlRequest) { (data, response, error) in
//        //                    if let error = error {
//        //                        continuation.resume(throwing: error)
//        //                    } else if let response = response as? HTTPURLResponse, let data = data {
//        //                        if (200...299).contains(response.statusCode) {
//        //                            continuation.resume(returning: (data, response))
//        //                        } else {
//        //                            continuation.resume(throwing: NetworkError.codeError)
//        //                        }
//        //                    } else {
//        //                        continuation.resume(throwing: NetworkError.noData)
//        //                    }
//        //                }
//        //                task.resume()
//        //            } onCancel: {
//        //                await Task.sleep(for: .nanoseconds(1))
//        //                if Task.isCancelled {
//        //                    task?.cancel()
//        //                }
//        //            }
//        //            //task.resume()
//        //        }
//        //    }
//
//        //}
//    }
//}
