//
//  HistoryViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 14/01/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    
    let SliderValueKey = "RevmaRappSliderValue"
    let ShowQuadrantIdentifier = "showQuadrant"
    
    @IBOutlet weak var graphView: CPTGraphHostingView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var weekSlider: UISlider!
    var currentSet:Int = 1
    var selectedQuadrant: ActivityItem.GraphQuadrant = .Unknown
    var sortedKeys:[Int] = []
    weak var appDelegate:AppDelegate! = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var managedObjectContext: NSManagedObjectContext?

    var activitiesByPeriods = [Int: [ActivityItem]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = appDelegate.managedObjectContext
        fetchActivities()
        configureView()
    }

    func configureView() {
        weekSlider.maximumValue = Float(activitiesByPeriods.count)
        setupGraph()
    }

    func fetchActivities() {
        // Probably need to page this by date at some point as well, for now get me everything
        let fetchRequest = NSFetchRequest(entityName: ActivityPeriod.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityPeriodAttributes.start.rawValue, ascending: false)]
        var error: NSError?
        if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) {
            let periods = results as! [ActivityPeriod]
            var periodKey = 1
            for period in periods {
                let activities = period.activityItems.allObjects as! [ActivityItem]
                activitiesByPeriods[periodKey] = activities
                periodKey = periodKey + 1
            }
            sortedKeys = sorted(activitiesByPeriods.keys) { $0 < $1 }
        } else {
            println("Unresolved error \(error?.localizedDescription), \(error?.userInfo)\n Attempting to get activity names")
        }
    }

    func createAxisLabel(axis:CPTXYAxis, image:UIImage?, altText:String, altTextStyle:CPTTextStyle) {
        if let goodImage = image {
            let imageAsContentLayer = CorePlotImageLayer(image: goodImage)
            let imageTitle = CPTAxisTitle(contentLayer:imageAsContentLayer)
            axis.axisTitle = imageTitle
        } else {
            axis.title = altText
            axis.titleTextStyle = altTextStyle
        }
        
    }
    
    func setupGraph() {
        // create graph
        graphView.allowPinchScaling = true
        let graph = CPTXYGraph(frame: CGRectZero)
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        
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
        
        let axisSet = graph.axisSet as! CPTXYAxisSet
        let x = axisSet.xAxis
        x.separateLayers = true
        
        createAxisLabel(x,
            image: UIImage.init(named: "wish", inBundle:nil, compatibleWithTraitCollection:nil),
            altText: NSLocalizedString("duty_max_label", comment: "duty"),
            altTextStyle: axisTitleTextStyle)
        
        x.titleOffset = 5
        x.titleLocation = 0.5

        let x2 = CPTXYAxis(frame: CGRectZero)
        x2.coordinate = CPTCoordinate.X
        x2.plotSpace = plotSpace
        x2.separateLayers = true
        x2.labelingPolicy = CPTAxisLabelingPolicy.None

        createAxisLabel(x2,
            image: UIImage.init(named: "handshake", inBundle:nil, compatibleWithTraitCollection:nil),
            altText: NSLocalizedString("duty_min_label", comment: "duty"),
            altTextStyle: axisTitleTextStyle)
        
        x2.titleOffset = 5
        x2.titleLocation = -0.5
        
        let y = axisSet.yAxis
        y.separateLayers = false
        createAxisLabel(y,
            image: UIImage.init(named:"important", inBundle:nil, compatibleWithTraitCollection:nil),
            altText: NSLocalizedString("meaning_max_label", comment: "importance"),
            altTextStyle: axisTitleTextStyle)
        
        y.titleOffset = 5
        y.titleLocation = 0.5
        
        let y2 = CPTXYAxis(frame: CGRectZero)
        y2.coordinate = CPTCoordinate.Y
        y2.plotSpace = plotSpace
        y2.separateLayers = true
        y2.labelingPolicy = CPTAxisLabelingPolicy.None

        createAxisLabel(y2,
            image: UIImage.init(named:"unimportant", inBundle:nil, compatibleWithTraitCollection:nil),
            altText: NSLocalizedString("meaning_min_label", comment: "importance"),
            altTextStyle: axisTitleTextStyle)

        y2.titleOffset = 5
        y2.titleLocation = -0.5
        
        graph.axisSet.axes = [x, x2, y, y2]
        
        plot.dataLineStyle = nil
        plot.dataSource = self
        plot.delegate = self
        graph.addPlot(plot)
        
        self.graphView.hostedGraph = graph
    }


    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case ShowQuadrantIdentifier:
                if let activityViewController = segue.destinationViewController.topViewController as? QuadrantActivityTableViewController {

                    activityViewController.activities = fetchActivitiesForQuadrant(selectedQuadrant)
                }
            default:
                break;
            }
        }
    }

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if activitiesByPeriods.isEmpty {
            return 0
        }

        let howManyPeriods = currentSet
        var recCount:UInt = 0;
        for i in 1...howManyPeriods {
            if let activities = activitiesByPeriods[i] {
                recCount = recCount + UInt(activities.count)
            }
        }
        return recCount
    }

    private func activityForRecordIndex(index: UInt) -> ActivityItem? {
        var indexAsInt = Int(bitPattern: index)
        for key in sortedKeys {
            if let activities = activitiesByPeriods[key] {
                if indexAsInt < activities.count {
                    return activities[indexAsInt]
                }
                indexAsInt -= activities.count
            }
        }
        ZAssert(false, "We should have returned an item from above")
        return nil
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject {
        let CPTScatterPlotFieldX: UInt = 0 // Conversion to enums doesn't seem to work :-/
        
        let activity = activityForRecordIndex(idx)!
        return (fieldEnum == CPTScatterPlotFieldX) ? activity.duty!.doubleValue - 0.5 : activity.importance!.doubleValue - 0.5
    }
    
    private func periodForIndex(index:UInt) -> Int {
        var shrinkingIndex = index;
        for key in sortedKeys {
            if let activities = activitiesByPeriods[key] {
                if shrinkingIndex < UInt(activities.count) {
                    return key;
                }
                shrinkingIndex = shrinkingIndex - UInt(activities.count)
            }
        }
        return -1;
    }

    private func fetchActivitiesForQuadrant(quad: ActivityItem.GraphQuadrant) -> [ActivityItem] {
        var activities = [ActivityItem]()

        let howManyPeriods = currentSet
        for i in 1...howManyPeriods {
            if let periodArray = activitiesByPeriods[i] {
                for activity in periodArray {
                    if (activity.quadrant == quad) {
                        activities.append(activity)
                    }
                }
            }
        }
        return sorted(activities, { (a1: ActivityItem, a2: ActivityItem) -> Bool in
                return a1.activityGraphDistance < a2.activityGraphDistance
            })
    }

    private func showActivitiesForQuadrant(quad: ActivityItem.GraphQuadrant) {
        selectedQuadrant = quad
        self.performSegueWithIdentifier(ShowQuadrantIdentifier, sender: self)
    }

    func scatterPlot(plot: CPTScatterPlot!, plotSymbolTouchUpAtRecordIndex idx: UInt) {
        if let activity = activityForRecordIndex(idx) {
            showActivitiesForQuadrant(activity.quadrant)
        }
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        let activity = activityForRecordIndex(idx)!
        let energyValue = 1.0 - CGFloat(activity.energy!.doubleValue)
        let Symbols = [CPTPlotSymbol.rectanglePlotSymbol(), CPTPlotSymbol.diamondPlotSymbol(),
                         CPTPlotSymbol.trianglePlotSymbol(), CPTPlotSymbol.ellipsePlotSymbol(), CPTPlotSymbol.plusPlotSymbol(),
                         CPTPlotSymbol.crossPlotSymbol()]
        
        let symbol = Symbols[periodForIndex(idx) - 1 % Symbols.count]
        let baseRadius = 5 * symbol.size.width
        symbol.size = (CGSizeMake(baseRadius * energyValue, baseRadius * energyValue))
        
        let isGreen = activity.isGreen
        let isRed = activity.isRed
        
        var components = [CGFloat](count: 3, repeatedValue: 0.55)

        // Find color based on the section. Section I: shades of green. Section III: shades of red. Others: something else?
        // Green Hue: 90 degrees, Saturation 50%, Lightness 25–75%
        // Red Hue: 0 degrees, Saturation 50%, Lightness 30–80%
        
        if isGreen || isRed {
            components = appDelegate.rgbComponetsForActivity(activity, isGreen: isGreen)
            let symbolColor = CPTColor(componentRed: components[0],
                green: components[1],
                blue: components[2], alpha: 1.0)
            symbol.lineStyle = nil
            symbol.fill = CPTFill(color:symbolColor)
        } else {
            let grayLineStyle = symbol.lineStyle.mutableCopy() as! CPTMutableLineStyle
            grayLineStyle.lineColor = CPTColor.grayColor()
            symbol.lineStyle = grayLineStyle
        }

        return symbol
    }
    
    @IBAction func sliderChange(slider: UISlider) {
        let flooredValue = Int(round(slider.value))
        slider.setValue(Float(flooredValue), animated: false)
        if flooredValue != currentSet {
            currentSet = flooredValue
            graphView.hostedGraph.reloadData()
        }
    }
}