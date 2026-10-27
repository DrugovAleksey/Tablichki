//
//  Untitled.swift
//  Tablichki
//
//  Created by Мой БУК on 05.10.2026.
//
import UIKit
import WebKit

protocol WebViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) // получили код
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) // пользователь нажал отмену
}
