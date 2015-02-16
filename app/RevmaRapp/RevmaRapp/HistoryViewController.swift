//
//  HistoryViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 14/01/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, CPTScatterPlotDataSource {
    
    @IBOutlet var graphView: CPTGraphHostingView!
    
    var managedObjectContext : NSManagedObjectContext?;
    
    var activities:[ActivityItem] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

        fetchActivities()
        setupGraph()
    }
    
    func fetchActivities() {
        // Probably need to page this by date at some point as well, for now get me everything
        let fetchRequest = NSFetchRequest(entityName: ActivityItem.entityName())
        var error: NSError?
        if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) {
            activities = results as [ActivityItem]
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }
    
    func setupGraph() {
        // create graph
        let graph = CPTXYGraph(frame: CGRectZero)
        let plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace
        let xRange = plotSpace.xRange.mutableCopy() as CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as CPTMutablePlotRange
        
        xRange.location = -0.6
        xRange.length = 1.2
        yRange.location = -0.6
        yRange.length = 1.2
        
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange
      
        let plot = CPTScatterPlot(frame: CGRectZero)
        
        let axisTitleTextStyle = CPTMutableTextStyle()
        axisTitleTextStyle.fontName = "Helvetica-Bold"
        axisTitleTextStyle.fontSize = 13.0
        
        let axisSet = graph.axisSet as CPTXYAxisSet
        let x = axisSet.xAxis
        x.separateLayers = false
        x.title = NSLocalizedString("duty_max_label", comment: "duty")
        x.titleTextStyle = axisTitleTextStyle
        x.titleOffset = 5
        x.titleLocation = 0.5
        
        let x2 = CPTXYAxis(frame: CGRectZero)
        x2.coordinate = CPTCoordinate.X
        x2.plotSpace = plotSpace
        x2.separateLayers = true
        x2.labelingPolicy = CPTAxisLabelingPolicy.None
        x2.title = NSLocalizedString("duty_min_label", comment: "duty")
        x2.titleTextStyle = axisTitleTextStyle
        x2.titleOffset = 5
        x2.titleLocation = -0.5
        
        let y = axisSet.yAxis
        y.title = NSLocalizedString("meaning_max_label", comment: "importance")
        y.separateLayers = false
        y.titleTextStyle = axisTitleTextStyle
        y.titleOffset = 5
        y.titleLocation = 0.5
        
        let y2 = CPTXYAxis(frame: CGRectZero)
        y2.coordinate = CPTCoordinate.Y
        y2.plotSpace = plotSpace
        y2.separateLayers = true
        y2.labelingPolicy = CPTAxisLabelingPolicy.None
        y2.title = NSLocalizedString("meaning_min_label", comment: "importance")
        y2.titleTextStyle = axisTitleTextStyle
        y2.titleOffset = 5
        y2.titleLocation = -0.5
        
        graph.axisSet.axes = [x, x2, y, y2]
        
        plot.dataLineStyle = nil
        plot.dataSource = self
        graph.addPlot(plot)
        
        self.graphView.hostedGraph = graph
    }

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(activities.count)
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        let CPTScatterPlotFieldX: UInt = 0 // Conversion to enums doesn't seem to work :-/
        let activity = activities[Int(bitPattern: idx)];
        return (fieldEnum == CPTScatterPlotFieldX) ? activity.duty!.doubleValue - 0.5 : activity.importance!.doubleValue - 0.5
    }
    
    func inSectionOne(activity: ActivityItem) -> Bool {
        return activity.duty!.doubleValue - 0.5 > 0 && activity.importance!.doubleValue - 0.5 > 0
    }
    
    func inSectionThree(activity: ActivityItem) -> Bool {
        return activity.duty!.doubleValue - 0.5 < 0 && activity.importance!.doubleValue - 0.5 < 0
    }

    func rgbComponetsFor(hue: Int, saturation: Double, lightness: Double) -> [CGFloat] {
        let bar = fabs(2.0 * lightness - 1.0)
        let C = (1.0 - bar) * saturation
        let foo = abs(hue / 60 % 2 - 1)
        let X = C * (1.0 - Double(foo))
        let m = lightness - C / 2

        let mPrime = CGFloat(m)
        let CPrime = CGFloat(C) + mPrime
        let XPrime = CGFloat(X) + mPrime

        
        var retValues: [CGFloat] = [0.0, 0.0, 0.0]
        switch hue {
        case 0...59:
            retValues[0] = CPrime
            retValues[1] = XPrime
            retValues[2] = mPrime
        case 60...119:
            retValues[0] = XPrime
            retValues[1] = CPrime
            retValues[2] = mPrime
        case 120...179:
            retValues[0] = mPrime
            retValues[1] = CPrime
            retValues[2] = XPrime
        case 180...239:
            retValues[0] = mPrime
            retValues[1] = XPrime
            retValues[2] = CPrime
        case 240...299:
            retValues[0] = XPrime
            retValues[1] = mPrime
            retValues[2] = CPrime
        case 300...359:
            retValues[0] = CPrime
            retValues[1] = mPrime
            retValues[2] = XPrime
        default:
            retValues[0] = 0.0
            retValues[1] = 0.0
            retValues[2] = 0.0
        }
        return retValues
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        let activity = activities[Int(bitPattern: idx)]
        let energyValue = 1.0 - CGFloat(activity.energy!.doubleValue)
        let symbol = CPTPlotSymbol.ellipsePlotSymbol()
        let baseRadius = 5 * symbol.size.width
        symbol.size = (CGSizeMake(baseRadius * energyValue, baseRadius * energyValue))
        
        let inSect1 = inSectionOne(activity)
        let inSect3 = inSectionThree(activity)
        let inOther = !inSect1 && !inSect3
        
        var components: [CGFloat] = [0.55, 0.55, 0.55]

        // Find color based on the section. Section I: shades of green. Section III: shades of red. Others: something else?
        // Green Hue: 90 degrees, Saturation 100%, Lightness 25–75%
        // Red Hue: 0 degrees, Saturation 100%, Lightness 30–80%
        
        if inSect1 || inSect3 {
            let redBase = 0.20
            let greenBase = 0.25
            let distanceBase = inSect1 ? greenBase : redBase
            let dutySquared = (activity.duty!.doubleValue - 0.5) * (activity.duty!.doubleValue - 0.5)
            let importanceSquared = (activity.importance!.doubleValue - 0.5) * (activity.importance!.doubleValue - 0.5)
            let activityDistance = sqrt(dutySquared + importanceSquared)
            components = rgbComponetsFor(inSect1 ? 120 : 0, saturation: 1.0, lightness: 1 - distanceBase - activityDistance)
            let symbolColor = CPTColor(componentRed: components[0],
                green: components[1],
                blue: components[2], alpha: 1.0)
            symbol.lineStyle = nil
            symbol.fill = CPTFill(color:symbolColor)
        } else {
            let grayLineStyle = symbol.lineStyle.mutableCopy() as CPTMutableLineStyle
            grayLineStyle.lineColor = CPTColor.grayColor()
            symbol.lineStyle = grayLineStyle
        }
        
        
        return symbol
    }
}