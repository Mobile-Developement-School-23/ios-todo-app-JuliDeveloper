import Foundation
import Combine

class TodoItemList: ObservableObject {
    @Published var items: [ObservableTodoItem]
    @Published var isShowCompletedItems = false
    @Published var showItems: [ObservableTodoItem] = []
    @Published var completedItemsCount: Int = 0
    @Published var selectedItem: ObservableTodoItem?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(items: [ObservableTodoItem]) {
        self.items = items
        
        Publishers.CombineLatest($items, $isShowCompletedItems)
            .sink { [weak self] items, isShowCompletedItems in
                self?.showItems = isShowCompletedItems ? items : items.filter { !$0.item.isDone }
                self?.completedItemsCount = items.filter { $0.item.isDone }.count
            }
            .store(in: &cancellables)
        
        $selectedItem
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.isShowCompletedItems = false
            }
            .store(in: &cancellables)
    }
}
