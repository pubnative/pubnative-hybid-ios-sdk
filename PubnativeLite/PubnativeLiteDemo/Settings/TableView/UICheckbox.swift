// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

@IBDesignable
class UICheckbox: UIControl {
    
    @IBInspectable var isChecked: Bool = false {
        didSet {
            if oldValue != isChecked {
                updateCheckmarkUI(animated: false)
            }
        }
    }
    
    @IBInspectable var boxColor: UIColor? {
        didSet {
            layer.borderColor = boxColor?.cgColor ?? UIColor.black.cgColor
        }
    }
    
    @IBInspectable var checkmarkColor: UIColor? {
        didSet {
            checkmarkLayer.strokeColor = checkmarkColor?.cgColor ?? UIColor.black.cgColor
        }
    }
    
    private var checkmarkLayer: CAShapeLayer!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        layer.borderWidth = 2.0
        layer.borderColor = boxColor?.cgColor ?? UIColor.black.cgColor
        layer.cornerRadius = 4.0
        
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
        
        checkmarkLayer = createCheckmarkLayer()
        layer.addSublayer(checkmarkLayer)
        checkmarkLayer.isHidden = !isChecked
    }
    
    private func createCheckmarkLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.size.width * 0.25, y: bounds.size.height * 0.5))
        path.addLine(to: CGPoint(x: bounds.size.width * 0.45, y: bounds.size.height * 0.75))
        path.addLine(to: CGPoint(x: bounds.size.width * 0.75, y: bounds.size.height * 0.25))
        
        layer.path = path.cgPath
        layer.fillColor = nil
        layer.strokeColor = checkmarkColor?.cgColor ?? UIColor.black.cgColor
        layer.lineWidth = 2.0
        return layer
    }
    
    @objc private func toggleState() {
        isChecked = !isChecked
        updateCheckmarkUI(animated: true)
        sendActions(for: .valueChanged)
    }
    
    private func updateCheckmarkUI(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.checkmarkLayer.isHidden = !self.isChecked
            }
        } else {
            checkmarkLayer.isHidden = !isChecked
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
}
