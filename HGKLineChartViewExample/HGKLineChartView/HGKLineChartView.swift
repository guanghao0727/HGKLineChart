//
//  HGKLineChartView.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/24.
//

import UIKit

typealias HGKLineChartBlock = (HGKLineChartRefreshType) -> ()

@objc protocol HGKLineChartViewDelegate {
    
}

class HGKLineChartView: UIView {
    
    private let scrollView = HGKLineChartScrollView()
    private let leftActivityView = UIActivityIndicatorView.init(style: .gray)
    private let rightActivityView = UIActivityIndicatorView.init(style: .gray)
    private let selectHorizontalView = UIView()
    private let selectVerticalView = UIView()
    private let selectPriceLabel = UILabel()
    private let selectTimeLabel = UILabel()
    
    private var selectCandlePoint: CGPoint!
    private var selectCandleMovePoint: CGPoint!
    private var pinchCandleScale: CGFloat!
    private var pinchCandleLastScale: CGFloat!
    
    private var leftActivityLeftConstraint: NSLayoutConstraint!
    private var leftActivityCenterYConstraint: NSLayoutConstraint!
    private var rightActivityLeftConstraint: NSLayoutConstraint!
    private var selectHorizontalHeightConstraint: NSLayoutConstraint!
    private var selectHorizontalCenterYConstraint: NSLayoutConstraint!
    private var selectHorizontalLeftConstraint: NSLayoutConstraint!
    private var selectHorizontalRightConstraint: NSLayoutConstraint!
    private var selectVerticalWidthConstraint: NSLayoutConstraint!
    private var selectVerticalCenterXConstraint: NSLayoutConstraint!
    private var selectVerticalTopConstraint: NSLayoutConstraint!
    private var selectVerticalBottomConstraint: NSLayoutConstraint!
    private var selectPriceWidthConstraint: NSLayoutConstraint!
    private var selectPriceLeftConstraint: NSLayoutConstraint!
    private var selectPriceRightConstraint: NSLayoutConstraint!
    private var selectTimeTopConstraint: NSLayoutConstraint!
    private var selectTimeBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: HGKLineChartViewDelegate?
    var datas: [HGKLineChartModel] = [] {
        didSet {
            scrollView.datas = datas
        }
    }
    var styleSet = HGKLineChartStyleSet() {
        didSet {
            drawView()
        }
    }
    var refreshBlock: HGKLineChartBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // K线图
        scrollView.styleSet = styleSet
        scrollView.refreshBlock = { type in
            if type == .reload {
                self.rightActivityLeftConstraint.constant = -(self.scrollView.contentInset.right + 8)
                self.rightActivityView.color = self.styleSet.loadingAnimateColor
                self.rightActivityView.startAnimating()
            } else if type == .more {
                self.leftActivityCenterYConstraint.constant = ((self.styleSet.mainInset.top - self.styleSet.mainInset.bottom) + (self.styleSet.isShowSecondaryView ? -self.frame.height * (1 - self.styleSet.mainSecondaryHeightRatio) : 0)) / 2
                self.leftActivityLeftConstraint.constant = (self.styleSet.priceLocation == .left ? self.scrollView.priceTextWidth : self.scrollView.contentInset.left) + 8
                self.leftActivityView.color = self.styleSet.loadingAnimateColor
                self.leftActivityView.startAnimating()
            }
            self.refreshBlock?(type)
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        // 加载动画
        leftActivityView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftActivityView)
        
        leftActivityLeftConstraint = leftActivityView.leftAnchor.constraint(equalTo: leftAnchor)
        leftActivityLeftConstraint.isActive = true
        leftActivityCenterYConstraint = leftActivityView.centerYAnchor.constraint(equalTo: centerYAnchor)
        leftActivityCenterYConstraint.isActive = true
        
