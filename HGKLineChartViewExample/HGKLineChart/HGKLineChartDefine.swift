//
//  HGKLineChartDefine.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/6/9.
//

import UIKit

struct HGKLineChartSecondaryInsets {
    
    public var top: CGFloat
    public var bottom: CGFloat
    
    init(top: CGFloat, bottom: CGFloat) {
        self.top = top
        self.bottom = bottom
    }
}

enum HGKLineChartRefreshState {
    case normal
    case pulling
    case refreshing
    case NoMoreData
}

@objc enum HGKLineChartRefreshType: Int {
    case reload
    case more
}

enum HGKLineChartHorizontalLocation {
    case left
    case right
}

enum HGKLineChartVerticalLocation {
    case top
    case bottom
}

enum HGKLineChartTimeFormatType {
    case hour
    case day
    case year
}

enum HGKLineChartMainIndexType {
    case not
    case ma
    case boll
}

enum HGKLineChartSecondaryIndexType {
    case volume
    case macd
    case rsi
    case kdj
}

struct HGKLineChartTwoParameterIndex {
    
    public var parameter1: Int
    public var parameter2: Int
    
    init(_ parameter1: Int, _ parameter2: Int) {
        self.parameter1 = parameter1
        self.parameter2 = parameter2
    }
}

struct HGKLineChartThreeParameterIndex {
    
    public var parameter1: Int
    public var parameter2: Int
    public var parameter3: Int
    
    init(_ parameter1: Int, _ parameter2: Int, _ parameter3: Int) {
        self.parameter1 = parameter1
        self.parameter2 = parameter2
        self.parameter3 = parameter3
    }
}

struct HGKLineChartTwoParameterIndexLineColor {
    
    public var line1Color: UIColor
    public var line2Color: UIColor
    
    init(_ line1Color: UIColor, _ line2Color: UIColor) {
        self.line1Color = line1Color
        self.line2Color = line2Color
    }
}

struct HGKLineChartThreeParameterIndexLineColor {
    
    public var line1Color: UIColor
    public var line2Color: UIColor
    public var line3Color: UIColor
    
    init(_ line1Color: UIColor, _ line2Color: UIColor, _ line3Color: UIColor) {
        self.line1Color = line1Color
        self.line2Color = line2Color
        self.line3Color = line3Color
    }
}

enum HGKLineChartIndexLocation {
    case not
    case left
    case right
}
