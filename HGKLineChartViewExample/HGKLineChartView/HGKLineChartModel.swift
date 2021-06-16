//
//  HGKLineChartModel.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/26.
//

import Foundation

class HGKLineChartModel: Codable {
    
    var low: String
    var high: String
    var open: String
    var close: String
    var time: TimeInterval
    var vol: Int
    
    var ma1: Double?  // MA
    var ma2: Double?
    var ma3: Double?
    var md: Double?  // BOLL标准差
    var mb: Double?  // BOLL中轨线
    var up: Double?  // BOLL上轨线
    var dn: Double?  // BOLL下轨线
    var emas: Double?  // ema短期
    var emal: Double?  // ema长期
    var diff: Double?  // 差离值
    var dea: Double?  // 差离平均值
    var macd: Double?  // MACD柱状
    var rsi1: Double?  // 相对强弱指标
    var rsi2: Double?  // 相对强弱指标
    var rsi3: Double?  // 相对强弱指标
    var k: Double?  // KDJ(K)
    var d: Double?  // KDJ(D)
    var j: Double?  // KDJ(J)

}
