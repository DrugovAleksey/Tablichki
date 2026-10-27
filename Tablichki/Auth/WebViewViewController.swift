//
//  WebViewViewController.swift
//  Tablichki
//
//  Created by Мой БУК on 04.10.2026.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    // создаем webView на контроллере созданном при переходе после нажатия на кнопку Войти
    private lazy var webView: WKWebView = {
        let v = WKWebView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .brown
        return v
    }()
    
    // введем переменную прогресса
    private lazy var progressView: UIProgressView = {
        let v = UIProgressView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .systemRed // цвет заполненной части
        v.trackTintColor = .lightGray //цвет фона плоскости
        v.progressViewStyle = .bar
        return v
    }()
    
    // ведем активитиИндикатор
    private var activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView()
        a.translatesAutoresizingMaskIntoConstraints = false
        a.style = .large
        a.color = .ypRedIOS
        return a
    }()
    
    
    // создадим переменную делегата со слабой ссылкой
    weak var delegate: WebViewControllerDelegate?
    

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        conf()
        loadAuthView()
        updateProgress()
    }
    
    
    // MARK: - loadAuthView  (загрузчик)
    // Функция отправляющая на сервер запрос с первоначальными данными для получения ответного токена
    private func loadAuthView() {
        // создаем переменную в которую загоняем структуру Swifta URLComponents. Непосредственным параметром ее будет строковая переменная с адресом, взятым из нашей константы с адресом.
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { return }
        
        // к переменной в которой создана структура добавляем элементы. Элементы храняться как массив словарей ["ключ", значение]. Таких элементов мы туда затолкать можем много, их количество мы определяем в структуре с константами Constants
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        // здесь собираем и проверяем строку с адресом
        guard let url = urlComponents.url else { return }
        
      //  let url = URL(string: "https://unsplash.com/login")
        let request = URLRequest(url: url) // здесь упоковали строку в УРЛ
        print (request)
        webView.load(request) // здесь отправили
    }
    
    
    
    // MARK: - viewDidApper перед тем как станет окно видимым
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // вводим наблюдателя
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
        
        // Запускаем индикатор
            activityIndicator.startAnimating()
    }
    
    
    // перед тем как экран скроектся
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // удаляем подписку на наблюдателя
        webView.removeObserver(self,
                               forKeyPath: #keyPath(WKWebView.estimatedProgress),
                               context: nil)
        
        activityIndicator.stopAnimating()

    }
    
    
    
    // MARK: - Функция наблюдателя
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object, change: change, context: context)
        }
        activityIndicator.stopAnimating()

    }
    
    
    // Функция обновления updateProgress
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    

    
    
    // MARK: - функция настройки констрейнтов
    func conf() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // конфигурируем прогресс
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        // конфигурируем активитиИндикатор
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 100),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}



// MARK: - extension
extension WebViewViewController: WKNavigationDelegate {
    // Функция получающая КОД из ответа по запросу аутентификации
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy)
        -> Void
    ) {
        // здесь мы ловим ответ с токеном
        if let code = code(from: navigationAction) {
            // Нашли код — передаём дальше и отменяем переход
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            
            print("code --->", code)
            decisionHandler(.cancel)
        } else {
            print("code ---------->", code)

            decisionHandler(.allow)
        }
    }
    
    // Функция, вынимающая КОД из ответа по запросу аутентификации (результат в виде строки)
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            // navigationAction — это объект, который WKWebView передаёт в делегат, чтобы спросить: «Я собираюсь перейти по этому адресу — разрешить или заблокировать?»
            let url = navigationAction.request.url,
            
                //url.absoluteString — превращает URL? в обычную строку вида "https://example.com/path?param=value". Даже если в URL есть спецсимволы, они остаются закодированными (например, пробел как %20).
            // URLComponents(string: ...) — создаёт объект URLComponents, который умеет удобно разбирать URL на части: схему, хост, путь, query‑параметры и т. д.
                let urlComponents = URLComponents(string: url.absoluteString),
            
                // производим сравнение путей из УРЛ и ожидаемый. Не понятно для чего это надо, работает и без этого сравнения
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) // здесь прям вынули токен
        {
            
            print("url =", url)
            print("urlComponents = \(urlComponents)")
            print("url.absoluteString =", url.absoluteString)
            print( "items = \(items)" )
            print( "codeItem.value =", codeItem)
            return codeItem.value
        } else {
            return nil
        }
    }
}
