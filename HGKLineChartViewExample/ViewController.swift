//
//  ViewController.swift
//  HGKLineChartViewExample
//
//  Created by Developer on 2021/5/24.
//

import UIKit

class ViewController: UIViewController, HGKLineChartViewDelegate {
    
    private let KLineChartView = HGKLineChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        KLineChartView.styleSet.mainInset.top = 25
        KLineChartView.styleSet.loadingAnimateColor = .blue
        KLineChartView.delegate = self
        KLineChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(KLineChartView)
        
        KLineChartView.refreshBlock = { type in
            self.getData(type)
        }
        
        view.addConstraint(NSLayoutConstraint(item: KLineChartView, attribute: .height, relatedBy: .equal, toItem: KLineChartView, attribute: .width, multiplier: 0.7, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: KLineChartView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: KLineChartView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: KLineChartView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
        
        let showBelowBtn = UIButton(type: .custom)
        showBelowBtn.setTitle("显示副图", for: .normal)
        showBelowBtn.setTitle("隐藏副图", for: .selected)
        showBelowBtn.setTitleColor(.black, for: .normal)
        showBelowBtn.titleLabel!.font = .systemFont(ofSize: 16)
        showBelowBtn.translatesAutoresizingMaskIntoConstraints = false
        showBelowBtn.addTarget(self, action: #selector(showBelowBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(showBelowBtn)
        
        showBelowBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        showBelowBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        showBelowBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        showBelowBtn.topAnchor.constraint(equalTo: KLineChartView.bottomAnchor, constant: 10).isActive = true
        
        let maIndexBtn = UIButton(type: .custom)
        maIndexBtn.setTitle("MA", for: .normal)
        maIndexBtn.setTitleColor(.black, for: .normal)
        maIndexBtn.titleLabel!.font = .systemFont(ofSize: 16)
        maIndexBtn.translatesAutoresizingMaskIntoConstraints = false
        maIndexBtn.tag = 101
        maIndexBtn.addTarget(self, action: #selector(indexBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(maIndexBtn)
        
        let bollIndexBtn = UIButton(type: .custom)
        bollIndexBtn.setTitle("BOLL", for: .normal)
        bollIndexBtn.setTitleColor(.black, for: .normal)
        bollIndexBtn.titleLabel!.font = .systemFont(ofSize: 16)
        bollIndexBtn.translatesAutoresizingMaskIntoConstraints = false
        bollIndexBtn.tag = 102
        bollIndexBtn.addTarget(self, action: #selector(indexBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(bollIndexBtn)
        
        maIndexBtn.widthAnchor.constraint(equalTo: bollIndexBtn.widthAnchor).isActive = true
        maIndexBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        maIndexBtn.topAnchor.constraint(equalTo: showBelowBtn.bottomAnchor).isActive = true
        maIndexBtn.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        bollIndexBtn.widthAnchor.constraint(equalTo: maIndexBtn.widthAnchor).isActive = true
        bollIndexBtn.heightAnchor.constraint(equalTo: maIndexBtn.heightAnchor).isActive = true
        bollIndexBtn.topAnchor.constraint(equalTo: maIndexBtn.topAnchor).isActive = true
        bollIndexBtn.leftAnchor.constraint(equalTo: maIndexBtn.rightAnchor).isActive = true
        bollIndexBtn.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        let volumeIndexBtn = UIButton(type: .custom)
        volumeIndexBtn.setTitle("Volume", for: .normal)
        volumeIndexBtn.setTitleColor(.black, for: .normal)
        volumeIndexBtn.titleLabel!.font = .systemFont(ofSize: 16)
        volumeIndexBtn.translatesAutoresizingMaskIntoConstraints = false
        volumeIndexBtn.tag = 103
        volumeIndexBtn.addTarget(self, action: #selector(indexBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(volumeIndexBtn)
        
        let macdIndexBtn = UIButton(type: .custom)
        macdIndexBtn.setTitle("MACD", for: .normal)
        macdIndexBtn.setTitleColor(.black, for: .normal)
        macdIndexBtn.titleLabel!.font = .systemFont(ofSize: 16)
        macdIndexBtn.translatesAutoresizingMaskIntoConstraints = false
        macdIndexBtn.tag = 104
        macdIndexBtn.addTarget(self, action: #selector(indexBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(macdIndexBtn)
        
        let rsiIndexBtn = UIButton(type: .custom)
        rsiIndexBtn.setTitle("RSI", for: .normal)
        rsiIndexBtn.setTitleColor(.black, for: .normal)
        rsiIndexBtn.titleLabel!.font = .systemFont(ofSize: 16)
        rsiIndexBtn.translatesAutoresizingMaskIntoConstraints = false
        rsiIndexBtn.tag = 105
        rsiIndexBtn.addTarget(self, action: #selector(indexBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(rsiIndexBtn)
        
        let kdjIndexBtn = UIButton(type: .custom)
        kdjIndexBtn.setTitle("KDJ", for: .normal)
        kdjIndexBtn.setTitleColor(.black, for: .normal)
        kdjIndexBtn.titleLabel!.font = .systemFont(ofSize: 16)
        kdjIndexBtn.translatesAutoresizingMaskIntoConstraints = false
        kdjIndexBtn.tag = 106
        kdjIndexBtn.addTarget(self, action: #selector(indexBtnClick(sender:)), for: .touchUpInside)
        view.addSubview(kdjIndexBtn)
        
        volumeIndexBtn.widthAnchor.constraint(equalTo: macdIndexBtn.widthAnchor).isActive = true
        volumeIndexBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        volumeIndexBtn.topAnchor.constraint(equalTo: maIndexBtn.bottomAnchor).isActive = true
        volumeIndexBtn.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        macdIndexBtn.widthAnchor.constraint(equalTo: rsiIndexBtn.widthAnchor).isActive = true
        macdIndexBtn.heightAnchor.constraint(equalTo: volumeIndexBtn.heightAnchor).isActive = true
        macdIndexBtn.topAnchor.constraint(equalTo: volumeIndexBtn.topAnchor).isActive = true
        macdIndexBtn.leftAnchor.constraint(equalTo: volumeIndexBtn.rightAnchor).isActive = true
        
        rsiIndexBtn.widthAnchor.constraint(equalTo: kdjIndexBtn.widthAnchor).isActive = true
        rsiIndexBtn.heightAnchor.constraint(equalTo: volumeIndexBtn.heightAnchor).isActive = true
        rsiIndexBtn.topAnchor.constraint(equalTo: macdIndexBtn.topAnchor).isActive = true
        rsiIndexBtn.leftAnchor.constraint(equalTo: macdIndexBtn.rightAnchor).isActive = true
        
        kdjIndexBtn.widthAnchor.constraint(equalTo: macdIndexBtn.widthAnchor).isActive = true
        kdjIndexBtn.heightAnchor.constraint(equalTo: volumeIndexBtn.heightAnchor).isActive = true
        kdjIndexBtn.topAnchor.constraint(equalTo: macdIndexBtn.topAnchor).isActive = true
        kdjIndexBtn.leftAnchor.constraint(equalTo: rsiIndexBtn.rightAnchor).isActive = true
        kdjIndexBtn.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // get data
        KLineChartView.beginRefreshing()
    }
    
    @objc func showBelowBtnClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        KLineChartView.styleSet.isShowSecondaryView = sender.isSelected
        KLineChartView.drawView()
    }
    
    @objc func indexBtnClick(sender: UIButton) {
        if sender.tag == 101 {
            KLineChartView.styleSet.mainIndexType = KLineChartView.styleSet.mainIndexType == .ma ? .not : .ma
        } else if sender.tag == 102 {
            KLineChartView.styleSet.mainIndexType = KLineChartView.styleSet.mainIndexType == .boll ? .not : .boll
        } else if sender.tag == 103 {
            KLineChartView.styleSet.secondaryIndexType = .volume
        } else if sender.tag == 104 {
            KLineChartView.styleSet.secondaryIndexType = .macd
        } else if sender.tag == 105 {
            KLineChartView.styleSet.secondaryIndexType = .rsi
        } else if sender.tag == 106 {
            KLineChartView.styleSet.secondaryIndexType = .kdj
        }
        KLineChartView.drawView()
    }
    
    private func getData(_ type: HGKLineChartRefreshType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json") {
                do {
                    self.KLineChartView.endRefreshing()
                    let data = try Data(contentsOf: jsonUrl)
                    let jsonData = try JSONDecoder().decode(HttpModel.self, from: data)
                    if jsonData.isSuccess == 1 {
                        if type == .reload {
                            self.KLineChartView.datas = (jsonData.data?.records)!
                        } else {
                            self.KLineChartView.datas.append(contentsOf: (jsonData.data?.records)!)
                        }
                    }
                } catch let error as Error? {
                    self.KLineChartView.endRefreshing()
                    print("\(String(describing: error))")
                }
            }
        }
    }

}

