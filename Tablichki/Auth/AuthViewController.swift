//
//  AuthViewController.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 21.10.2026.
//

import UIKit

class AuthViewController: UIViewController, WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        
        // здесь вызываем функцию получения данных с входным параметром code и делаем замыкание на выдачу результата result в виде двух веток: учачного получения данных и ошибки
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let data):
                print("✅ Токен получен, данные в OAuth2Service.shared.fetchOAuthToken: \(data)")
                
                // Здесь дальше распарсим JSON и сохраним токен
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("jsonString -> ", jsonString)
                }
                
                // декодируем JSON в модель
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    print ("response ---->", response)
                    
                    // чтобы красиво сложить Джейсончик
                    let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let prettyData = try encoder.encode(response)
                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    }
                    
                    
                    print(response)
                    
                    // сохраняем результат в хранилище
                    OAuth2TokenStorage.shared.tokenStorage(storage: response)
                    
                } catch {
                    print("❌ Ошибка декодирования:", error)
                }
                
                vc.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                print("❌ Ошибка получения токена: \(error)")
                vc.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("❌ Пользователь отменил авторизацию")
        //vc.dismiss(animated: true)
        vc.navigationController?.popViewController(animated: true)

    }
    
    
    // на контроллере лого и кнопка войти
    private let image = UIImage(named: "Logo_of_Unsplash")
    private let imageLogoView = UIImageView()
    private lazy var buttonInCome: UIButton = {
        let btn = UIButton.systemButton(
            with: UIImage(systemName: "arrow.right")!,
            target: self,
            action: #selector(buttonIn)
        )
        btn.setTitle("Войти", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        btn.tintColor = .ypBlackIOS
        btn.backgroundColor = .ypWhiteIOS
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    @objc func buttonIn() {
        print("Кнопка Войти нажата")
        
        // сделаем переход на Веб контроллер кодом при помощи навигатораКонтроллера
        let webViewVC = WebViewViewController()
        webViewVC.delegate = self

        navigationController?.pushViewController(webViewVC,animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: true)
        configureBackButton()
        razmetka()
    }
    
    
    // разметка
    func razmetka() {
        if image == nil {
                print("❌ Картинка 'Logo_of_Unsplash' не найдена!")
            } else {
                print("✅ Картинка найдена, размер: \(image!.size)")
            }
        view.addSubview(imageLogoView)
        imageLogoView.image = image
        imageLogoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // кнопка
        view.addSubview(buttonInCome)
        buttonInCome.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonInCome.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonInCome.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            buttonInCome.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            buttonInCome.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            buttonInCome.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // Функция конфигурации кнопки назад в навигаторКонтроллер
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_black_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .systemBlue
    }
}

