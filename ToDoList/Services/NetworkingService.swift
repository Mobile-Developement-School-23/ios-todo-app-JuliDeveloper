import Foundation

private enum NetworkError: Error {
    case codeError
}

protocol NetworkingServiceProtocol {
    func getTodoItemList(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func putTodoItemList(_ item: TodoItem, completion: @escaping (Result<Data, Error>) -> Void)
    func updateTodoItemList(_ list: [TodoItem], completion: @escaping (Result<Data, Error>) -> Void)
    
}

final class DefaultNetworkingService {
    static let shared = DefaultNetworkingService()
    
    var latestKnownRevision: Int32 = 0
        
    private init() {}
    
    private func makeRequest(with urlString: String, and bearerToken: String) -> URLRequest {
        guard
            let url = URL(string: urlString)
        else {
            return URLRequest(url: URL(fileURLWithPath: ""))
            
        }
        
        var request = URLRequest(url: url)
        request.setValue("\(bearerToken)", forHTTPHeaderField: "Authorization: Bearer <token>")
        return request
    }
}

extension DefaultNetworkingService: NetworkingServiceProtocol {
    func getTodoItemList(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: "https://beta.mrdekk.ru/todobackend/list") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(TokenStorage.token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(TodoItemListResult.self, from: data)
                    var todoItems = [TodoItem]()
                    
                    for item in result.list {
                        let convertItem = item.convert()
                        todoItems.append(convertItem)
                    }
                    
                    self.latestKnownRevision = result.revision
                    
                    completion(.success(todoItems))
                } catch let error {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func putTodoItemList(_ item: TodoItem, completion: @escaping (Result<Data, Error>) -> Void) {
        let currentId = UUID(uuidString: item.id)
        guard let url = URL(string: "https://beta.mrdekk.ru/todobackend/list/\(currentId?.uuidString ?? "")") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(TokenStorage.token)", forHTTPHeaderField: "Authorization")
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(latestKnownRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let newTodoItem = item.convert()
        let newList = TodoItemListResult(status: "ok", list: [newTodoItem], revision: 0)
        
        do {
            let jsonData = try JSONEncoder().encode(newList)
            request.httpBody = jsonData
        } catch let error {
            print(error)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
    }
    
    func updateTodoItemList(_ list: [TodoItem], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://beta.mrdekk.ru/todobackend/list") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(TokenStorage.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(latestKnownRevision)", forHTTPHeaderField: "X-Last-Known-Revision")

//        let newList = TodoItemListResult(status: "ok", list: list.map { $0.convert() }, revision: latestKnownRevision)
//
//        do {
//            let jsonData = try JSONEncoder().encode(newList)
//            request.httpBody = jsonData
//        } catch let error {
//            print(error)
//        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    completion(.success(data ?? Data()))
                } else {
                    completion(.failure(NetworkError.codeError))
                }
            }
        }
        task.resume()
    }
}
