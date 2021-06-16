//
//  HttpModel.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/26.
//

import Foundation

struct HttpModel: Codable {
    
    var is_succ: Int?
    var code: Int?
    var message: String?
    var data: dataModel?
    
    struct dataModel: Codable {
        var page_count: Int?
        var record_count: Int?
        var records: [HGKLineChartModel]?
    }
    
}
