//
//  HttpModel.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/26.
//

import Foundation

struct HttpModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case isSuccess = "is_succ"
        case code
        case message
        case data
    }
    
    let isSuccess: Int?
    let code: Int?
    let message: String?
    let data: dataModel?
    
    struct dataModel: Codable {
        let page_count: Int?
        let record_count: Int?
        let records: [HGKLineChartModel]?
    }
    
}
