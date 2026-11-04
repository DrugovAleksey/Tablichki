//
//  WebViewViewController.swift
//  Tablichki
//
//  Created by Мой БУК on 04.10.2026.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    // Функция конфигурации кнопки назад в навигаторКонтроллер
    private func configureBackButton() {
  //      navigationController?.navigationBar.backgroundColor = .systemBackground

    //    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
   //     navigationItem.leftBarButtonItem?.image = UIImage(named: "Backward")
    }
    
    
    // создаем webView на контроллере созданном при переходе после нажатия на кнопку Войти
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent() // <-- Это делает WebView приватным (как Incognito)
        
        let v = WKWebView(frame: .zero, configuration: config)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .ypWhiteIOS
        return v
    }()
    
    // введем переменную прогресса
    private lazy var progressView: UIProgressView = {
        let v = UIProgressView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .ypBlackIOS // цвет заполненной части
        v.trackTintColor = .ypGrayIOS //цвет фона плоскости
        v.progressViewStyle = .bar
        return v
    }()

    
    // создадим переменную делегата со слабой ссылкой
    weak var delegate: WebViewControllerDelegate?
    

    
    
    // MARK: ------ loadAuthView  (загрузчик) ----
    
    // Функция отправляющая на сервер запрос с первоначальными данными для получения ответного токена
    // А теперь самое важное: функция loadAuthView должна быть чистой. Она не должна ничего проверять, не должна пытаться что-то парсить. Её единственная задача — сформировать URL с параметрами Unsplash и сказать webView.load(request).
    
    private func loadAuthView() {
        // создаем переменную в которую загоняем структуру Swifta URLComponents. Непосредственным параметром ее будет строковая переменная с адресом, взятым из нашей константы с адресом.
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("[WebView] ❌ Не удалось создать базовый URL")
            return
        }
        
        // к переменной в которой создана структура добавляем элементы. Элементы храняться как массив словарей ["ключ", значение]. Таких элементов мы туда затолкать можем много, их количество мы определяем в структуре с константами Constants
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        // здесь собираем и проверяем строку с адресом
        guard let url = urlComponents.url else {
            print("[WebView] ❌ Не удалось собрать полный URL")
            return
        }
        
        // здесь упоковали строку в УРЛ
        let request = URLRequest(url: url)
        print("[WebView] 🚀 Загружаем URL: \(url.absoluteString)")

        webView.load(request) // здесь отправили
    }
    
  
    
    // MARK: ------- Наблюдатель демонстрация загрузки -------
    
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
    }
    
    // Функция обновления updateProgress
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    
    
    // MARK: --------- CONSTRAINS ------------------
    
    // MARK: - функция настройки констрейнтов
    func conf() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
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
    }
    
    
    
    
    // MARK: --------- Вывод на ЭКРАН --------------
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("✅ WebViewViewController показан")
        
        // 1. Констрейнты (добавляем на Вью и активируем)
        conf() // сначала добавляем в view и ставим констрейнты
        
        // 2. Назначаем делегата (до любого load!)
        webView.navigationDelegate = self
        
        
            
        // 3. ОДИН единственный load - только OAuth-страница
        loadAuthView()
        configureBackButton()
        updateProgress()
        print("[WebView] Страница авторизации отправлена на загрузку")
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
    }
    
    
    // перед тем как экран скроектся выключаем индикатор
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // удаляем подписку на наблюдателя
        webView.removeObserver(self,
                               forKeyPath: #keyPath(WKWebView.estimatedProgress),
                               context: nil)
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
        // проверяем, получен ли токен
        let urlString = navigationAction.request.url?.absoluteString ?? "Нет УРЛ"
        print("[decidePolicyFor] Пытаемся перейти: \(urlString)")

        // здесь мы берем, полученный ранее токен,
        if let code = code(from: navigationAction) {
            // Нашли код — передаём дальше и отменяем переход
            // ✅ КОД НАЙДЕН!
            print("[decidePolicyFor] Редирект с кодом обнаружен. Передаём код делегату.")

            // Сообщаем родителю, что код получен
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            print("code --->", code)
            
            decisionHandler(.cancel)
        } else {
            
            // ❌ Кода нет: разрешаем браузеру переходить по ссылке (например, показать форму логина)
            print("❌ Кода нет: переходимт 🚀  на страницу авторизации AuthViewController")
            decisionHandler(.allow)
        }
    }
    
    // Функция, вынимающая КОД из ответа по запросу аутентификации (результат в виде строки). Ловим РЕДИРЕКТ
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            // navigationAction — это объект, который WKWebView передаёт в делегат, чтобы спросить: «Я собираюсь перейти по этому адресу — разрешить или заблокировать?»
            let url = navigationAction.request.url,
            
            //url.absoluteString — превращает URL? в обычную строку вида "https://example.com/path?param=value". Даже если в URL есть спецсимволы, они остаются закодированными (например, пробел как %20).
            // URLComponents(string: ...) — создаёт объект URLComponents, который умеет удобно разбирать URL на части: схему, хост, путь, query‑параметры и т. д.
            // Здесь разбираем УРЛ на части
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            // Ищем параметр с имененм "code"
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) // здесь прям вынули токен
        {
            print("[WebView] ✅ НАЙДЕН КОД: \(codeItem)")

            return codeItem.value
        } else {
            return nil
        }
    }
}
