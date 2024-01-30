//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
