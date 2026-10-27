//
//  OAuth2Service.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 21.10.2026.
//


import Foundation

// СинглТон - единственный экземпляр класса
final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    
    
    
    // Функция далает запрос POST в виде https строки
    // в нее приходит в переменную code строка с кодом в качестве входных данных и берутся все данные из массива URLComponents.queryItems, в который уже дозаписали в "code" значение ключа code
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        // проверим доступность адреса для передачи на него запроса с токеном
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        // далее собираем запрос на авторизацию
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        // проверим собрался ли запрос в адресной строке
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        print("request в makeOAuthTokenRequest <->", request)
        return request
    }
    
    // функци fetchOAuthToken создающая полноценный запрос к серверу по методу "POST" с применением выше используемой функции авторизации makeOAuthTokenRequest
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result <Data, Error>)
        -> Void)
    {
        print()
        print("1 fetchOAuthToken - запущена")
        // 1. Получаем готовый запрос из функции makeOAuthTokenRequest
        guard let request = makeOAuthTokenRequest(code: code) else { print ("Не удалось сформировать запрос")
            return
        }
        print()
        print("2 request -> ", request)
        
        // 2. Выполняем запрос через URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // проверка на ошибки
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // проверка на приход данных
            guard let data = data else {
                completion(.failure(NSError(domain: "OAuthError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])))
                return
            }
            print()
            print("3 data ->", data)

            // проверяем HTTP-статус
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "OAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет HTTP-ответа"])
                completion(.failure(error))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(
                    domain: "OAuthError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Ошибка HTTP \(httpResponse.statusCode)"]
                )
                completion(.failure(error))
                return
            }
                print()
                print("4 httpResponse ->", httpResponse)
            
            // если все в норме, то здесь получаем данные
            // ✅ Возвращаем данные на главный поток, если дальше будет UI
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        task.resume()
    }
}
