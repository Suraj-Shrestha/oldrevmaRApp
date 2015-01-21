//
//  HistoryViewController.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 14/01/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, CPTScatterPlotDataSource {
    
    @IBOutlet var graphView: CPTGraphHostingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create graph
        let graph = CPTXYGraph(frame: CGRectZero)
        graph.title = "Hello Graph"
        let plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace
        let xRange = plotSpace.xRange.mutableCopy() as CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as CPTMutablePlotRange
        
        xRange.location = -5.0
        xRange.length = 10.0
        yRange.location = -5
        yRange.length = 10.0
        
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange
        
        let plot = CPTScatterPlot(frame: CGRectZero)
        plot.dataSource = self
        graph.addPlot(plot)
        
        self.graphView.hostedGraph = graph
    }

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return 4
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        
        if idx % 2 == 0 {
            return -Int(idx + 1)
        }
        return idx+1
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        return CPTPlotSymbol.ellipsePlotSymbol()
        
    }
}