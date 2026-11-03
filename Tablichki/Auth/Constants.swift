//
//  Constants.swift
//  Tablichki
//
//  Created by Мой БУК on 04.10.2026.
//
import Foundation

enum Constants {
    static let accessKey = "9CSgd0OZBSyzDt5MX_GdLn3dXh49XEfYjHsvo6xNScE"
    static let secretKey = "oC9AQtzVpl2RrGgiAxGLVdF5P2dC4ehby70X8DhdGhc"
    static let accessScope = "public+read_user+write_likes"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
//    static let redirectURI = "http://localhost/callback"

    static let defaultBaseURLString = URL(string: "https://api.unsplash.com")
}


// константа адреса, где будем авторизоваться
// специальный адрес с которого мы и получаем code
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
//https://unsplash.com/login
//https://unsplash.com/oauth/authorize
//"http://localhost/callback"
