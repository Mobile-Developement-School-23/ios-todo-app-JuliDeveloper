import Foundation

private enum NetworkServiceError: Error {
    case codeError
    case notData
    case invalidURL
    case parseError
}

private enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol NetworkingService {
    func fetchTodoItems() async throws -> [TodoItem]
    func addTodoItem(_ item: TodoItem) async throws -> TodoItem
    func syncTodoItems(_ items: [TodoItem]) async throws -> [TodoItem]
    func editTodoItem(_ item: TodoItem) async throws -> TodoItem
    func deleteTodoItem(_ item: TodoItem) async throws -> TodoItem
    func fetchTodoItem(_ item: TodoItem) async throws -> TodoItem
}

final class DefaultNetworkingService {
    static let shared = DefaultNetworkingService()
    
    private let urlSession = URLSession.shared
    
    private var revision = RevisionStorage().latestKnownRevision
    
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
            throw NetworkServiceError.notData
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
            throw NetworkServiceError.parseError
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
        
        let (data, _) = try await urlSession.fetchData(for: request)
        return try await obtainTodoItems(from: data)
    }
    
    func syncTodoItems(_ items: [TodoItem]) async throws -> [TodoItem] {
        var request = try makeRequest(
            endPoint: "/list",
            httpMethod: .patch,
            isRevision: true
        )
        
        let json = items.map { $0.json }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["list": json], options: .fragmentsAllowed)
        
        let (data, _) = try await urlSession.fetchData(for: request)
        return try await obtainTodoItems(from: data)
    }
    
    func addTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list",
            httpMethod: .post,
            isRevision: true
        )
        
        let requestBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
        request.httpBody = requestBody
        
        let (data, _) = try await urlSession.fetchData(for: request)
        return try await obtainTodoItem(from: data)
    }
    
    func editTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list/\(item.id)",
            httpMethod: .put,
            isRevision: true
        )

        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
        
        let (data, _) = try await urlSession.fetchData(for: request)
        return try await obtainTodoItem(from: data)
    }
    
    func deleteTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list/\(item.id)",
            httpMethod: .delete,
            isRevision: true
        )
        
        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
        
        let (data, _) = try await urlSession.fetchData(for: request)
        return try await obtainTodoItem(from: data)
    }
    
    // этот метод работает, но нигде не используется, он просто реализует метод из API
    func fetchTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list/\(item.id)",
            httpMethod: .get,
            isRevision: true
        )
                
        let (data, _) = try await urlSession.fetchData(for: request)
        return try await obtainTodoItem(from: data)
    }
}
