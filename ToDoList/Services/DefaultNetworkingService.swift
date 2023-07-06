import Foundation

private enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

private enum NetworkError: Error {
    case codeError
    case notData
    case invalidURL
    case parseError
}

protocol NetworkingService {
    func fetchTodoItems() async throws -> [TodoItem]
    func addTodoItem(_ item: TodoItem) async throws -> TodoItem
}

final class DefaultNetworkingService {
    static let shared = DefaultNetworkingService()
    
    private let urlSession = URLSession.shared

    var revision = RevisionStorage().latestKnownRevision
    
    private init() {}
    
    private func makeRequest(endPoint: String, httpMethod: HttpMethod, isRevision: Bool) throws -> URLRequest {
        guard let url = URL(string: Constants.baseUrl + endPoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue(
            "Bearer \(TokenStorage.token)", forHTTPHeaderField: "Authorization"
        )
        
        if isRevision {
            request.setValue(
                "\(revision)", forHTTPHeaderField: "X-Last-Known-Revision"
            )
        }
        
        return request
    }
    
    private func obtainTodoItems(from data: Data) async throws -> [TodoItem] {
        let parsedJson = try JSONSerialization.jsonObject(with: data)
        
        guard
            let mapJsonArray = parsedJson as? [String: Any],
            let todoItemList = mapJsonArray["list"] as? [[String: Any]],
            let revision = mapJsonArray["revision"] as? Int
        else {
            throw NetworkError.notData
        }
        
        var itemsArray: [TodoItem] = []
        
        try todoItemList.forEach { itemJson in
            guard let item = TodoItem.parse(json: itemJson) else {
                throw URLError(.cannotDecodeContentData)
            }
            itemsArray.append(item)
        }
        
        self.revision = revision
        
        return itemsArray
    }
    
    private func obtainTodoItem(from data: Data) async throws -> TodoItem {
        let json = try JSONSerialization.jsonObject(with: data)
        guard
            let jsonArray = json as? [String: Any],
            let element = jsonArray["element"] as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let todoItem = TodoItem.parse(json: element)
        else {
            throw NetworkError.parseError
        }
        
        self.revision = revision
        
        return todoItem
    }
}

extension DefaultNetworkingService: NetworkingService {
    func fetchTodoItems() async throws -> [TodoItem] {
        let request = try makeRequest(
            endPoint: "/list",
            httpMethod: HttpMethod.get,
            isRevision: false
        )

        let (data, response) = try await urlSession.fetchData(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.codeError
        }
        
        guard !data.isEmpty else {
            throw NetworkError.notData
        }
        
        return try await obtainTodoItems(from: data)
    }
    
    func addTodoItem(_ item: TodoItem) async throws -> TodoItem {
        guard let url = URL(string: "https://beta.mrdekk.ru/todobackend/list") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(TokenStorage.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let requestBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
        request.httpBody = requestBody
        
        let (data, response) = try await urlSession.fetchData(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.codeError
        }
        
        guard !data.isEmpty else {
            throw NetworkError.notData
        }
        
        return try await obtainTodoItem(from: data)
    }
}
