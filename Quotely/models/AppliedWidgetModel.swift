//
//  AppliedWidgetModel.swift
//  Quotely
//
//  Created by Brilliant Gamez on 8/31/22.
//

import Foundation
import SwiftUI

struct AppliedWidgetModel: Hashable, Codable, Identifiable{
    var id: Int
    var name: String
    var quote: [QuoteModel]
    var data: Data?
    var color: String
    var font_family: String
}
