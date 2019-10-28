//
//  SecondViewController.swift
//  Feeda
//
//  Created by Bruno Marra de Melo on 30/09/19.
//  Copyright © 2019 Bruno Marra de Melo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftCharts

class RelatoriosController: UIViewController {

    fileprivate var feedInfo: Chart?
    fileprivate var energyInfo: Chart?
    var dbReference: DatabaseReference!;
    var formatter = DateFormatter();
    
    func createFeedChart(chartPoints: Array<ChartPoint>, xValues: Array<ChartAxisValue>, y : CGFloat, text : String) -> Chart {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let date = {(str: String) -> Date in
            return self.formatter.date(from: str)!
        }
        
        func filler(_ date: Date) -> ChartAxisValueDate {
            let filler = ChartAxisValueDate(date: date, formatter: self.formatter)
            filler.hidden = true
            return filler
        }
        
        let yValues = stride(from: 0, through: 2000, by: 200).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Data e Hora", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: text, settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds, y: y)
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        chartSettings.trailing = 80

        // Set a fixed (horizontal) scrollable area 2x than the original width, with zooming disabled.
        chartSettings.zoomPan.maxZoomX = 2
        chartSettings.zoomPan.minZoomX = 2
        chartSettings.zoomPan.minZoomY = 1
        chartSettings.zoomPan.maxZoomY = 1
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, lineWidth: 2, animDuration: 1, animDelay: 0)

        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], delayInit: true)
        
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: 0.3)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer]
        )
        
        view.addSubview(chart.view)
        
        chartPointsLineLayer.initScreenLines(chart)
        
        return chart
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dbReference = Database.database().reference()
        
        formatter.dateFormat = "dd/MM/yyyy HH"
        loadData()
    }
    
    func createChartPoint(dateStr: String, percent: Double, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartPoint {
        return ChartPoint(x: createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter), y: ChartAxisValuePercent(percent))
    }
    
    func createDateAxisValue(_ dateStr: String, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartAxisValue {
        let date = readFormatter.date(from: dateStr)!
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, rotation: 45, rotationKeep: .top)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    class ChartAxisValuePercent: ChartAxisValueDouble {
        override var description: String {
            return "\(formatter.string(from: NSNumber(value: scalar))!)"
        }
    }
    
    func generateXValues() -> [ChartAxisValue] {
        var xValues = [ChartAxisValue]();
        var i = 10
        while i <= 18 {
            let date = "28/10/2019 " + String(i);
            
            let x = self.createDateAxisValue(date, readFormatter: self.formatter, displayFormatter: self.formatter)
            xValues.append(x)
            i = i + 1
        }
        return xValues;
    }
    
    @IBAction func refreshData(_ sender: Any) {
        self.energyInfo?.clearView()
        self.feedInfo?.clearView()
        self.viewDidLoad();
    }
    
    func loadData() {
        print("Carregando dados...");
        self.dbReference.child("alimentou").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print("Registros recuperados: ");
            let keys = value?.allKeys;
            
            var feedPoints = [ChartPoint]();
            var energyPoints = [ChartPoint]();
            let xValues = self.generateXValues();
            let acumulatedFeed : NSMutableDictionary? = value?.mutableCopy() as? NSMutableDictionary
            let acumulatedEnergy : NSMutableDictionary? = value?.mutableCopy() as? NSMutableDictionary
            
            for key in keys! {
                let feedId = key as! String
                let feedData = value?.value(forKey: feedId) as! NSDictionary
                let date = feedData.value(forKey: "date") as! String
              
                let sCalories = feedData.value(forKey: "calories") as! NSNumber;
                let calories = sCalories.doubleValue
                let sConsumption = feedData.value(forKey: "energyConsumption") as! NSNumber;
                let consumption = sConsumption.doubleValue
                
                if(acumulatedFeed?.value(forKey: date) != nil) {
                    var previousFeed = acumulatedFeed?.value(forKey: date) as! Double
                    var previousEnergy = acumulatedEnergy?.value(forKey: date) as! Double

                    previousFeed += calories
                    previousEnergy += consumption
                    
                    acumulatedFeed?.setValue(previousFeed, forKey: date)
                    acumulatedEnergy?.setValue(previousEnergy, forKey: date)
                } else {
                    acumulatedFeed?.setValue(calories, forKey: date)
                    acumulatedEnergy?.setValue(consumption, forKey: date)
                }
                
                acumulatedFeed?.removeObject(forKey: feedId)
                acumulatedEnergy?.removeObject(forKey: feedId)
            }
            
            var dates = acumulatedFeed?.allKeys as! [String]
            dates.sort(by: { $0 < $1 })
            
            for date in dates {
                let feed = self.createChartPoint(dateStr: date , percent: acumulatedFeed?.value(forKey: date ) as! Double, readFormatter: self.formatter, displayFormatter: self.formatter)
                let energy = self.createChartPoint(dateStr: date , percent: acumulatedEnergy?.value(forKey: date ) as! Double, readFormatter: self.formatter, displayFormatter: self.formatter)
                
                feedPoints.append(feed);
                energyPoints.append(energy);
            }
            
            self.feedInfo = self.createFeedChart(chartPoints: feedPoints, xValues: xValues, y: 70, text: "Quantidade ingerida (Kcal)");
            self.energyInfo = self.createFeedChart(chartPoints: energyPoints, xValues: xValues, y: 320, text: "Consumo Energético (mAh)");
        }
    }
}

