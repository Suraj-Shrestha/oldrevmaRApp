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
        graph.title = "Hello Graph"
        let plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace
        let xRange = plotSpace.xRange.mutableCopy() as CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as CPTMutablePlotRange
        
        xRange.location = -0.6
        xRange.length = 1.1
        yRange.location = -0.6
        yRange.length = 1.1
        
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange
        
        let plot = CPTScatterPlot(frame: CGRectZero)
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
        println("Field index: \(fieldEnum) energy: \(activity.energy!) importance: \(activity.importance!)")
        return (fieldEnum == CPTScatterPlotFieldX) ? activity.duty!.doubleValue - 0.5 : activity.importance!.doubleValue - 0.5
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        let activity = activities[Int(bitPattern: idx)]
        let energyValue = CGFloat(1.0) + CGFloat(activity.energy!.doubleValue)
        let symbol = CPTPlotSymbol.ellipsePlotSymbol()
        let baseRadius = 3 * symbol.size.width
        symbol.size = (CGSizeMake(baseRadius * energyValue, baseRadius * energyValue))
        symbol.lineStyle = nil
        symbol.fill = CPTFill(color: CPTColor.blueColor())
        
        return symbol
    }
}