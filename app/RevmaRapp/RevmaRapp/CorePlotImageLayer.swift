//
//  CorePlotImageLayer.swift
//  RevmaRapp
//
//  Created by Trenton Schulz on 13/03/15.
//  Copyright (c) 2015 Norsk Regnesentral. All rights reserved.
//


class CorePlotImageLayer: CPTBorderedLayer {
    var image:UIImage
    
    init(image:UIImage) {
        self.image = image
        super.init(frame:CGRectZero)
        self.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
    }
    
    required init(coder: NSCoder) {
        image = UIImage(named:"important")!
        super.init(coder:coder)
    }
    
    override func drawInContext(context:CGContextRef) {
        CGContextDrawImage(context, self.bounds, image.CGImage)
    }
}
