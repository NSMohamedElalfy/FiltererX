//
//  ColorCubeDataGenerator.m
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/2/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//

#import "ColorCubeDataGenerator.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>

@implementation ColorCubeDataGenerator

#pragma mark - public methods

+ (NSData *) colorCubeDataForCGImageRef:(CGImageRef)imageRef {
    
    NSData *cubeNSData;
    const unsigned int size = floor(CGImageGetWidth(imageRef));
    
    NSUInteger cubeDataSize = ( size * size * size * sizeof(char) * 4);
    char *cubeCharData = [self convertCGImageRefToBitmapRGBA8CharData:imageRef];
    
    cubeNSData = [NSData dataWithBytesNoCopy:cubeCharData length:cubeDataSize freeWhenDone:YES];
    
    return cubeNSData;
}

#pragma mark - private methods

+ (char *) convertCGImageRefToBitmapRGBA8CharData:(CGImageRef)imageRef {
    
    // Create a bitmap context to draw the UIImage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
    if(!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    char *bitmapData = ( char *)CGBitmapContextGetData(context);
    
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    
    char *newBitmap = NULL;
    
    if(bitmapData) {
        newBitmap = ( char *)malloc(sizeof( char) * bytesPerRow * height);
        
        if(newBitmap) {	// Copy the data
            for(size_t i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }
        
        free(bitmapData);
        
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
        free(bitmapData);
    }
    
    CGContextRelease(context);
    
    return newBitmap;
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedLast);	// RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

@end
