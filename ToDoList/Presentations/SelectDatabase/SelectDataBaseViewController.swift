import UIKit

final class SelectDataBaseViewController: UIViewController {
    
    private let storageManager: StorageManager
    private var viewModel: TodoListViewModelProtocol
    
    weak var delegate: SelectDatabaseViewControllerDelegate?
    
    init(
        storageManager: StorageManager = StorageManager.shared,
        viewModel: TodoListViewModelProtocol
    ) {
        self.storageManager = storageManager
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let customView = SelectDatabaseView(frame: view.frame)
        customView.delegate = self
        customView.config()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        title = "Выберете способ хранения задач"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(handleDatabaseChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleDatabaseChange(_ notification: Notification) {
        updateViewModel()
    }
    
    private func updateViewModel() {
        let databaseService: DatabaseService
        if StorageManager.shared.useCoreData {
            databaseService = CoreDataService()
        } else {
            databaseService = SQLiteService()
        }
        viewModel = TodoListViewModel(database: databaseService)
        delegate?.didUpdateDatabaseService(self, service: databaseService)
    }
}

extension SelectDataBaseViewController: SelectDatabaseViewDelegate {
    func sqliteSwitchDidChange(_ sender: UISwitch) {
        storageManager.useCoreData = !sender.isOn
        updateViewModel()
    }
    
    func coreDataSwitchDidChange(_ sender: UISwitch) {
        storageManager.useCoreData = sender.isOn
        updateViewModel()
    }
    
    func closeViewController() {
        dismiss(animated: true)
    }
}
