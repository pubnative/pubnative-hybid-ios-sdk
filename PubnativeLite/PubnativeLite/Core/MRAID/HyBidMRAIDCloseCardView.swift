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

@objc
public class HyBidMRAIDCloseCardView: UIView {
    
    // MARK: Outlets
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankingView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contentInfoContainer: UIView!
    @IBOutlet weak var installButton: UIButton!
    
    // MARK: Constraints
    
    @IBOutlet weak var widthIconlayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightIconLayoutConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    
    private var adModel: HyBidAdModel!
    private var cornerRadiusIcon = 30.0
    private var cornerRadiusButton = 20.0
    
    @objc public init(dictionary: NSDictionary) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        self.xibSetUp()
        guard let dictionary = dictionary as? [AnyHashable : Any],
              let ads = dictionary["ads"] as? Array<Any>,
              let adModel = HyBidAdModel.init(dictionary: ads.first as? [String: Any]) else { return }
        
        setAdModelValue(adModel: adModel)
    }
    
    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        self.customizeCloseCard()
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HyBidMRAIDCloseCardView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
        
    }
    
    func customizeCloseCard(){
        self.iconImageView.layer.cornerRadius = cornerRadiusIcon
        self.installButton.layer.cornerRadius = cornerRadiusButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAdModelValue(adModel: HyBidAdModel){
        self.adModel = adModel
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if((adModel) != nil){
            self.setAdValuesInUI()
        }
    }
    
    func setAdValuesInUI(){
        DispatchQueue.main.async { [weak self] in
            self?.setTitleValues()
            self?.setContentInfoValues()
            self?.setIconValues()
            self?.setRatingValues()
        }
    }
    
    func setContentInfoValues(){
        let contentInfo = HyBidContentInfoView(frame: self.contentInfoContainer.frame)
        
        guard let contentInfoAsset = self.adModel.meta(withType: "contentinfo"),
              let link = contentInfoAsset.data["link"] as? String,
              let icon = contentInfoAsset.data["icon"] as? String,
              let text = contentInfoAsset.data["text"] as? String else { return }
        
        contentInfo.link = link
        contentInfo.icon = icon
        contentInfo.text = text
        contentInfo.display = contentInfo.display
        contentInfo.zoneID = contentInfo.zoneID
        contentInfo.delegate = self
        self.contentInfoContainer.addSubview(contentInfo)
    }
    
    func setTitleValues(){
        guard let titleAsset = self.adModel.asset(withType: "title"),
              let text = titleAsset.data["text"] as? String else { return }
        self.titleLabel.text = text
    }
    
    func setIconValues(){
        guard let iconAsset = self.adModel.asset(withType: "icon"),
              let width = iconAsset.data["w"] as? Double,
              let height = iconAsset.data["h"] as? Double,
              let url = iconAsset.data["url"] as? String else { return }

        widthIconlayoutConstraint.constant = width
        heightIconLayoutConstraint.constant = height
        
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.iconImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    func setRatingValues(){
        guard let ratingAsset = self.adModel.asset(withType: "rating"),
              let _ = ratingAsset.data["number"] as? Int else { return }
    }
    
    // MARK: Actions
    
    @IBAction func close(_ sender: Any) {
        self.removeFromSuperview()
    }
}


extension HyBidMRAIDCloseCardView: HyBidContentInfoViewDelegate {
    
    public func contentInfoViewWidthNeedsUpdate(_ width: NSNumber!) {
        
    }
}
