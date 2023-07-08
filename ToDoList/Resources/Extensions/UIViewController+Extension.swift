import UIKit

extension UIViewController {
    func showAlert(_ deleteAction: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Вы точно хотите удалить заметку?", message: nil, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive, handler: deleteAction)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    func showAttentionAlert() {
        let alert = UIAlertController(title: "Данные загружены не из сети", message: "Все новые данные не сохраняться. Проверьте интернет соединение.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OК", style: .cancel)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
