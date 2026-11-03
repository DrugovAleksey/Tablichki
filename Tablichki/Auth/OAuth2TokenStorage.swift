//
//  OAuth2TokenStorage.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 21.10.2026.
//

import Foundation

class OAuth2TokenStorage {
    
    // хранилище делаем единственным - синглТоном, чтобы все хранилось в одном месте
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let defaults = UserDefaults.standard
    private static let tokenKey = "access_token"
    private static let created_at = "created_at"
    private static let refresh_token = "refresh_token"
    private static let scope = "scope"
    private static let tokey_type = "token_type"
    private static let user_id = "user_id"
    private static let name = "username"

    
    // Вычисляемое свойство: сразу считается и пишет в UserDefaults
    var token: String? {
        get {
            return defaults.string(forKey: Self.tokenKey)
        }
        set {
            if let value = newValue {
                defaults.set(value, forKey: Self.tokenKey)
            } else {
                defaults.removeObject(forKey: Self.tokenKey)
            }
        }
    }
    
    var name: String? {
        get { defaults.string(forKey: Self.name) }
        set { defaults.set(newValue, forKey: Self.name) }
    }
    
    // если надо сохранить другие поля таким способом
//    var refreshToken: String? {
//        get { defaults.string(forKey: "refresh_token") }
//        set { defaults.set(newValue, forKey: "refresh_token") }
//    }
//
//    var userId: Int? {
//        get { defaults.integer(forKey: "user_id") == 0 ? nil : defaults.integer(forKey: "user_id") } // осторожно с 0
//        set { if let v = newValue { defaults.set(v, forKey: "user_id") } else { defaults.removeObject(forKey: "user_id") } }
//    }
    
    
    // сохраняем все в UserDefaults
    func tokenStorage (storage: OAuthTokenResponseBody?) {
        guard let storage = storage else {return}
        print("❌ tokenStorage: пришёл nil — ничего не сохраняем")

        UserDefaults.standard.set(storage.access_token, forKey: "access_token")
        UserDefaults.standard.set(storage.created_at, forKey: "created_at")
        UserDefaults.standard.set(storage.refresh_token, forKey: "refresh_token")
        UserDefaults.standard.set(storage.scope, forKey: "scope")
        UserDefaults.standard.set(storage.token_type, forKey: "token_type")
        UserDefaults.standard.set(storage.user_id, forKey: "user_id")
        UserDefaults.standard.set(storage.username, forKey: "username")
    }
    
    
    
    // Функция сброса всех ключей
    func resetStorage() {
        let keyToRemove = [
            Self.tokenKey,
            Self.name,
            "refresh_token",
            "created_at",
            "scope",
            "token_type",
            "user_id"
        ]
        
        keyToRemove.forEach { key in
            defaults.removeObject(forKey: key)
        }
        // Сохраняем изменения сразу
        defaults.synchronize()
    }
}
