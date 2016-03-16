//
//  ColorCubeDataGenerator.h
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/2/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CIFilter;

@interface ColorCubeDataGenerator : NSObject

+ (NSData *)colorCubeDataForCGImageRef:(CGImageRef)imageRef;

@end
