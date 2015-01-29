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
        
        
        println("default title \(x.titleLocation), \(y.titleLocation)" )
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
//        println("Field index: \(fieldEnum) energy: \(activity.energy!) importance: \(activity.importance!) duty: \(activity.duty!)")
        return (fieldEnum == CPTScatterPlotFieldX) ? activity.duty!.doubleValue - 0.5 : activity.importance!.doubleValue - 0.5
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        let activity = activities[Int(bitPattern: idx)]
        let energyValue = 1.0 - CGFloat(activity.energy!.doubleValue)
        println("\(activity.activity!.name!) energy: \(energyValue) importance: \(activity.importance!) duty: \(activity.duty!)")
        let symbol = CPTPlotSymbol.ellipsePlotSymbol()
        let baseRadius = 3 * symbol.size.width
        symbol.size = (CGSizeMake(baseRadius * energyValue, baseRadius * energyValue))
        symbol.lineStyle = nil
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let symbolColor = CPTColor(componentRed: energyValue > 0.5 ? 1.0 : 0.0,
                                       green: energyValue > 0.5 ? 0.0 : 0.75,
                                       blue: energyValue > 0.5 ? 0.0 : 0.2, alpha: 1.0)
        symbol.fill = CPTFill(color:symbolColor)
        return symbol
    }
}