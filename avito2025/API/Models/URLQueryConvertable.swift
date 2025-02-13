//
//  URLQueryConvertable.swift
//  avito2025
//
//  Created by Richard Dzubko on 12.02.2025.
//

import Foundation

protocol URLQueryConvertable {
    func convertToQueryParams() -> [URLQueryItem]
}
