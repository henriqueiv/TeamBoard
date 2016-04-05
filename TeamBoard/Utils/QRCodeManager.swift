//
//  QRCodeManager.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//

import CoreImage

enum QRCodeManagerError: ErrorType {
    case ErrorGettingOutputImage
    case ErrorCreatingFilter
    case ErrorGeneratingStringData
}

class QRCodeManager {
    
    static let sharedInstance = QRCodeManager()
    
    private enum InputCorrectionLevel: String {
        case Low = "L", Medium = "M", High = "Q", Ultra = "H"
    }
    
    func generateQRCodeFromString(string:String, withFrameSize frameSize:CGSize) throws -> CIImage? {
        guard let data = string.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false) else {
            throw QRCodeManagerError.ErrorGeneratingStringData
        }
        
        let inputParameters:[String:AnyObject] = [
            "inputMessage":data,
            "inputCorrectionLevel":InputCorrectionLevel.Low.rawValue
        ]
        guard let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: inputParameters) else {
            throw QRCodeManagerError.ErrorGettingOutputImage
        }
        
        guard let outputImage = filter.outputImage else {
            throw QRCodeManagerError.ErrorGettingOutputImage
        }
        
        let scaleX = frameSize.width / outputImage.extent.size.width
        let scaleY = frameSize.height / outputImage.extent.size.height
        
        let qrCodeCIImage = outputImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        return qrCodeCIImage
    }
    
}