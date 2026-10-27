//
//  OAuthTokenResponseBody.swift
//  Tablichki
//
//  Created by Мой БУК on 18.10.2026.
//

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let refresh_token: String
    let created_at: Int
    let scope: String
    let token_type: String
    let user_id: Int
    let username: String
}
