//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

@objc
/// A class representing Call-To-Action (CTA) data, including its size and location.
/// This class is used to configure the appearance and placement of CTAs in the HyBid SDK.
public class HyBidCTAData: NSObject {
    
    /// The size of the CTA.
    @objc public let size : HyBidCTASize
    
    /// The location of the CTA.
    @objc public let location : HyBidCTALocation
    @objc public let cornerRadius: CGFloat = 8.0
    
    /// Initializes a new instance of `HyBidCTAData` with the specified size and location.
    /// - Parameters:
    ///   - size: The size of the CTA, represented by the `HyBidCTASize` enum.
    ///   - location: The location of the CTA, represented by the `HyBidCTALocation` enum.
    @objc public init(size: HyBidCTASize, location: HyBidCTALocation) {
        self.size = size
        self.location = location
    }
    
    @objc public static func sizeFromValue(_ value: Any) -> HyBidCTASize {
        return HyBidCTASize.sizeFromValue(value)
    }
    
    @objc public static func locationFromValue(_ value: Any) -> HyBidCTALocation {
        return HyBidCTALocation.locationFromValue(value)
    }
    
    @objc public func sizeValue() -> CGSize {
        return self.size.sizeValue()
    }
    
    @objc public func fontSize() -> CGFloat {
        return self.size.fontSize()
    }
    
    @objc public func ctaImageWithFixedSize(image: UIImage) -> UIImage {
        let targetSize = self.size.imageSize()
        return self.size.scalePreservingAspectRatio(image: image, targetSize: targetSize)
    }
    
    @objc public func locationBottomConstraint() -> CGFloat {
        return self.location.constraintsConstant().bottom
    }

    @objc public func locationLeadingConstraint() -> CGFloat {
        return self.location.constraintsConstant().leading
    }
    
    @objc public func accessibilityIdentifierString() -> String {
        return "openOfferButton_\(self.size.stringValue())_\(self.location.stringValue())"
    }
}

@objc
public enum HyBidCTASize: Int32 {
    
    @objc(HyBidCTASizeDefault) case defaultSize
    case medium
    case large
    
    fileprivate static func sizeFromValue(_ value: Any) -> HyBidCTASize {
        
        guard let stringValue = value as? String else { return .defaultSize }
        
        switch stringValue.lowercased() {
        case "medium": return .medium
        case "large": return .large
        default: return .defaultSize
        }
    }
    
    fileprivate func stringValue() -> String {
        switch self {
        case .defaultSize: return "default_size"
        case .medium: return "medium"
        case .large: return "large"
        }
    }
    
    fileprivate func sizeValue() -> CGSize {
        switch self {
        case .defaultSize: return CGSize(width: 128, height: 50)
        case .medium: return CGSize(width: 194, height: 48)
        case .large: return CGSize(width: 232, height: 64)
        }
    }
    
    fileprivate func fontSize() -> CGFloat {
        switch self {
        case .defaultSize: return 14.0
        case .medium: return 18.0
        case .large: return 22.0
        }
    }
    
    fileprivate func imageSize() -> CGSize {
        switch self {
            //default value is bigger since its image is smaller than medium & large formats
        case .defaultSize: return CGSize(width: 32, height: 32)
        case .medium: return CGSize(width: 24, height: 24)
        case .large: return CGSize(width: 28, height: 28)
        }
    }
    
    fileprivate func scalePreservingAspectRatio(image: UIImage, targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)

        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
}

@objc
public enum HyBidCTALocation: Int32 {
    
    @objc(HyBidCTALocationDefault) case defaultLocation
    case bottom_down
    case bottom_up
    
    fileprivate func stringValue() -> String {
        switch self {
        case .defaultLocation: return "default_location"
        case .bottom_down: return "bottom_down"
        case .bottom_up: return "bottom_up"
        }
    }
    
    fileprivate static func locationFromValue(_ value: Any) -> HyBidCTALocation {
        
        guard let stringValue = value as? String else { return .defaultLocation }
        
        switch stringValue.lowercased() {
        case "bottom_down": return .bottom_down
        case "bottom_up": return .bottom_up
        default: return .defaultLocation
        }
    }
    
    fileprivate func constraintsConstant() -> (bottom: CGFloat, leading: CGFloat) {
        
        guard let window = UIApplication.shared.keyWindow else { return (bottom: 0, leading: 0) }
        let safeAreaBottom = window.safeAreaInsets.bottom
    
        switch self {
        case .defaultLocation:
            return (bottom: 0, leading: 0)
        case .bottom_down:
            let bottom_down_constant = (bottom: 96.0, leading: 16.0)
            let bottomPercentageValue = UIDevice.current.orientation.isLandscape
                                      ? (bottom_down_constant.bottom * 100) / window.frame.width
                                      : (bottom_down_constant.bottom * 100) / window.frame.height
            let bottomConstraintValue = (window.frame.height * bottomPercentageValue) / 100
            return (bottom: bottomConstraintValue - safeAreaBottom, leading: bottom_down_constant.leading)
        case .bottom_up:
            let bottom_up_constant = (bottom: 260.0, leading: 0.0)
            let bottomPercentageValue = UIDevice.current.orientation.isLandscape
                                      ? (bottom_up_constant.bottom * 100) / window.frame.width
                                      : (bottom_up_constant.bottom * 100) / window.frame.height
            let bottomConstraintValue = (window.frame.height * bottomPercentageValue) / 100
            return (bottom: bottomConstraintValue - safeAreaBottom, leading: bottom_up_constant.leading)
        }
    }
}
