//
//  SplashViewController.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 21.10.2026.
//


import UIKit

class SplashViewController: UIViewController {
    
    // введем переменную которая берет данных из хранилища
    private let storage = OAuth2TokenStorage.shared
    
    // вьюшка для картинки
    let viewImageSplash: UIImageView = {
        let viewIS = UIImageView()
        viewIS.contentMode = .scaleAspectFit
        return viewIS
    }()
    
    
    // переменная картинки для спрашь экрана
    let image: UIImage? = UIImage(named: "splash_screen_logo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        razmetka()
        print("разметка загрузилась")


    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("✅ SplashViewController показан")

        // Запускаем анимацию лого (если есть)
        animateLogo()

        // Таймер на 3 секунды: потом сработает performRouting()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.performRouting()
        }
        
    }
    private func animateLogo() {
        viewImageSplash.alpha = 0 // прозрачность
        viewImageSplash.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: .pi / 4) // стартовые размеры

        UIView.animate(
            withDuration: 3.0, // замедление (время проигрывания)
            delay: 0.5, // задержка анимации
            usingSpringWithDamping: 0.8, //(0..1, пружинит)
            initialSpringVelocity: 15.0 // увеличение с возвращением (пружинная анимация)
        ) {
            self.viewImageSplash.alpha = 1
            self.viewImageSplash.transform = .identity
        }
    }
    
    private func razmetka() {
        view.addSubview(viewImageSplash)
 
        viewImageSplash.translatesAutoresizingMaskIntoConstraints = false
        
        viewImageSplash.image = image
        
        
        NSLayoutConstraint.activate([
            viewImageSplash.topAnchor.constraint(equalTo: view.topAnchor, constant: 272),
            viewImageSplash.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewImageSplash.widthAnchor.constraint(equalToConstant: 73),
            viewImageSplash.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    // создадим функци - "Выполнить маршутизацию" - performRouting
    func performRouting() {
        
        guard let window = self.view.window else { return }
        
        // сбросим токен для появления окна авторизации
     //   storage.token = nil
        
        // проверяем наличие сохраненного токена в хранилище
        if storage.token != nil {
            
            // тогда пользователь авторизован и мы его переключаем на экран с пользовательскими данными (ProfileViewController) или галерею (ImagesListViewController)
            print ("Пользователь \(storage.name ?? "") авторизован")
            
            // ✅ Авторизован: собираем таббар как новый root
            // вкладка первая
            let imagesListVC = ImagesListViewController()
            
            imagesListVC.tabBarItem = UITabBarItem (
                title: "",
                image: UIImage(named: "tab_editorial_active")?.withRenderingMode(.alwaysOriginal),
                tag: 0
                )
            
            // вкладка вторая
            let profileVC = ProfileViewController()
            profileVC.tabBarItem = UITabBarItem(
                title: "",
                image: UIImage(named: "tab_profile_active")?.withRenderingMode(.alwaysOriginal),
                tag: 1
            )
            
            // собираем сам ТабБарКонтроллер
            let tabBarVC = UITabBarController()
            tabBarVC.tabBar.backgroundColor = .ypBlackIOS
            tabBarVC.viewControllers = [imagesListVC, profileVC]
            tabBarVC.selectedIndex = 0
            // делаем рутовым (основным) экраном контроллер ТабБар
            window.rootViewController = tabBarVC

            print("✅ Переход на TabBarController выполнен")

        } else {
            // иначе мы его переключаем на экран с авторизацией AuthViewController
            print ("❌ Пользователь не авторизован")
            // ❌ Не авторизован: ставим экран входа как новый root
            
            let authVC = AuthViewController()
            navigationController?.pushViewController(authVC, animated: true)
          //  window.rootViewController = authVC
            print ("✅ Переход на экран AuthViewController совершен")
        }
    }
}
