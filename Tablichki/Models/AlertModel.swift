//
//  AlertModel.swift
//  Tablichki
//
//  Created by Мой БУК on 27.10.2026.
//

import UIKit

// Модель Алерта
struct AlertModel {
    let alertTitle : String
    let alertMessage : String
    
    let firstButtonTitle: String
    let firstButtonAction: (() -> Void)? // действие при нажатии на кнопку
    
    let secondButtonTitle: String? // может быть nil, если нужна только одна кнопка
    let secondButtonAction: (() -> Void)?
}

// Метод отображения алерта в любом контроллере
extension UIViewController {
    // Алерты!
    func showAlert( with model: AlertModel) {
        // создаем контроллер
        let alert = UIAlertController(
            title: model.alertTitle,
            message: model.alertMessage,
            preferredStyle: .alert
        )
        
        //создаем кнопку 1
        let alertButton = UIAlertAction(
            title: model.firstButtonTitle,
            style: .default) {_ in
                model.firstButtonAction?()
            }
        alert.addAction(alertButton) // кнопку на алерт добавляем
        
        // если будет кнопка 2
        if let secondTitle = model.secondButtonTitle {
            let secondAction = UIAlertAction(
                title: model.secondButtonTitle,
                style: .cancel) { _ in
                    model.secondButtonAction?()
                }
            alert.addAction(secondAction)
        }
        
        // покажем алерт
        self.present(alert, animated: true)
    }

}
