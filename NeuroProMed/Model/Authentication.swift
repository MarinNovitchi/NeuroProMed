//
//  Authentication.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 11.06.2021.
//

import Foundation

struct Authentication: Codable {
    let identityToken: String //jwt
    let userIdentifier: String
    let nonce: String?
    let userID: UUID
    let firstName: String?
    let lastName: String?
    let isDoctor: Bool
}
