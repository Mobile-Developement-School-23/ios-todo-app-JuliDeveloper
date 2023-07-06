import XCTest
@testable import ToDoList

final class URLSessionsTests: XCTestCase {
    
    func testFetchData() async {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else { return }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.fetchData(for: request)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
}
