//
//  HGKLineChartScrollView.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/26.
//

import UIKit

typealias HGKLineChartScrollBlock = (HGKLineChartRefreshType) -> ()

class HGKLineChartScrollView: UIScrollView {
    
    private var contentOffsetObserve: NSKeyValueObservation?
    private var mainHeight: CGFloat = 0
    private var secondaryHeight: CGFloat = 0
    private var lastContentSizeWidth: CGFloat = 0
    private var digits: Int = 0
    private(set) var priceTextWidth: CGFloat = 0
    private var priceCoordsScale: CGFloat = 0
    private var secondaryCoordsScale: CGFloat = 0
    private(set) var minIndex: Int = 0
    private(set) var maxIndex: Int = 0
    private var mainMaxPrice: Double = 0
    private var mainMinPrice: Double = 0
    private var secondaryMaxValue: Double = 0
    private var secondaryMinValue: Double = 0
    
    var datas: [HGKLineChartModel] = [] {
        didSet {
            self.datas = datas.reversed()
            setCalculate()
            setPriceWidthAndFormat()
            setContentSize()
            if oldValue.count == 0 || oldValue.count >= datas.count {
                // 重新加载（左拉）
                setContentOffset(CGPoint(x: contentSize.width - frame.width + (styleSet.priceLocation == .left ? styleSet.mainInset.right : priceTextWidth), y: 0), animated: false)
            } else {
                // 更多加载（右拉）
                setContentOffset(CGPoint(x: contentSize.width - lastContentSizeWidth - styleSet.mainInset.left, y: 0), animated: false)
            }
            lastContentSizeWidth = contentSize.width
        }
    }
    var styleSet = HGKLineChartStyleSet() {
        didSet {
            setNeedsDisplay()
        }
    }
    var refreshState: HGKLineChartRefreshState = .normal
    var refreshBlock: HGKLineChartScrollBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        contentOffsetObserve = observe(\.contentOffset, options: .new, changeHandler: { _, _ in
            self.scrollViewContentOffsetDidChange()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 获取上下文
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.clear(rect)
        
        // 背景颜色
        context.setFillColor(styleSet.backgroundColor.cgColor)
        context.fill(rect)
        
        if datas.count > 0 {
            // 获取最高低价格坐标
            var highestPrice: String = ""
            var highestPriceX: CGFloat = 0
            var highestPriceY: CGFloat = CGFloat.greatestFiniteMagnitude
            var lowestPrice: String = ""
            var lowestPriceX: CGFloat = 0
            var lowestPriceY: CGFloat = CGFloat.leastNormalMagnitude
            
            // 设置最高和最低范围
            setMaxAndMinValue()
            
            // 设置坐标范围
            setCoordsScale()
            
            // 价格横线
            let priceLineSpace = (mainHeight - styleSet.mainInset.top - styleSet.mainInset.bottom) / CGFloat(styleSet.priceLineCount - 1)
            for i in 0..<styleSet.priceLineCount {
                if styleSet.priceLocation == .left {
                    drawDashLine(context: context, startPoint: CGPoint(x: rect.minX + priceTextWidth, y: styleSet.mainInset.top + priceLineSpace * CGFloat(i)), stopPoint: CGPoint(x: rect.maxX, y: styleSet.mainInset.top + priceLineSpace * CGFloat(i)), width: styleSet.priceLineWidth, lengths: styleSet.priceLineDashLengths, color: styleSet.priceLineColor)
                } else {
                    drawDashLine(context: context, startPoint: CGPoint(x: rect.minX, y: styleSet.mainInset.top + priceLineSpace * CGFloat(i)), stopPoint: CGPoint(x: rect.maxX - priceTextWidth, y: styleSet.mainInset.top + priceLineSpace * CGFloat(i)), width: styleSet.priceLineWidth, lengths: styleSet.priceLineDashLengths, color: styleSet.priceLineColor)
                }
            }
            
            // 遍历
            for i in minIndex...maxIndex {
                let model = datas[i]
                // 转换蜡烛坐标
                let centerX: CGFloat = (styleSet.candleWidth + styleSet.candleSpace) * CGFloat(i) + styleSet.candleWidth / 2
                let lastCenterX: CGFloat = (styleSet.candleWidth + styleSet.candleSpace) * CGFloat(i - 1) + styleSet.candleWidth / 2
                let openY: CGFloat = styleSet.mainInset.top + CGFloat((mainMaxPrice - Double(model.open)!)) * priceCoordsScale
                let closeY: CGFloat = styleSet.mainInset.top + CGFloat((mainMaxPrice - Double(model.close)!)) * priceCoordsScale
                let highY: CGFloat = styleSet.mainInset.top + CGFloat((mainMaxPrice - Double(model.high)!)) * priceCoordsScale
                let lowY: CGFloat = styleSet.mainInset.top + CGFloat((mainMaxPrice - Double(model.low)!)) * priceCoordsScale
                if highY < highestPriceY {
                    highestPrice = model.high
                    highestPriceX = centerX
                    highestPriceY = highY
                }
                if lowY > lowestPriceY {
                    lowestPrice = model.low
                    lowestPriceX = centerX
                    lowestPriceY = lowY
                }
                
                // 日期文字
                if (i + 1) % styleSet.timeBetweenNumber == 0 {
                    if styleSet.timeLineWidth != 0 {
                        drawDashLine(context: context, startPoint: CGPoint(x: centerX, y: styleSet.mainInset.top), stopPoint: CGPoint(x: centerX, y: mainHeight - styleSet.mainInset.bottom), width: styleSet.timeLineWidth, lengths: styleSet.timeLineDashLengths, color: styleSet.timeLineColor)
                    }
                    let attributesText = NSMutableAttributedString.init(string: timeTransformation(model.time, type: .hour), attributes: [.foregroundColor: styleSet.timeColor, .font: styleSet.timeFont])
                    drawText(context: context, attributesText: attributesText, rect: CGRect(x: centerX - attributesText.size().width / 2, y: mainHeight - styleSet.mainInset.bottom + (styleSet.mainInset.bottom - attributesText.size().height) / 2, width: attributesText.size().width, height: attributesText.size().height))
                }
                
                // 画蜡烛
                var candleColor = styleSet.candleRiseColor
                if openY > closeY {
                    // 上涨
                    drawLine(context: context, startPoint: CGPoint(x: centerX, y: highY), stopPoint: CGPoint(x: centerX, y: lowY), width: styleSet.candleLineWidth, color: candleColor)
                    drawLine(context: context, startPoint: CGPoint(x: centerX, y: closeY), stopPoint: CGPoint(x: centerX, y: openY), width: styleSet.candleWidth, color: candleColor)
                } else if openY < closeY {
                    // 下跌
                    candleColor = styleSet.candleFallColor
                    drawLine(context: context, startPoint: CGPoint(x: centerX, y: highY), stopPoint: CGPoint(x: centerX, y: lowY), width: styleSet.candleLineWidth, color: candleColor)
                    drawLine(context: context, startPoint: CGPoint(x: centerX, y: openY), stopPoint: CGPoint(x: centerX, y: closeY), width: styleSet.candleWidth, color: candleColor)
                } else {
                    if i > 1 {
                        let lastModel = datas[i - 1]
                        if Double(lastModel.close)! > Double(model.close)! {
                            candleColor = styleSet.candleFallColor
                        }
                    }
                    drawLine(context: context, startPoint: CGPoint(x: centerX, y: highY), stopPoint: CGPoint(x: centerX, y: lowY), width: styleSet.candleLineWidth, color: candleColor)
                    drawLine(context: context, startPoint: CGPoint(x: centerX, y: openY), stopPoint: CGPoint(x: centerX, y: openY + 1), width: styleSet.candleWidth, color: candleColor)
                }
                
                // 主图指标线
                if styleSet.mainIndexType == .ma, i > 0 {
                    // MA
                    let lastModel = datas[i - 1]
                    if lastModel.ma1 ?? 0 > 0 {
                        let maY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - model.ma1!) * priceCoordsScale
                        let lastMAY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - lastModel.ma1!) * priceCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastMAY), stopPoint: CGPoint(x: centerX, y: maY), width: styleSet.mainIndexLineWidth, color: styleSet.maIndexLineColor.line1Color)
                    }
                    if lastModel.ma2 ?? 0 > 0 {
                        let maY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - model.ma2!) * priceCoordsScale
                        let lastMAY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - lastModel.ma2!) * priceCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastMAY), stopPoint: CGPoint(x: centerX, y: maY), width: styleSet.mainIndexLineWidth, color: styleSet.maIndexLineColor.line2Color)
                    }
                    if lastModel.ma3 ?? 0 > 0 {
                        let maY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - model.ma3!) * priceCoordsScale
                        let lastMAY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - lastModel.ma3!) * priceCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastMAY), stopPoint: CGPoint(x: centerX, y: maY), width: styleSet.mainIndexLineWidth, color: styleSet.maIndexLineColor.line3Color)
                    }
                } else if styleSet.mainIndexType == .boll, i > 0 {
                    // BOLL
                    let lastModel = datas[i - 1]
                    if lastModel.mb ?? 0 > 0 {
                        let mbY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - model.mb!) * priceCoordsScale
                        let lastMBY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - lastModel.mb!) * priceCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastMBY), stopPoint: CGPoint(x: centerX, y: mbY), width: styleSet.mainIndexLineWidth, color: styleSet.bollIndexLineColor.line1Color)
                    }
                    if lastModel.up ?? 0 > 0 {
                        let upY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - model.up!) * priceCoordsScale
                        let lastUPY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - lastModel.up!) * priceCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastUPY), stopPoint: CGPoint(x: centerX, y: upY), width: styleSet.mainIndexLineWidth, color: styleSet.bollIndexLineColor.line2Color)
                    }
                    if lastModel.dn ?? 0 > 0 {
                        let dnY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - model.dn!) * priceCoordsScale
                        let lastDNY: CGFloat = styleSet.mainInset.top + CGFloat(mainMaxPrice - lastModel.dn!) * priceCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastDNY), stopPoint: CGPoint(x: centerX, y: dnY), width: styleSet.mainIndexLineWidth, color: styleSet.bollIndexLineColor.line3Color)
                    }
                }
                
                // 副图
                if styleSet.isShowSecondaryView {
                    if styleSet.secondaryIndexType == .volume {
                        // 成交量
                        let volumeY: CGFloat = mainHeight + styleSet.secondaryInset.top + (CGFloat(secondaryMaxValue) - CGFloat(model.vol)) * secondaryCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: centerX, y: volumeY), stopPoint: CGPoint(x: centerX, y: rect.height - styleSet.secondaryInset.bottom), width: styleSet.candleWidth, color: candleColor)
                    } else if styleSet.secondaryIndexType == .macd {
                        // MACD
                        // 1.MACD
                        let positiveScale: CGFloat = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - model.macd!) * secondaryCoordsScale
                        let negativeScale: CGFloat = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue) * secondaryCoordsScale
                        if model.macd ?? 0 > 0 {
                            drawLine(context: context, startPoint: CGPoint(x: centerX, y: positiveScale), stopPoint: CGPoint(x: centerX, y: negativeScale), width: styleSet.candleWidth, color: styleSet.candleRiseColor)
                        } else if model.macd ?? 0 < 0 {
                            drawLine(context: context, startPoint: CGPoint(x: centerX, y: negativeScale), stopPoint: CGPoint(x: centerX, y: positiveScale), width: styleSet.candleWidth, color: styleSet.candleFallColor)
                        }
                        // 2.DIFF和DEA线
                        if i > 0 {
                            let lastModel = datas[i - 1]
                            let diffY = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - model.diff!) * secondaryCoordsScale
                            let lastDiffY = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - lastModel.diff!) * secondaryCoordsScale
                            drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastDiffY), stopPoint: CGPoint(x: centerX, y: diffY), width: styleSet.secondaryIndexLineWidth, color: styleSet.macdIndexLineColor.line1Color)
                            
                            let deaY = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - model.dea!) * secondaryCoordsScale
                            let lastDeaY = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - lastModel.dea!) * secondaryCoordsScale
                            drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastDeaY), stopPoint: CGPoint(x: centerX, y: deaY), width: styleSet.secondaryIndexLineWidth, color: styleSet.macdIndexLineColor.line2Color)
                        }
                    } else if i > 0 {
                        let lastModel = datas[i - 1]
                        let num1: Double = styleSet.secondaryIndexType == .rsi ? model.rsi1! : model.k!
                        let num2: Double = styleSet.secondaryIndexType == .rsi ? model.rsi2! : model.d!
                        let num3: Double = styleSet.secondaryIndexType == .rsi ? model.rsi3! : model.j!
                        let lastNum1: Double = styleSet.secondaryIndexType == .rsi ? lastModel.rsi1! : lastModel.k!
                        let lastNum2: Double = styleSet.secondaryIndexType == .rsi ? lastModel.rsi2! : lastModel.d!
                        let lastNum3: Double = styleSet.secondaryIndexType == .rsi ? lastModel.rsi3! : lastModel.j!
                        let line1Color = styleSet.secondaryIndexType == .rsi ? styleSet.rsiIndexLineColor.line1Color : styleSet.kdjIndexLineColor.line1Color
                        let line2Color = styleSet.secondaryIndexType == .rsi ? styleSet.rsiIndexLineColor.line2Color : styleSet.kdjIndexLineColor.line2Color
                        let line3Color = styleSet.secondaryIndexType == .rsi ? styleSet.rsiIndexLineColor.line3Color : styleSet.kdjIndexLineColor.line3Color
                        
                        let index1Y = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - num1) * secondaryCoordsScale
                        let lastIndex1Y = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - lastNum1) * secondaryCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastIndex1Y), stopPoint: CGPoint(x: centerX, y: index1Y), width: styleSet.secondaryIndexLineWidth, color: line1Color)
                        
                        let index2Y = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - num2) * secondaryCoordsScale
                        let lastIndex2Y = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - lastNum2) * secondaryCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastIndex2Y), stopPoint: CGPoint(x: centerX, y: index2Y), width: styleSet.secondaryIndexLineWidth, color: line2Color)
                        
                        let index3Y = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - num3) * secondaryCoordsScale
                        let lastIndex3Y = mainHeight + styleSet.secondaryInset.top + CGFloat(secondaryMaxValue - lastNum3) * secondaryCoordsScale
                        drawLine(context: context, startPoint: CGPoint(x: lastCenterX, y: lastIndex3Y), stopPoint: CGPoint(x: centerX, y: index3Y), width: styleSet.secondaryIndexLineWidth, color: line3Color)
                    }
                }
            }
            
            // 横线价格文字
            for i in 0..<styleSet.priceLineCount {
                let attributesText = NSMutableAttributedString.init(string: getPrice(row: i, count: styleSet.priceLineCount), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                if styleSet.priceLocation == .left {
                    drawText(context: context, attributesText: attributesText, rect: CGRect(x: rect.minX + styleSet.mainInset.left, y: styleSet.mainInset.top + priceLineSpace * CGFloat(i) - attributesText.size().height / 2, width: attributesText.size().width, height: attributesText.size().height))
                } else {
                    drawText(context: context, attributesText: attributesText, rect: CGRect(x: rect.maxX - attributesText.size().width - styleSet.mainInset.right, y: styleSet.mainInset.top + priceLineSpace * CGFloat(i) - attributesText.size().height / 2, width: attributesText.size().width, height: attributesText.size().height))
                }
            }
            
            // 副图文字
            if styleSet.isShowSecondaryView {
                var maxAttributesText: NSMutableAttributedString!
                var minAttributesText: NSMutableAttributedString!
                if styleSet.secondaryIndexType == .volume {
                    maxAttributesText = NSMutableAttributedString.init(string: String(format: "%.0f", secondaryMaxValue), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                    minAttributesText = NSMutableAttributedString.init(string: String(format: "0 %@", styleSet.secondaryVolumeName), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                } else if styleSet.secondaryIndexType == .macd {
                    maxAttributesText = NSMutableAttributedString.init(string: String(format: "%f", secondaryMaxValue), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                    minAttributesText = NSMutableAttributedString.init(string: String(format: "%f", secondaryMinValue), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                } else {
                    maxAttributesText = NSMutableAttributedString.init(string: String(format: "%.2f", secondaryMaxValue), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                    minAttributesText = NSMutableAttributedString.init(string: String(format: "%.2f", secondaryMinValue), attributes: [.foregroundColor: styleSet.priceColor, .font: styleSet.priceFont])
                }
                if styleSet.priceLocation == .left {
                    drawText(context: context, attributesText: maxAttributesText, rect: CGRect(x: rect.minX + styleSet.mainInset.left, y: mainHeight + styleSet.secondaryInset.top, width: maxAttributesText.size().width, height: maxAttributesText.size().height))
                    drawText(context: context, attributesText: minAttributesText, rect: CGRect(x: rect.minX + styleSet.mainInset.left, y: rect.height - styleSet.secondaryInset.bottom - minAttributesText.size().height, width: minAttributesText.size().width, height: minAttributesText.size().height))
                } else {
                    drawText(context: context, attributesText: maxAttributesText, rect: CGRect(x: rect.maxX - styleSet.mainInset.right - maxAttributesText.size().width, y: mainHeight + styleSet.secondaryInset.top, width: maxAttributesText.size().width, height: maxAttributesText.size().height))
                    drawText(context: context, attributesText: minAttributesText, rect: CGRect(x: rect.maxX - styleSet.mainInset.right - minAttributesText.size().width, y: rect.height - styleSet.secondaryInset.bottom - minAttributesText.size().height, width: minAttributesText.size().width, height: minAttributesText.size().height))
                }
            }
            
            // 最高低价格文字
            if styleSet.isShowHighestLowestPrice {
                // 1.最高
                var isLeftHighest: Bool
                if rect.maxX - priceTextWidth > highestPriceX {
                    isLeftHighest = true
                    highestPrice = String(format: "←%@", highestPrice)
                } else {
                    isLeftHighest = false
                    highestPrice = String(format: "%@→", highestPrice)
                }
                let highestAttributes = NSMutableAttributedString.init(string: highestPrice, attributes: [.foregroundColor: styleSet.highestLowestPriceColor, .font: styleSet.highestLowestPriceFont])
                drawText(context: context, attributesText: highestAttributes, rect: CGRect(x: highestPriceX + (isLeftHighest ? styleSet.candleWidth / 3 : -(highestAttributes.size().width + styleSet.candleWidth / 3)), y: highestPriceY - highestAttributes.size().height / 2, width: highestAttributes.size().width, height: highestAttributes.size().height))
                
                // 2.最低
                var isLeftLowest: Bool
                if rect.maxX - priceTextWidth > lowestPriceX {
                    isLeftLowest = true
                    lowestPrice = String(format: "←%@", lowestPrice)
                } else {
                    isLeftLowest = false
                    lowestPrice = String(format: "%@→", lowestPrice)
                }
                let lowestAttributes = NSMutableAttributedString.init(string: lowestPrice, attributes: [.foregroundColor: styleSet.highestLowestPriceColor, .font: styleSet.highestLowestPriceFont])
                drawText(context: context, attributesText: lowestAttributes, rect: CGRect(x: lowestPriceX + (isLeftLowest ? styleSet.candleWidth / 3 : -(lowestAttributes.size().width + styleSet.candleWidth / 3)), y: lowestPriceY - lowestAttributes.size().height / 2, width: lowestAttributes.size().width, height: lowestAttributes.size().height))
            }
        }
        
        // 回复上下文
        context.restoreGState()
    }
    
    // MARK: - 开始渲染
    
    func drawView() {
        setContentSize()
        setMaxAndMinValue()
        setCoordsScale()
        setNeedsDisplay()
    }
    
    // MARK: - 实时报价
    
    func nowQuote(price: Double, time: TimeInterval) {
        if datas.count == 0 || price == 0 || time == 0 {
            return
        }
    }
    
    // MARK: - 选中蜡烛
    
    func getSelectTime(_ index: Int) -> String {
        return timeTransformation(datas[index].time, type: .year)
    }
    
    func getSelectPrice(_ pointY: CGFloat) -> String {
        return String(format: "%.\(digits)f", mainMaxPrice - Double((pointY - styleSet.mainInset.top) / priceCoordsScale))
    }
    
    func getSelectSecondary(_ pointY: CGFloat) -> String {
        let value = secondaryMaxValue - Double((pointY - mainHeight - styleSet.secondaryInset.top) / secondaryCoordsScale)
        if styleSet.secondaryIndexType == .volume {
            return String(format: "%.0f", value)
        } else if styleSet.secondaryIndexType == .macd {
            return String(format: "%f", value)
        } else if styleSet.secondaryIndexType == .rsi || styleSet.secondaryIndexType == .kdj {
            return String(format: "%.2f", value)
        }
        return ""
    }
    
    // MARK: - 刷新
    // MARK: 开始
    
    func beginRefreshing(_ type: HGKLineChartRefreshType) {
        refreshState = .refreshing
        refreshBlock?(type)
    }
    
    // MARK: 结束
    
    func endRefreshing() {
        refreshState = .normal
    }
    
    // MARK: - 监听滚动
    
    private func scrollViewContentOffsetDidChange() {
        minIndex = Int(contentOffset.x / (styleSet.candleWidth + styleSet.candleSpace))
        maxIndex = Int((contentOffset.x + frame.width) / (styleSet.candleWidth + styleSet.candleSpace))
        if minIndex < 0 {
            minIndex = 0
        }
        if maxIndex > datas.count - 1 {
            maxIndex = datas.count - 1
        }
        setNeedsDisplay()
        
        // 左拉（重新加载)
        let rightProgress = (contentOffset.x - contentSize.width + frame.width - (styleSet.priceLocation == .left ? styleSet.mainInset.right : priceTextWidth)) / 34
        if !rightProgress.isNaN, rightProgress >= 0  {
            if isDragging {
                // 拖动中
                if refreshState == .normal, rightProgress >= 1 {
                    refreshState = .pulling
                } else if refreshState == .pulling, rightProgress < 1 {
                    refreshState = .normal
                }
            } else if refreshState == .pulling {
                // 开始刷新
                beginRefreshing(.reload)
            }
        }
        // 右拉（更多加载）
        let leftProgress = -(contentOffset.x + styleSet.mainInset.left) / 34
        if !leftProgress.isNaN, leftProgress >= 0 {
            if isDragging {
                // 拖动中
                if refreshState == .normal, leftProgress >= 1 {
                    refreshState = .pulling
                } else if refreshState == .pulling, leftProgress < 1 {
                    refreshState = .normal
                }
            } else if refreshState == .pulling {
                // 开始刷新
                beginRefreshing(.more)
            }
        }
    }
    
    // MARK: - 设置K线图宽度
    
    private func setContentSize() {
        if styleSet.isShowSecondaryView {
            mainHeight = frame.height * styleSet.mainSecondaryHeightRatio
        } else {
            mainHeight = frame.height
        }
        secondaryHeight = frame.height - mainHeight
        
        var width = styleSet.candleWidth * CGFloat(datas.count) + styleSet.candleSpace * CGFloat(datas.count - 1)
        if width <= frame.width {
            width = frame.width + 1
        }
        contentSize = CGSize(width: width, height: 0)
        if styleSet.priceLocation == .left {
            contentInset = UIEdgeInsets(top: 0, left: styleSet.mainInset.left, bottom: 0, right: styleSet.mainInset.right)
        } else {
            contentInset = UIEdgeInsets(top: 0, left: styleSet.mainInset.left, bottom: 0, right: priceTextWidth)
        }
    }
    
    // MARK: - 设置最高最低价格
    
    private func setMaxAndMinValue() {
        mainMaxPrice = .leastNormalMagnitude
        mainMinPrice = .greatestFiniteMagnitude
        secondaryMaxValue = .leastNormalMagnitude
        secondaryMinValue = .greatestFiniteMagnitude
        for i in minIndex...maxIndex {
            let model = datas[i]
            // 主图
            mainMaxPrice = max(mainMaxPrice, Double(model.high)!)
            mainMinPrice = min(mainMinPrice, Double(model.low)!)
            mainMaxPrice = max(mainMaxPrice, Double(model.close)!)
            mainMinPrice = min(mainMinPrice, Double(model.close)!)
            if styleSet.mainIndexType == .ma {
                if model.ma1 ?? 0 > 0 {
                    mainMaxPrice = max(mainMaxPrice, model.ma1!)
                    mainMinPrice = min(mainMinPrice, model.ma1!)
                }
                if model.ma2 ?? 0 > 0 {
                    mainMaxPrice = max(mainMaxPrice, model.ma2!)
                    mainMinPrice = min(mainMinPrice, model.ma2!)
                }
                if model.ma3 ?? 0 > 0 {
                    mainMaxPrice = max(mainMaxPrice, model.ma3!)
                    mainMinPrice = min(mainMinPrice, model.ma3!)
                }
            } else if styleSet.mainIndexType == .boll {
                if model.up ?? 0 > 0 {
                    mainMaxPrice = max(mainMaxPrice, model.up!)
                    mainMinPrice = min(mainMinPrice, model.up!)
                }
                if model.dn ?? 0 > 0 {
                    mainMaxPrice = max(mainMaxPrice, model.dn!)
                    mainMinPrice = min(mainMinPrice, model.dn!)
                }
            }
            // 副图
            if styleSet.secondaryIndexType == .volume {
                secondaryMaxValue = max(secondaryMaxValue, Double(model.vol))
                secondaryMinValue = 0
            } else if styleSet.secondaryIndexType == .macd {
                secondaryMaxValue = max(secondaryMaxValue, model.macd!)
                secondaryMinValue = min(secondaryMinValue, model.macd!)
                secondaryMaxValue = max(secondaryMaxValue, model.diff!)
                secondaryMinValue = min(secondaryMinValue, model.diff!)
                secondaryMaxValue = max(secondaryMaxValue, model.dea!)
                secondaryMinValue = min(secondaryMinValue, model.dea!)
            } else if styleSet.secondaryIndexType == .rsi {
                secondaryMaxValue = max(secondaryMaxValue, model.rsi1!)
                secondaryMinValue = min(secondaryMinValue, model.rsi1!)
                secondaryMaxValue = max(secondaryMaxValue, model.rsi2!)
                secondaryMinValue = min(secondaryMinValue, model.rsi2!)
                secondaryMaxValue = max(secondaryMaxValue, model.rsi3!)
                secondaryMinValue = min(secondaryMinValue, model.rsi3!)
            } else if styleSet.secondaryIndexType == .kdj {
                secondaryMaxValue = max(secondaryMaxValue, model.k!)
                secondaryMinValue = min(secondaryMinValue, model.k!)
                secondaryMaxValue = max(secondaryMaxValue, model.d!)
                secondaryMinValue = min(secondaryMinValue, model.d!)
                secondaryMaxValue = max(secondaryMaxValue, model.j!)
                secondaryMinValue = min(secondaryMinValue, model.j!)
            }
        }
        let scale = (mainMaxPrice - mainMinPrice) * 0.1
        mainMaxPrice = mainMaxPrice + scale
        mainMinPrice = mainMinPrice - scale
    }
    
    // MARK: - 设置坐标范围
    
    private func setCoordsScale() {
        priceCoordsScale = (mainHeight - styleSet.mainInset.top - styleSet.mainInset.bottom) / CGFloat((mainMaxPrice - mainMinPrice))
        secondaryCoordsScale = (secondaryHeight - styleSet.secondaryInset.top - styleSet.secondaryInset.bottom) / CGFloat(secondaryMaxValue - secondaryMinValue)
    }
    
    // MARK: - 设置价格宽度及格式
    
    private func setPriceWidthAndFormat() {
        if datas.count > 0 {
            let price = datas.first!.high as NSString
            priceTextWidth = price.size(withAttributes: [.font: styleSet.priceFont]).width + (styleSet.priceLocation == .left ? styleSet.mainInset.left : styleSet.mainInset.right) * 2
            let priceArr = price.components(separatedBy: ".")
            if priceArr.count == 2 {
                digits = priceArr[1].count
            } else {
                digits = 0
            }
        } else {
            priceTextWidth = 0
            digits = 0
        }
    }
    
    // MARK: - 获取每个横线价格
    
    private func getPrice(row: Int, count: Int) -> String {
        var price: Double
        if row == 0 {
            price = mainMaxPrice
        } else {
            price = mainMaxPrice - (mainMaxPrice - mainMinPrice) / Double(count - 1) * Double(row)
        }
        return String(format: "%.\(digits)f", price)
    }
    
    // MARK: - 计算
    
    private func setCalculate() {
        for i in 0..<datas.count {
            let model = datas[i]
            model.ma1 = getMA(i, cycle: styleSet.maIndex.parameter1)
            model.ma2 = getMA(i, cycle: styleSet.maIndex.parameter2)
            model.ma3 = getMA(i, cycle: styleSet.maIndex.parameter3)
            model.md = getMD(i, cycle: styleSet.bollIndex.parameter1)
            model.mb = getMA(i - 1, cycle: styleSet.bollIndex.parameter1)
            model.up = getUP(mb: model.mb!, md: model.md!, deviation: styleSet.bollIndex.parameter2)
            model.dn = getDN(mb: model.mb!, md: model.md!, deviation: styleSet.bollIndex.parameter2)
            model.emas = getEMAShort(i, cycle: styleSet.macdIndex.parameter1)
            model.emal = getEMALong(i, cycle: styleSet.macdIndex.parameter2)
            model.diff = getDIFF(i)
            model.dea = getDEA(i, cycle: styleSet.macdIndex.parameter3)
            model.macd = getMACD(i)
            model.rsi1 = getRSI(i, cycle: styleSet.rsiIndex.parameter1)
            model.rsi2 = getRSI(i, cycle: styleSet.rsiIndex.parameter2)
            model.rsi3 = getRSI(i, cycle: styleSet.rsiIndex.parameter3)
            model.k = getKDJForK(i, cycle: styleSet.kdjIndex.parameter1, KCycle: styleSet.kdjIndex.parameter2)
            model.d = getKDJForD(i, cycle: styleSet.kdjIndex.parameter1, DCycle: styleSet.kdjIndex.parameter3)
            model.j = getKDJForJ(i)
        }
    }
    
    // MARK: KDJ
    
    private func getKDJForJ(_ index: Int) -> Double {
        let model = datas[index]
        return 3 * model.k! - 2 * model.d!
    }
    
    private func getKDJForD(_ index: Int, cycle: Int, DCycle: Int) -> Double {
        // D
        if index == 0 {
            return 50.0
        } else {
            let lastModel = datas[index - 1]
            let model = datas[index]
            return (model.k! + Double(DCycle - 1) * lastModel.d!) / Double(DCycle)
        }
    }
    
    private func getKDJForK(_ index: Int, cycle: Int, KCycle: Int) -> Double {
        // K
        if index == 0 {
            return 50.0
        } else {
            var close: Double = 0
            var low: Double = .greatestFiniteMagnitude
            var high: Double = .leastNormalMagnitude
            for i in 0...(min(cycle - 1, index)) {
                let model = datas[index - i]
                if i == 0 {
                    close = Double(model.close)!
                }
                low = min(low, Double(model.low)!)
                high = max(high, Double(model.high)!)
            }
            let rsv = getRSV(close: close, low: low, high: high)
            let lastModel = datas[index - 1]
            return (rsv + Double(KCycle - 1) * lastModel.k!) / Double(KCycle)
        }
    }
    
    private func getRSV(close: Double, low: Double, high: Double) -> Double {
        // RSV
        return (close - low) / (high - low) * 100
    }
    
    // MARK: RSI
    
    private func getRSI(_ index: Int, cycle: Int) -> Double {
        if index == 0 {
            return 0.0
        } else {
            var rise: Double = 0
            var fall: Double = 0
            for i in 0..<(min(index, cycle)) {
                let firstModel = datas[index - i]
                let secondModel = datas[index - i - 1]
                let number = Double(firstModel.close)! - Double(secondModel.close)!
                if number >= 0 {
                    rise += number
                } else {
                    fall += number * -1
                }
            }
            return rise / (rise + fall) * 100
        }
    }
    
    // MARK: MACD
    
    private func getMACD(_ index: Int) -> Double {
        // MACD柱状图
        let model = datas[index]
        return (model.diff! - model.dea!) * 2
    }
    
    private func getDEA(_ index: Int, cycle: Int) -> Double {
        // DEA
        if index == 0 {
            return 0.0
        } else {
            let model = datas[index]
            let lastModel = datas[index - 1]
            return lastModel.dea! * Double(cycle - 1) / Double(cycle + 1) + model.diff! * 2 / Double(cycle + 1)
        }
    }
    
    private func getDIFF(_ index: Int) -> Double {
        // DIFF
        let model = datas[index]
        return model.emas! - model.emal!
    }
    
    private func getEMALong(_ index: Int, cycle: Int) -> Double {
        // EMA长期
        let model = datas[index]
        if index == 0 {
            return Double(model.close)!
        } else {
            let lastModel = datas[index - 1]
            return lastModel.emal! * Double(cycle - 1) / Double(cycle + 1) + Double(model.close)! * 2 / Double(cycle + 1)
        }
    }
    
    private func getEMAShort(_ index: Int, cycle: Int) -> Double {
        // EMA短期
        let model = datas[index]
        if index == 0 {
            return Double(model.close)!
        } else {
            let lastModel = datas[index - 1]
            return lastModel.emas! * Double(cycle - 1) / Double(cycle + 1) + Double(model.close)! * 2 / Double(cycle + 1)
        }
    }
    
    // MARK: BOLL
    
    private func getDN(mb: Double, md: Double, deviation: Int) -> Double {
        if mb > 0, md > 0 {
            return mb - md * Double(deviation)
        } else {
            return 0.0
        }
    }
    
    private func getUP(mb: Double, md: Double, deviation: Int) -> Double {
        if mb > 0, md > 0 {
            return mb + md * Double(deviation)
        } else {
            return 0.0
        }
    }
    
    private func getMD(_ index: Int, cycle: Int) -> Double {
        // 标准差
        if cycle - 1 <= index {
            var mdCount: Double = 0
            let ma: Double = getMA(index, cycle: cycle)
            for i in index - (cycle - 1)...index {
                let model = datas[i]
                mdCount += pow(Double(model.close)! - ma, 2)
            }
            return sqrt(mdCount / Double(cycle))
        } else {
            return 0.0
        }
    }
    
    // MARK: MA
    
    private func getMA(_ index: Int, cycle: Int) -> Double {
        // 均线
        if cycle - 1 <= index {
            var maCount: Double = 0
            for i in index - (cycle - 1)...index {
                maCount += Double(datas[i].close)!
            }
            return maCount / Double(cycle)
        } else {
            return 0.0
        }
    }
    
    // MARK: - 时间戳转换
    
    private func timeTransformation(_ timeStamp: TimeInterval, type: HGKLineChartTimeFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if type == .year {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        } else if type == .hour {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "MM-dd"
        }
        formatter.timeZone = NSTimeZone.local
        let date = NSDate(timeIntervalSince1970: timeStamp)
        return formatter.string(from: date as Date)
    }
    
    // MARK: - 绘画
    // MARK: 实线
    
    private func drawLine(context: CGContext, startPoint: CGPoint, stopPoint: CGPoint, width: CGFloat, color: UIColor) {
        if width == 0 {
            return
        }
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.beginPath()
        context.move(to: startPoint)
        context.addLine(to: stopPoint)
        context.setLineDash(phase: 0, lengths: [])
        context.strokePath()
    }
    
    // MARK: 虚线
    
    private func drawDashLine(context: CGContext, startPoint: CGPoint, stopPoint: CGPoint, width: CGFloat, lengths: [CGFloat], color: UIColor) {
        if width == 0 {
            return
        }
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.beginPath()
        context.move(to: startPoint)
        context.addLine(to: stopPoint)
        // 设置虚线排列的宽度间隔:[3, 1]下面的arr中的数字表示先绘制3个点再绘制1个点
        context.setLineDash(phase: 0, lengths: lengths)
        context.strokePath()
    }
    
    // MARK: 文字
    
    private func drawText(context: CGContext, attributesText: NSAttributedString, rect: CGRect) {
        attributesText.draw(in: rect)
    }
    
}
