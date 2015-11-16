//
//  HistoryViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 14/01/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, CPTScatterPlotDataSource, CPTScatterPlotDelegate, WhitespaceTouchDelegate, PeriodGraphChooserControllerDelegate {

    static let ShowQuadrantIdentifier = "showQuadrant"
    static let ShowPeriodEditIdentifier = "showPeriodEdit"
    static let SavedPeriodNamesKey = "selectedPeriodNames"
    
    @IBOutlet weak var graphView: CPTGraphHostingView!
    var cacheCountSet = false
    var cacheCount: UInt = 0

    var selectedQuadrant: ActivityItem.GraphQuadrant = .Unknown
    weak var appDelegate:AppDelegate! = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var managedObjectContext: NSManagedObjectContext?

    var selectedPeriods:[ActivityPeriod] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = appDelegate.managedObjectContext
        fetchPeriods()
        updateTitle()
        configureView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextChanged:",
                                                                name:NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func contextChanged(notification: NSNotification) {
        fetchPeriods()
        if let hostedGraph = self.graphView.hostedGraph {
            hostedGraph.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func configureView() {
        setupGraph()
    }

    func fetchPeriods() {
        // Probably need to page this by date at some point as well, for now get me everything
        selectedPeriods = []
        let fetchRequest = NSFetchRequest(entityName: ActivityPeriod.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ActivityPeriodAttributes.start.rawValue, ascending: false)]
        do {
            let results = try self.managedObjectContext?.executeFetchRequest(fetchRequest)
            let defaults = NSUserDefaults.standardUserDefaults()
            let allPeriods = results as! [ActivityPeriod]
            if let periodNames = defaults.stringArrayForKey(HistoryViewController.SavedPeriodNamesKey) {
                for name in periodNames {
                    for period in allPeriods {
                        if name == period.name! {
                            selectedPeriods.append(period)
                        }
                    }
                }
            } else if !allPeriods.isEmpty {
                selectedPeriods.append(allPeriods.first!)
            }
            selectedPeriods.sortInPlace({ (p1: ActivityPeriod, p2: ActivityPeriod) -> Bool in
                        return p1.start!.compare(p2.start!) == .OrderedDescending })
        } catch let error as NSError {
            print("Unresolved error \(error.localizedDescription), \(error.userInfo)\n Attempting to get activity names")
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
      
        let plot = RevmaRappScatterPlot(frame: CGRectZero)
        
        let axisTitleTextStyle = CPTMutableTextStyle()
        axisTitleTextStyle.fontName = "Helvetica-Bold"
        axisTitleTextStyle.fontSize = 13.0
        
        let axisSet = graph.axisSet as! CPTXYAxisSet
        let x = axisSet.xAxis
        x!.separateLayers = true
        
        createAxisLabel(x!,
            image: UIImage.init(named: "wish"),
            altText: NSLocalizedString("duty_max_label", comment: "duty"),
            altTextStyle: axisTitleTextStyle)
        
        x!.titleOffset = 5
        x!.titleLocation = 0.5

        let x2 = CPTXYAxis(frame: CGRectZero)
        x2.coordinate = CPTCoordinate.X
        x2.plotSpace = plotSpace
        x2.separateLayers = true
        x2.labelingPolicy = CPTAxisLabelingPolicy.None

        createAxisLabel(x2,
            image: UIImage.init(named: "handshake"),
            altText: NSLocalizedString("duty_min_label", comment: "duty"),
            altTextStyle: axisTitleTextStyle)
        
        x2.titleOffset = 5
        x2.titleLocation = -0.5
        
        let y = axisSet.yAxis
        y!.separateLayers = false
        createAxisLabel(y!,
            image: UIImage.init(named:"important"),
            altText: NSLocalizedString("meaning_max_label", comment: "importance"),
            altTextStyle: axisTitleTextStyle)
        
        y!.titleOffset = 5
        y!.titleLocation = 0.5
        
        let y2 = CPTXYAxis(frame: CGRectZero)
        y2.coordinate = CPTCoordinate.Y
        y2.plotSpace = plotSpace
        y2.separateLayers = true
        y2.labelingPolicy = CPTAxisLabelingPolicy.None

        createAxisLabel(y2,
            image: UIImage.init(named:"unimportant"),
            altText: NSLocalizedString("meaning_min_label", comment: "importance"),
            altTextStyle: axisTitleTextStyle)

        y2.titleOffset = 5
        y2.titleLocation = -0.5
        
        graph.axisSet!.axes = [x!, x2, y!, y2]
        
        plot.dataLineStyle = nil
        plot.dataSource = self
        plot.delegate = self
        plot.whitespaceDelegate = self
        graph.addPlot(plot)
        
        self.graphView.hostedGraph = graph
    }


    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Get the detail view hooked up.
        if let whichSegue = segue.identifier {
            switch (whichSegue) {
            case HistoryViewController.ShowQuadrantIdentifier:
                if let activityViewController = segue.destinationViewController as? QuadrantActivityTableViewController {
                    activityViewController.activities = fetchActivitiesForQuadrant(selectedQuadrant)
                }
            case HistoryViewController.ShowPeriodEditIdentifier:
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let periodController = navigationController.topViewController as? PeriodGraphChooserController {
                        periodController.delegate = self
                        periodController.selectedPeriods = Set<ActivityPeriod>(selectedPeriods)
                    }
                }
            default:
                break;
            }
        }
    }

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        if cacheCountSet {
            return cacheCount
        }


        if selectedPeriods.isEmpty {
            return 0
        }

        cacheCount = 0
        for period in selectedPeriods {
            cacheCount = cacheCount + UInt(period.activityItems.count)
        }
        cacheCountSet = true
        return cacheCount
    }

    private func activityForRecordIndex(index: UInt) -> ActivityItem? {
        var indexAsInt = Int(bitPattern: index)
        // Sadly, sets aren't ordered.
        for period in selectedPeriods {
            let activityCount = period.activityItems.count
            if indexAsInt < activityCount {
                return period.activityItems.allObjects[indexAsInt] as? ActivityItem
            }
            indexAsInt -= activityCount
        }
        ZAssert(false, "We should have returned an item from above")
        return nil
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        let CPTScatterPlotFieldX: UInt = 0 // Conversion to enums doesn't seem to work :-/

        let activity = activityForRecordIndex(idx)!
        return (fieldEnum == CPTScatterPlotFieldX) ? activity.duty!.doubleValue - 0.5 : activity.importance!.doubleValue - 0.5
    }
    
    private func periodForIndex(index:UInt) -> Int {
        var shrinkingIndex = index;
        var symbolIndex = 0
        for period in selectedPeriods {
            let activityCount = UInt(period.activityItems.count)
            if  shrinkingIndex < activityCount {
                return symbolIndex
            }
            shrinkingIndex = shrinkingIndex - activityCount
            symbolIndex = symbolIndex + 1
        }
        return 0;
    }

    private func fetchActivitiesForQuadrant(quad: ActivityItem.GraphQuadrant) -> [ActivityItem] {
        var activities = [ActivityItem]()

        for period in selectedPeriods {
            for activity in period.activityItems.allObjects as! [ActivityItem] {
                if (activity.quadrant == quad) {
                    activities.append(activity)
                }
            }
        }
        return activities.sort({ (a1: ActivityItem, a2: ActivityItem) -> Bool in
                return a1.activityGraphDistance > a2.activityGraphDistance
            })
    }

    private func showActivitiesForQuadrant(quad: ActivityItem.GraphQuadrant) {
        selectedQuadrant = quad
        self.performSegueWithIdentifier(HistoryViewController.ShowQuadrantIdentifier, sender: self)
    }

    func scatterPlot(plot: CPTScatterPlot, plotSymbolTouchUpAtRecordIndex idx: UInt) {
        if let activity = activityForRecordIndex(idx) {
            showActivitiesForQuadrant(activity.quadrant)
        }
    }

    func touchedWhiteSpaceAtPoint(point: CGPoint, plot: RevmaRappScatterPlot) {
        let frameRect = plot.frame
        let halfWidth = frameRect.size.width / 2
        let halfHeight = frameRect.size.height / 2
        let quads = [
            CGRectMake(frameRect.origin.x + halfWidth, frameRect.origin.y + halfHeight, halfWidth, halfHeight), // Quadrant I
            CGRectMake(frameRect.origin.x, frameRect.origin.y, halfWidth, halfHeight), // Quadrant II
            CGRectMake(frameRect.origin.x, frameRect.origin.y + halfHeight, halfWidth, halfHeight), // Quadrant III
            CGRectMake(frameRect.origin.x + halfWidth, frameRect.origin.y, halfWidth, halfHeight) // Quadrant IV
            ]
        var rawValue = 1
        for quad in quads {
            if CGRectContainsPoint(quad, point) {
                showActivitiesForQuadrant(ActivityItem.GraphQuadrant(rawValue: rawValue)!)
                break;
            }
            rawValue = rawValue + 1
        }
    }

    func symbolForScatterPlot(plot: CPTScatterPlot, recordIndex idx: UInt) -> CPTPlotSymbol? {
        // The current strategy is…
        // Things that take energy are red, more red == take more energy
        // Things that give energy are green, more green == give more energy
        // Size is based on time, the more time used the bigger.
        let activity = activityForRecordIndex(idx)!
        let Symbols = [CPTPlotSymbol.rectanglePlotSymbol(), CPTPlotSymbol.diamondPlotSymbol(),
            CPTPlotSymbol.trianglePlotSymbol(), CPTPlotSymbol.ellipsePlotSymbol(), CPTPlotSymbol.plusPlotSymbol(),
            CPTPlotSymbol.crossPlotSymbol()]
        let symbol = Symbols[periodForIndex(idx) % Symbols.count]
        let baseRadius = 2 * symbol.size.width
        let radiusMultiplier = CGFloat(activity.duration!.floatValue) / 30
        symbol.size = CGSizeMake(baseRadius * radiusMultiplier, baseRadius * radiusMultiplier)
        
        var components = [CGFloat](count: 3, repeatedValue: 0.55)

        components = AppDelegate.rgbComponetsForActivity(activity)
        let symbolColor = CPTColor(componentRed: components[0],
            green: components[1],
            blue: components[2], alpha: 1.0)
        symbol.lineStyle = nil
        symbol.fill = CPTFill(color:symbolColor)

        return symbol
    }

    private func finishDismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    private func updatePeriods(newPeriods: Set<ActivityPeriod>) {
        selectedPeriods = newPeriods.sort({ (p1: ActivityPeriod, p2: ActivityPeriod) -> Bool in
            return p1.start?.compare(p2.start!) == .OrderedDescending
        })
        var periodNames:[String] = []
        periodNames.reserveCapacity(selectedPeriods.count)
        for period in selectedPeriods {
            periodNames.append(period.name!)
        }
        NSUserDefaults.standardUserDefaults().setObject(periodNames, forKey: HistoryViewController.SavedPeriodNamesKey)

        cacheCountSet = false
        updateTitle()
        self.graphView.hostedGraph!.reloadData()
    }

    private func updateTitle() {
        if selectedPeriods.isEmpty {
            self.title = NSLocalizedString("Choose a period", comment: "")
        } else if selectedPeriods.count == 1 {
            self.title = selectedPeriods.first!.name
        } else {
            self.title = NSLocalizedString("Multiple periods", comment: "")
        }
    }

    func periodChooserControllerDidCancel(controller: PeriodGraphChooserController) {
        finishDismiss()
    }

    func periodChooserControllerDidDone(controller: PeriodGraphChooserController) {
        updatePeriods(controller.selectedPeriods)
        finishDismiss()
    }
}
















