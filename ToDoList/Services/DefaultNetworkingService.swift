import Foundation

enum APIError: Error {
    case badRequest(String)
    case unauthorized(String)
    case notFound(String)
    case internalServerError(String)
    
    var description: String {
        switch self {
        case .badRequest(let message):
            return "400 - Bad Request: \(message)"
        case .unauthorized(let message):
            return "401 - Unauthorized: \(message)"
        case .notFound(let message):
            return "404 - Not Found: \(message)"
        case .internalServerError(let message):
            return "500 - Internal Server Error: \(message)"
        }
    }
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
    
    private let factor: Double = 1.5
    private let maxDelay: TimeInterval = 120.0
    private let minDelay: TimeInterval = 2.0
    private let jitter: Double = 0.05
    
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
    
    private func retryRequest(_ request: URLRequest, retryCount: Int = 0) async throws -> [TodoItem] {

        do {
            let (data, _) = try await urlSession.fetchData(for: request)
            return try await obtainTodoItems(from: data)
        } catch {
            let delay = min(maxDelay, minDelay * pow(factor, Double(retryCount)))
            let jitterAmount = delay * jitter * Double.random(in: 0...1) - 0.5
            let totalTime = delay + jitterAmount

            try await Task.sleep(nanoseconds: UInt64(totalTime * 1_000_000_000))

            if retryCount < 2 {
                return try await retryRequest(request, retryCount: retryCount + 1)
            } else {
                throw APIError.internalServerError("Invalid response format")
            }
        }
    }
    
    private func obtainTodoItems(from data: Data) async throws -> [TodoItem] {
        let parsedJson = try JSONSerialization.jsonObject(with: data)
        
        guard
            let mapJsonArray = parsedJson as? [String: Any],
            let todoItemList = mapJsonArray["list"] as? [[String: Any]],
            let revision = mapJsonArray["revision"] as? Int
        else {
            throw APIError.badRequest("Invalid response format")
        }
        
        var itemsArray: [TodoItem] = []
        
        try todoItemList.forEach { itemJson in
            guard let item = TodoItem.parse(json: itemJson) else {
                throw APIError.badRequest("Failed to parse todo item")
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
            throw APIError.badRequest("Invalid response format")
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
        
        do {
            return try await retryRequest(request)
        } catch {
            throw APIError.internalServerError(error.localizedDescription)
        }
    }
    
    func syncTodoItems(_ items: [TodoItem]) async throws -> [TodoItem] {
        var request = try makeRequest(
            endPoint: "/list",
            httpMethod: .patch,
            isRevision: true
        )
        
        let json = items.map { $0.json }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["list": json], options: .fragmentsAllowed)
        
        do {
            let (data, _) = try await urlSession.fetchData(for: request)
            return try await obtainTodoItems(from: data)
        } catch {
            throw APIError.internalServerError(error.localizedDescription)
        }
    }
    
    func addTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list",
            httpMethod: .post,
            isRevision: true
        )
        
        let requestBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
        request.httpBody = requestBody
        
        do {
            let (data, _) = try await urlSession.fetchData(for: request)
            return try await obtainTodoItem(from: data)
        } catch {
            throw APIError.internalServerError(error.localizedDescription)
        }
    }
    
    func editTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list/\(item.id)",
            httpMethod: .put,
            isRevision: true
        )

        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
                
        do {
            let (data, _) = try await urlSession.fetchData(for: request)
            return try await obtainTodoItem(from: data)
        } catch {
            throw APIError.internalServerError(error.localizedDescription)
        }
    }
    
    func deleteTodoItem(_ item: TodoItem) async throws -> TodoItem {
        var request = try makeRequest(
            endPoint: "/list/\(item.id)",
            httpMethod: .delete,
            isRevision: true
        )
        
        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": item.json])
        
        do {
            let (data, _) = try await urlSession.fetchData(for: request)
            return try await obtainTodoItem(from: data)
        } catch {
            throw APIError.internalServerError(error.localizedDescription)
        }
    }
    
    // этот метод работает, но нигде не используется, он просто реализует метод из API
    func fetchTodoItem(_ item: TodoItem) async throws -> TodoItem {
        let request = try makeRequest(
            endPoint: "/list/\(item.id)",
            httpMethod: .get,
            isRevision: true
        )
                
        do {
            let (data, _) = try await urlSession.fetchData(for: request)
            return try await obtainTodoItem(from: data)
        } catch {
            throw APIError.internalServerError(error.localizedDescription)
        }
    }
}
