//
//  RevmaRappScatterPlot.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 23/06/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//

import Foundation

protocol WhitespaceTouchDelegate {
    func touchedWhiteSpaceAtPoint(point: CGPoint, plot: RevmaRappScatterPlot)
}


class RevmaRappScatterPlot: CPTScatterPlot {
    var whitespaceDelegate: WhitespaceTouchDelegate?
    override func pointingDeviceUpEvent(event: UIEvent, atPoint interactionPoint: CGPoint) -> Bool {
        let result = super.pointingDeviceUpEvent(event, atPoint: interactionPoint)
        if result == false {
            whitespaceDelegate?.touchedWhiteSpaceAtPoint(interactionPoint, plot: self)
        }
        return result
    }
}