        rightActivityView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightActivityView)
        
        rightActivityLeftConstraint = rightActivityView.rightAnchor.constraint(equalTo: rightAnchor)
        rightActivityLeftConstraint.isActive = true
        rightActivityView.centerYAnchor.constraint(equalTo: leftActivityView.centerYAnchor).isActive = true
        
        // 选中十字线
        selectHorizontalView.isHidden = true
        selectHorizontalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectHorizontalView)
        
        selectHorizontalHeightConstraint = selectHorizontalView.heightAnchor.constraint(equalToConstant: 0)
        selectHorizontalHeightConstraint.isActive = true
        selectHorizontalCenterYConstraint = selectHorizontalView.topAnchor.constraint(equalTo: topAnchor)
        selectHorizontalCenterYConstraint.isActive = true
        selectHorizontalLeftConstraint = selectHorizontalView.leftAnchor.constraint(equalTo: leftAnchor)
        selectHorizontalLeftConstraint.isActive = true
        selectHorizontalRightConstraint = selectHorizontalView.rightAnchor.constraint(equalTo: rightAnchor)
        selectHorizontalRightConstraint.isActive = true
        
        selectVerticalView.isHidden = true
        selectVerticalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectVerticalView)
        
        selectVerticalWidthConstraint = selectVerticalView.widthAnchor.constraint(equalToConstant: 0)
        selectVerticalWidthConstraint.isActive = true
        selectVerticalCenterXConstraint = selectVerticalView.centerXAnchor.constraint(equalTo: leftAnchor)
        selectVerticalCenterXConstraint.isActive = true
        selectVerticalTopConstraint = selectVerticalView.topAnchor.constraint(equalTo: topAnchor)
        selectVerticalTopConstraint.isActive = true
        selectVerticalBottomConstraint = selectVerticalView.bottomAnchor.constraint(equalTo: bottomAnchor)
        selectVerticalBottomConstraint.isActive = true
        
        selectTimeLabel.isHidden = true
        selectTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectTimeLabel)
        
        let selectTimeCenterXConstraint = selectTimeLabel.centerXAnchor.constraint(equalTo: selectVerticalView.centerXAnchor)
        selectTimeCenterXConstraint.priority = .defaultHigh
        selectTimeCenterXConstraint.isActive = true
        selectTimeLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
        selectTimeLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        selectTimeTopConstraint = selectTimeLabel.bottomAnchor.constraint(equalTo: selectVerticalView.topAnchor)
        selectTimeBottomConstraint = selectTimeLabel.topAnchor.constraint(equalTo: selectVerticalView.bottomAnchor)
        
        selectPriceLabel.textAlignment = .center
        selectPriceLabel.isHidden = true
        selectPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectPriceLabel)
        
        selectPriceLabel.centerYAnchor.constraint(equalTo: selectHorizontalView.centerYAnchor).isActive = true
        selectPriceWidthConstraint = selectPriceLabel.widthAnchor.constraint(equalToConstant: 0)
        selectPriceWidthConstraint.isActive = true
        selectPriceLeftConstraint = selectPriceLabel.leftAnchor.constraint(equalTo: leftAnchor)
        selectPriceRightConstraint = selectPriceLabel.rightAnchor.constraint(equalTo: rightAnchor)
        
        // 添加手势
        // 1.长按
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressAction(_:)))
        addGestureRecognizer(longPress)
        
        // 2.拖动
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanAction(_:)))
        addGestureRecognizer(pan)
        
        // 3.点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapPressAction(_:)))
        addGestureRecognizer(tap)
        
        // 4.缩放
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchAction(_:)))
        addGestureRecognizer(pinch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawView() {
        scrollView.drawView()
        if !scrollView.isScrollEnabled {
            setSelectCandlePoint(selectCandlePoint, animate: false)
        }
    }
    
    // MARK: - 刷新
    // MARK: 开始
    
    func beginRefreshing() {
        scrollView.beginRefreshing(.reload)
    }
    
    func beginRefreshing(_ type: HGKLineChartRefreshType) {
        scrollView.beginRefreshing(type)
    }
    
    // MARK: 结束
    
    func endRefreshing() {
        scrollView.endRefreshing()
        leftActivityView.stopAnimating()
        rightActivityView.stopAnimating()
    }
    
    // MARK: - 手势
    // MARK: 缩放
    
    @objc private func handlePinchAction(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if scrollView.isScrollEnabled {
            if gestureRecognizer.state == .began {
                pinchCandleScale = (scrollView.contentOffset.x + frame.width / 2) / scrollView.contentSize.width
                pinchCandleLastScale = 1
            } else if gestureRecognizer.state == .changed {
                if pinchCandleLastScale - gestureRecognizer.scale < 0 {
                    // 放大
                    styleSet.candleWidth = styleSet.candleWidth * 1.02
                } else {
                    // 缩小
                    styleSet.candleWidth = styleSet.candleWidth * 0.98
                }
                if styleSet.candleWidth < styleSet.candleMinWidth {
                    styleSet.candleWidth = styleSet.candleMinWidth
                } else if styleSet.candleWidth > styleSet.candleMaxWidth {
                    styleSet.candleWidth = styleSet.candleMaxWidth
                }
                scrollView.drawView()
                pinchCandleLastScale = gestureRecognizer.scale
                if scrollView.contentSize.width * pinchCandleScale - frame.width / 2 >= scrollView.contentSize.width - frame.width {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - frame.width + scrollView.contentInset.right, y: 0), animated: false)
                } else if scrollView.contentSize.width * pinchCandleScale - frame.width / 2 <= 0 {
                    scrollView.setContentOffset(CGPoint(x: -scrollView.contentInset.left, y: 0), animated: false)
                } else {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width * pinchCandleScale - frame.width / 2, y: 0), animated: false)
                }
            }
        }
    }
    
    // MARK: 点击
    
    @objc private func handleTapPressAction(_ gestureRecognizer: UITapGestureRecognizer) {
        if !scrollView.isScrollEnabled {
            setCancelSelectCandle()
        }
    }
    
    // MARK: 拖动
    
    @objc private func handlePanAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        if scrollView.isScrollEnabled || scrollView.refreshState == .refreshing {
            return
        }
        
        let point = gestureRecognizer.translation(in: self)
        if gestureRecognizer.state == .began {
            selectCandleMovePoint = CGPoint(x: point.x - selectCandlePoint.x, y: point.y - selectCandlePoint.y)
        } else if gestureRecognizer.state == .changed {
            setSelectCandlePoint(CGPoint(x: point.x - selectCandleMovePoint.x, y: point.y - selectCandleMovePoint.y), animate: true)
        }
    }
    
    // MARK: 长按
    
    @objc private func handleLongPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if datas.count == 0 || scrollView.refreshState == .refreshing {
            return
        }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            var animate = true
            if scrollView.isScrollEnabled {
                animate = false
                scrollView.isScrollEnabled = false
                selectHorizontalView.backgroundColor = styleSet.selectCandleLineColor
                selectHorizontalView.isHidden = false
                selectVerticalView.backgroundColor = styleSet.selectCandleLineColor
                selectVerticalView.isHidden = false
                selectPriceLabel.backgroundColor = styleSet.selectCandleBackgroundColor
                selectPriceLabel.textColor = styleSet.selectCandleTextColor
                selectPriceLabel.font = styleSet.selectCandleFont
                selectPriceLabel.isHidden = false
                selectTimeLabel.backgroundColor = selectPriceLabel.backgroundColor
                selectTimeLabel.textColor = selectPriceLabel.textColor
                selectTimeLabel.font = selectPriceLabel.font
                selectTimeLabel.isHidden = false
                
                selectHorizontalHeightConstraint.constant = styleSet.selectCandleLineWidth
                selectHorizontalLeftConstraint.constant = styleSet.priceLocation == .left ? scrollView.contentInset.left : 0
                selectHorizontalRightConstraint.constant = styleSet.priceLocation == .left ? 0 : -scrollView.contentInset.right
                selectVerticalWidthConstraint.constant = styleSet.selectCandleLineWidth
                selectPriceWidthConstraint.constant = styleSet.priceLocation == .left ? scrollView.priceTextWidth : scrollView.contentInset.right
                selectPriceLeftConstraint.isActive = styleSet.priceLocation == .left
                selectPriceRightConstraint.isActive = styleSet.priceLocation == .right
                selectTimeTopConstraint.isActive = styleSet.selectCandleTimeLocation == .top
                selectTimeBottomConstraint.isActive = styleSet.selectCandleTimeLocation == .bottom
            }
            setSelectCandlePoint(gestureRecognizer.location(in: self), animate: animate)
        }
    }
    
    // MARK: - 十字线
    // MARK: 移动
    
    private func setSelectCandlePoint(_ point: CGPoint, animate: Bool) {
        var selectCandleIndex = Int(floor((scrollView.contentOffset.x + point.x) / (styleSet.candleWidth + styleSet.candleSpace)))
        
        // 限制选中Index
        selectCandleIndex = max(selectCandleIndex, scrollView.minIndex)
        selectCandleIndex = min(selectCandleIndex, scrollView.maxIndex)
        
        // 限制选中坐标
        let mainViewH = frame.height * styleSet.mainSecondaryHeightRatio
        selectCandlePoint = point
        selectCandlePoint.x = styleSet.candleWidth / 2 + CGFloat(selectCandleIndex) * (styleSet.candleWidth + styleSet.candleSpace) - scrollView.contentOffset.x
        if point.y < styleSet.mainInset.top {
            selectCandlePoint.y = styleSet.mainInset.top
        } else {
            if styleSet.isShowSecondaryView {
                if point.y > mainViewH - styleSet.mainInset.bottom, point.y <= mainViewH - (styleSet.mainInset.bottom + styleSet.secondaryInset.bottom) / 2 {
                    selectCandlePoint.y = mainViewH - styleSet.mainInset.bottom
                } else if point.y > mainViewH - (styleSet.mainInset.bottom + styleSet.secondaryInset.bottom) / 2, point.y < mainViewH + styleSet.secondaryInset.top {
                    selectCandlePoint.y = mainViewH + styleSet.secondaryInset.top
                } else if point.y > frame.height - styleSet.secondaryInset.bottom {
                    selectCandlePoint.y = frame.height - styleSet.secondaryInset.bottom
                }
            } else {
                if point.y > frame.height - styleSet.mainInset.bottom {
                    selectCandlePoint.y = frame.height - styleSet.mainInset.bottom
                }
            }
        }
        
        // 文字
        if !styleSet.isShowSecondaryView || (styleSet.isShowSecondaryView && selectCandlePoint.y <= mainViewH - styleSet.mainInset.bottom) {
            // 主图
            selectPriceLabel.text = scrollView.getSelectPrice(selectCandlePoint.y)
        } else if styleSet.isShowSecondaryView {
            // 副图
            selectPriceLabel.text = scrollView.getSelectSecondary(selectCandlePoint.y)
        }
        selectTimeLabel.text = scrollView.getSelectTime(selectCandleIndex)
        
        // 移动
        selectHorizontalCenterYConstraint.constant = selectCandlePoint.y
        selectVerticalCenterXConstraint.constant = selectCandlePoint.x
        selectVerticalTopConstraint.constant = styleSet.mainInset.top
        selectVerticalBottomConstraint.constant = -(styleSet.isShowSecondaryView ? styleSet.secondaryInset.bottom : styleSet.mainInset.bottom)
        if animate {
            UIView.animate(withDuration: 0.15) {
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: 取消
    
    private func setCancelSelectCandle() {
        scrollView.isScrollEnabled = true
        selectHorizontalView.isHidden = true
        selectVerticalView.isHidden = true
        selectPriceLabel.isHidden = true
        selectTimeLabel.isHidden = true
    }
    
}
