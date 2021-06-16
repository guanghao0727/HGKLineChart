//
//  HGKLineChartStyleSet.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/27.
//

import UIKit

class HGKLineChartStyleSet: NSObject {
    
    // 背景
    var backgroundColor = UIColor.white
    
    // 图表
    var mainSecondaryHeightRatio: CGFloat = 0.78  //主图副图高度比例
    var isShowSecondaryView = false  //是否显示副图
    var mainInset = UIEdgeInsets(top: 5, left: 10, bottom: 34, right: 10)  //主图表内边距
    var secondaryInset = HGKLineChartSecondaryInsets(top: 5, bottom: 5)  //副图表内边距
    var loadingAnimateColor: UIColor?  //菊花颜色
    
    // 横线价格
    var priceLineColor = UIColor.init(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 0.2)  //价格横线颜色
    var priceLineCount: Int = 5  //价格横线条数
    var priceLineWidth: CGFloat = 0.5  //价格横线宽度
    var priceLineDashLengths: [CGFloat] = [3, 1]  //设置价格虚线
    var priceLocation: HGKLineChartHorizontalLocation = .right  //价格位置
    var priceColor = UIColor.black.withAlphaComponent(0.6)  //价格颜色
    var priceFont = UIFont.systemFont(ofSize: 9)  //价格字体
    
    // 蜡烛
    var candleWidth: CGFloat = 5  //蜡烛宽度
    var candleMinWidth: CGFloat = 2.5  //蜡烛最小宽度
    var candleMaxWidth: CGFloat = 30  //蜡烛最大宽度
    var candleLineWidth: CGFloat = 1  //蜡烛影线宽度
    var candleSpace: CGFloat = 2  //蜡烛间距
    var candleRiseColor = UIColor.red  //上涨颜色
    var candleFallColor = UIColor.green  //下跌颜色
    
    // 时间
    var timeBetweenNumber: Int = 10  //时间间隔个数
    var timeLineColor = UIColor.init(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 0.2)  //时间竖线颜色
    var timeLineWidth: CGFloat = 0.5  //时间竖线宽度
    var timeLineDashLengths: [CGFloat] = [3, 1]  //设置时间虚线
    var timeLocation: HGKLineChartVerticalLocation = .bottom  //时间位置
    var timeColor = UIColor.black.withAlphaComponent(0.6)  //时间颜色
    var timeFont = UIFont.systemFont(ofSize: 9)  //时间字体
    var timeFormatType: HGKLineChartTimeFormatType = .hour  //时间格式
    
    // 最高及低价格
    var isShowHighestLowestPrice = true  //是否显示最高低价格
    var highestLowestPriceColor = UIColor.black  //最高低价格颜色
    var highestLowestPriceFont = UIFont.systemFont(ofSize: 9)  //最高低价格字体
    
    // 主图指标
    var mainIndexType: HGKLineChartMainIndexType = .not  //显示
    var mainIndexLineWidth: CGFloat = 1  //主图指标线宽度
//    var mainIndexLocation: HGKLineChartIndexLocation = .right  //指标参数位置
    var maIndex = HGKLineChartThreeParameterIndex(5, 10, 20)
    var maIndexLineColor = HGKLineChartThreeParameterIndexLineColor(.purple, .green, .orange)
    var bollIndex = HGKLineChartTwoParameterIndex(20, 2)
    var bollIndexLineColor = HGKLineChartThreeParameterIndexLineColor(.purple, .green, .orange)
    
    // 副图
    var secondaryIndexType: HGKLineChartSecondaryIndexType = .volume
    var secondaryIndexLineWidth: CGFloat = 1  //主图指标线宽度
//    var secondaryIndexLocation: HGKLineChartIndexLocation = .right  //指标参数位置
    var secondaryVolumeName: String = "手"  //成交量单位名称
    var macdIndex = HGKLineChartThreeParameterIndex(12, 26, 9)
    var macdIndexLineColor = HGKLineChartTwoParameterIndexLineColor(.purple, .green)
    var rsiIndex = HGKLineChartThreeParameterIndex(6, 12, 24)
    var rsiIndexLineColor = HGKLineChartThreeParameterIndexLineColor(.purple, .green, .orange)
    var kdjIndex = HGKLineChartThreeParameterIndex(9, 3, 3)
    var kdjIndexLineColor = HGKLineChartThreeParameterIndexLineColor(.purple, .green, .orange)
    
    // 选中十字线
    var selectCandleLineWidth: CGFloat = 1  //直线宽度
    var selectCandleLineColor = UIColor.gray  //直线颜色
    var selectCandleBackgroundColor = UIColor.gray  //文字背景颜色
    var selectCandleTextColor = UIColor.white  //文字颜色
    var selectCandleFont = UIFont.systemFont(ofSize: 9)  //文字字体
    var selectCandleTimeLocation: HGKLineChartVerticalLocation = .bottom  //时间位置
    
}
