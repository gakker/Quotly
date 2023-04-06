//
//  AddWidgetResponse.swift
//  Quotely
//
//  Created by Brilliant Gamez on 10/24/22.
//

import Foundation
import Foundation
struct AddWidgetResponse: Hashable, Codable{
    var status: Bool
    var message: String
    var widget_status: Bool
    var Quotes: [QuoteModel]
}
