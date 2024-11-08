//
//  APIError.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import Foundation

enum APIError: Error {
    case invalidUrl
    case dataNotFound
    case invalidResponse
}
