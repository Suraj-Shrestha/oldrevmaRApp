//
//  CorePlotImageLayer.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 13/03/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//


class CorePlotImageLayer: CPTBorderedLayer {
    var image:UIImage
    let ImageSize:CGFloat = 20.0
    
    init(image:UIImage) {
        self.image = image
        super.init(frame:CGRectZero)
        self.bounds = CGRectMake(0, 0, ImageSize, ImageSize)
    }
    
    required init(coder: NSCoder) {
        image = UIImage(named:"important")!
        super.init(coder:coder)
    }
    
    override func drawInContext(context:CGContextRef) {
        CGContextDrawImage(context, self.bounds, image.CGImage)
    }
}
