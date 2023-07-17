import UIKit

final class DataManager {
    static let shared = DataManager()
    
    let ids = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    ]
    
    let texts = [
        "Поливать цветы", "Заказать продукты онлайн", "Записаться на тренировку",
        "Закончить отчет", "Позвонить другу", "Проверить электронную почту",
        "Сходить в аптеку", "Прочитать книгу", "Посетить врача", "Сделать уборку"
    ]
    
    let colors: [UIColor] = [
        UIColor.systemRed, UIColor.systemBlue, UIColor.systemCyan,
        UIColor.systemMint, UIColor.systemPink, UIColor.systemBrown,
        UIColor.systemIndigo, UIColor.systemOrange, UIColor.systemPurple,
        UIColor.systemYellow
    ]
    
    let importance: [Importance] = [.important, .normal, .unimportant]
    
    let isDone = [false, true]
    
    private init() {}
}
