//
//  FiltersFactory.swift
//  FiltererX
//
//  Created by Mohamed El-Alfy on 3/2/16.
//  Copyright © 2016 Mohamed El-Alfy. All rights reserved.
//


import Foundation
import UIKit
import CoreImage

public typealias Filter = CIImage -> CIImage

infix operator >>> { associativity left }

public func >>> (filter1: Filter, filter2: Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}

public class FiltersFactory {
    
   public class var sharedInstance: FiltersFactory
    {
        struct Static
        {
            static var onceToken: dispatch_once_t = 0
            static var instance: FiltersFactory? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = FiltersFactory()
        }
        return Static.instance!
    }
    
    public var filtersStore : [(name:String,filter:Filter)]?
    
    init(){
        self.filtersStore = [
            
            //Basic
            ("None", colorControls()),
            ("Chrome", photoEffectChrome()),
            ("Fade",photoEffectFade()),
            ("Instant",photoEffectInstant()),
            ("Process",photoEffectProcess()),
            ("Transfer",photoEffectTransfer()),
            ("LtosRGB",linearToSRGBToneCurve()),
            ("Sepia",sepiaTone()),
       
            //Vintage
            ("ClassicVintage",colorCube(keyImage: "k_ClassicVintage")),
            ("RETROLollipop",colorCube(keyImage: "k_RETROLollipop")),
            ("RetroVintage",colorCube(keyImage: "k_RetroVintage")),
            ("SweetVintage",colorCube(keyImage: "k_SweetVintage")),
            ("VintageHaze",colorCube(keyImage: "k_VintageHaze")),
            ("VintageSummer",colorCube(keyImage: "k_VintageSummer")),
            ("VintageWine",colorCube(keyImage: "k_VintageWine")),
            
            //Retro
            ("Brunch",colorCube(keyImage: "k_Brunch")),
            ("Daydream",colorCube(keyImage: "k_Daydream")),
            ("Heatwave",colorCube(keyImage: "k_Heatwave")),
            ("Helga",colorCube(keyImage: "k_Helga")),
            ("Mignon",colorCube(keyImage: "k_Mignon")),
            ("Molle",colorCube(keyImage: "k_Molle")),
            ("Radiance",colorCube(keyImage: "k_Radiance")),
            ("Reunion",colorCube(keyImage: "k_Reunion")),
            ("Steampunk",colorCube(keyImage: "k_Steampunk")),
            ("Wilderness",colorCube(keyImage: "k_Wilderness")),
            
            //B&W
            ("BWChampagne",colorCube(keyImage: "k_BWChampagne")),
            ("BWChampagneHaze",colorCube(keyImage: "k_BWChampagneHaze")),
            ("BWPlatinum",colorCube(keyImage: "k_BWPlatinum")),
            ("BWRichVintage",colorCube(keyImage: "k_BWRichVintage")),
            ("BWVanilla",colorCube(keyImage: "k_BWVanilla")),
            ("BWVintageButtercup",colorCube(keyImage: "k_BWVintageButtercup")),
            ("BWVintageChocolate",colorCube(keyImage: "k_BWVintageChocolate"))

        ]
    }
    
    
   public func gaussianBlur(radius radius:Double) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIGaussianBlur", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputRadiusKey : radius
                ])
            return filter!.outputImage!
        }
    }
    
    public func hueAdjust(angle angle : Double) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIHueAdjust", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputAngleKey : angle
                ])
            return filter!.outputImage!
        }
    }
    
   public func colorControls(saturation saturation:Double = 1.0, brightness:Double = 0.0, contrast:Double = 1.0) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIColorControls", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputSaturationKey : saturation,
                    kCIInputBrightnessKey : brightness,
                    kCIInputContrastKey : contrast
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectChrome() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectChrome", withInputParameters:
                [
                    kCIInputImageKey : image,

                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectFade() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectFade", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectInstant() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectInstant", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectMono() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectMono", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectNoir() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectNoir", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectProcess() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectProcess", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectTonal() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectTonal", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func photoEffectTransfer() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIPhotoEffectTransfer", withInputParameters:
                [
                    kCIInputImageKey : image,
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func sepiaTone(intensity intensity:Double = 1) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CISepiaTone", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputIntensityKey : intensity
                ])
            return filter!.outputImage!
        }
    }
    
    public func vignette(intensity intensity:Double , radius:Double) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIVignette", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputIntensityKey : intensity,
                    kCIInputRadiusKey : radius
                ])
            return filter!.outputImage!
        }
    }
    
    public func vignetteEffect(intensity intensity:Double , radius:Double , center : CIVector) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIVignetteEffect", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputIntensityKey : intensity,
                    kCIInputRadiusKey : radius ,
                    kCIInputCenterKey : center
                ])
            return filter!.outputImage!
        }
    }
    
    public func bloom(intensity intensity:Double , radius:Double) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIBloom", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputIntensityKey : intensity,
                    kCIInputRadiusKey : radius
                ])
            return filter!.outputImage!
        }
    }
    
    public func comicEffect() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIComicEffect", withInputParameters:
                [
                    kCIInputImageKey : image
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorClamp(minComponents minComponents:CIVector , maxComponents:CIVector) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIColorClamp", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputMinComponents" : minComponents,
                    "inputMaxComponents" : maxComponents
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorMatrix(red red:CIVector = CIVector(r: 1, g: 0, b: 0, a: 0) , green:CIVector = CIVector(r: 0, g: 1, b: 0, a: 0) , blue:CIVector = CIVector(r: 0, g: 0, b: 1, a: 0), alpha:CIVector = CIVector(r: 0, g: 0, b: 0, a: 1), bias:CIVector = CIVector(r: 0, g: 0, b: 0, a: 0)) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIColorMatrix", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputRVector" : red,
                    "inputGVector" : green,
                    "inputBVector" : blue,
                    "inputAVector" : alpha,
                    "inputBiasVector" : bias
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorMatrix(red red:CGFloat , green:CGFloat , blue:CGFloat, alpha:CGFloat) -> Filter
    {
        let rVector = CIVector(r: red, g: 0, b: 0, a: 0)
        let gVector = CIVector(r: 0, g: green, b: 0, a: 0)
        let bVector = CIVector(r: 0, g: 0, b: blue, a: 0)
        let aVector = CIVector(r: 0, g: 0, b: 0, a: alpha)
        return { image in
            let filter = CIFilter(name: "CIColorMatrix", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputRVector" : rVector,
                    "inputGVector" : gVector,
                    "inputBVector" : bVector,
                    "inputAVector" : aVector
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorPolynomial(red red:CGFloat = 1 , green:CGFloat = 1 , blue:CGFloat = 1 , alpha:CGFloat = 1) -> Filter
    {
        let rVector = CIVector(r: red, g: 0, b: 0, a: 0)
        let gVector = CIVector(r: 0, g: green, b: 0, a: 0)
        let bVector = CIVector(r: 0, g: 0, b: blue, a: 0)
        let aVector = CIVector(r: 0, g: 0, b: 0, a: alpha)
        return { image in
            let filter = CIFilter(name: "CIColorPolynomial", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputRedCoefficients" : rVector,
                    "inputGreenCoefficients" : gVector,
                    "inputBlueCoefficients" : bVector,
                    "inputAlphaCoefficients" : aVector
                ])
            return filter!.outputImage!
        }
    }
    
    public func linearToSRGBToneCurve() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CILinearToSRGBToneCurve", withInputParameters:
                [
                    kCIInputImageKey : image
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func sRGBToneCurveToLinear() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CISRGBToneCurveToLinear", withInputParameters:
                [
                    kCIInputImageKey : image
                    
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorCube(keyImage keyImage:String) -> Filter
    {
        return { image in
            let keyCgImage = UIImage(named: keyImage)?.CGImage
            let sizeOfCube = CGImageGetWidth(keyCgImage)
            let colorCubeData = ColorCubeDataGenerator.colorCubeDataForCGImageRef(keyCgImage)
            let filter = CIFilter(name: "CIColorCube", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputCubeData" : colorCubeData! ,
                    "inputCubeDimension" : sizeOfCube
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorMonochrome(intensity intensity:Double , color:CIColor) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIColorMonochrome", withInputParameters:
                [
                    kCIInputImageKey : image,
                    kCIInputColorKey : color ,
                    kCIInputIntensityKey : intensity
                ])
            return filter!.outputImage!
        }
    }
    
    public func colorInvert() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIColorInvert", withInputParameters:
                [
                    kCIInputImageKey : image
                ])
            return filter!.outputImage!
        }
    }
    
    public func maximumComponent() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIMaximumComponent", withInputParameters:
                [
                    kCIInputImageKey : image
                ])
            return filter!.outputImage!
        }
    }
    
    public func minimumComponent() -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIMinimumComponent", withInputParameters:
                [
                    kCIInputImageKey : image
                ])
            return filter!.outputImage!
        }
    }
    
    public func falseColor(color0 color0:CIColor , color1:CIColor) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CIFalseColor", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputColor0" : color0 ,
                    "inputColor1" : color1
                ])
            return filter!.outputImage!
        }
    }
    
    
    
    public func sharpenLuminance(sharpnessValue value:Double = 0.40) -> Filter
    {
        return { image in
            let filter = CIFilter(name: "CISharpenLuminance", withInputParameters:
                [
                    kCIInputImageKey : image,
                    "inputSharpness" : value
                ])
            return filter!.outputImage!
        }
    }
    
}


