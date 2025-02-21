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

private enum BeaconsFilterScopeType: String, CaseIterable {
    case type = "type"
    case url = "url"
    case js = "js"
}

private struct DictionaryKeyList {
    static let type = "type"
    static let data = "data"
    static let vast2 = "vast2"
    static let url = "url"
    static let js = "js"
}

class BeaconsViewController: UIViewController {
    
    @IBOutlet weak var beaconsTableView: UITableView!
    @IBOutlet weak var beaconsNumberLabel: UILabel!
    
    private let vastParser = HyBidVASTParser()
    private var ad: HyBidAd? = HyBidAd()
    private let vastZoneID = "6"
    private let beaconsTextListSegueIdentifier = "goingToBeaconsListText"
    private var beaconsBeforeRendering = [HyBidDataModel]()
    private let searchController = UISearchController(searchResultsController: nil)
    private let filterScope = BeaconsFilterScopeType.allCases.map { return $0.rawValue }
    private var beacons : [HyBidDataModel] = [] {
        didSet {
            self.beaconsFiltered = beacons
        }
    }
    private let cellIdentifier = "BeaconTableViewCell"
    private var beaconsFiltered : [HyBidDataModel] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.beaconsTableView.reloadData()
                self.beaconsNumberLabel.text = "Number of beacons: \(beaconsFiltered.count)"
                self.beaconsNumberLabel.accessibilityIdentifier = "numberOfBeaconsLabel"
                self.beaconsNumberLabel.accessibilityLabel = "numberOfBeaconsLabel"
                self.beaconsNumberLabel.accessibilityValue = "\(beaconsFiltered.count)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beaconsTableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        setAdBeaconsList()
        setSearchController()
    }
    
    private func setSearchController() {
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        
        searchController.searchBar.scopeButtonTitles = filterScope

        navigationItem.searchController = searchController
        navigationController?.title = "Beacons"
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func cleanValues() {
        self.vastParser.vastArray.removeAllObjects()
        self.beaconsBeforeRendering.removeAll()
        self.beacons.removeAll()
        self.beaconsFiltered.removeAll()
    }
    
    private func setAdBeaconsList() {
        self.cleanValues()
        guard let lastRequest = PNLiteRequestInspector.sharedInstance().lastInspectedRequest,
              let lastResponse = lastRequest.response else { return }
                
        //case last response is an API V3 response
        if let data = lastResponse.data(using: .utf8, allowLossyConversion: false),
           let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String,Any>,
           let responseModel = PNLiteResponseModel(dictionary: responseDictionary),
           let ads = responseModel.ads,
           let ad = ads.first as? HyBidAdModel {
            
            if let adBeacons = ad.beacons, !adBeacons.isEmpty {
                self.beaconsBeforeRendering = adBeacons.map { return dataModelWith(type: $0.type, url: $0.url, js: $0.js) }
                self.beaconsBeforeRendering.sort { $0.type == $1.type ? ($0.url ?? $0.js < $1.url ?? $1.js) : $0.type < $1.type }
                self.beacons = self.beaconsBeforeRendering
                self.updateSearchResults(for: self.searchController)
            }
            
            if let assets = ad.assets as? Array<HyBidDataModel>,
               let asset: HyBidDataModel = assets.first,
               let data = asset.data as? Dictionary<String, Any>,
               let vastString = data[DictionaryKeyList.vast2] as? String,
               !vastString.isEmpty {
                setVASTTrackersFrom(vastString: vastString, adModel: ad) { [weak self] in
                    guard let self else { return }
                    self.beaconsBeforeRendering.sort {
                        $0.type == $1.type ? ($0.url ?? $0.js < $1.url ?? $1.js) : $0.type < $1.type
                    }
                    self.beacons = self.beaconsBeforeRendering
                    self.updateSearchResults(for: self.searchController)
                }
            }
        } else { //case last response is a VAST XML
            setVASTTrackersFrom(vastString: lastResponse) { [weak self] in
                guard let self else { return }
                self.beaconsBeforeRendering.sort { $0.type == $1.type ? ($0.url ?? $0.js < $1.url ?? $1.js) : $0.type < $1.type }
                self.beacons.append(contentsOf: beaconsBeforeRendering)
                self.updateSearchResults(for: self.searchController)
            }
        }
    }
    
    private func setFiredBeaconsList() {
        self.cleanValues()
        let beacons: [HyBidReportingBeacon] = HyBidReportingManager.sharedInstance.beacons
        let vastTrackers: [HyBidReportingVASTTracker] = HyBidReportingManager.sharedInstance.vastTrackers
        
        let beaconsModel: [HyBidDataModel] = beacons.map { return HyBidDataModel(dictionary: $0.properties) }
        let vastTrackersModel: [HyBidDataModel] = vastTrackers.map { return HyBidDataModel(dictionary: $0.properties) }
        
        var allBeacons = beaconsModel + vastTrackersModel
        allBeacons = allBeacons.map { return dataModelWith(type: $0.type, url: $0.url, js: $0.js) }
        allBeacons.sort { $0.type == $1.type ? ($0.url ?? $0.js < $1.url ?? $1.js) : $0.type < $1.type }
        
        self.beacons = allBeacons
        self.updateSearchResults(for: searchController)
    }
    
    private func getBeaconsListString() -> String? {
        let beaconsCodableValues = self.beaconsFiltered.map { return [($0.type as String) : ($0.url ?? $0.js)] }
        
        guard !beaconsCodableValues.isEmpty,
              let data = try? JSONEncoder().encode(beaconsCodableValues),
              let stringData = String(data: data, encoding: .utf8),
              !stringData.isEmpty else { return nil }
        
        return stringData
    }
    
    @IBAction func copyBeaconsToClipboard(_ sender: Any) {
        guard let beaconsListString = getBeaconsListString() else { return }
        UIPasteboard.general.string = beaconsListString
    }
    
    @IBAction func changingBeaconsList(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setAdBeaconsList()
        } else {
            setFiredBeaconsList()
        }
    }
    
    @IBAction func dismissButtonTouchUpInside(_ sender: UIButton) {
        searchController.dismiss(animated: true)
        self.dismiss(animated: true)
    }
    
    private func setVASTTrackersFrom(vastString: String, adModel: HyBidAdModel? = nil, completion:@escaping () -> ()) {

        let vastData = vastString.data(using: .utf8)
        self.vastParser.parse(with: vastData) { [weak self] model, error in
            
            guard let self else { return completion() }
            
            if let adModel = adModel { self.ad = HyBidAd(data: adModel, withZoneID: self.vastZoneID) }
            
            guard let vastParserArray = self.vastParser.vastArray as? Array<Data> else { return completion() }
            let vastOrderedSet: NSOrderedSet = NSOrderedSet(array: vastParserArray)
            guard let vastArrayData = vastOrderedSet.array as? Array<Data> else { return completion() }
            
            self.setTrackingEvents(vastArray: vastArrayData)
            self.fetchEndCards(vastArray: vastArrayData)
            completion()
        }
    }
    
    private func setTrackingEvents(vastArray: Array<Data>) {
        if vastArray.isEmpty { return }
        
        for vast in vastArray {
            let xml = String(data: vast, encoding: .utf8)
            guard let parser = HyBidXMLEx.parser(withXML: xml),
                  let rootElement = parser.rootElement(),
                  let results = rootElement.query("Ad") else { continue }
            
            for result in results {
                guard let xmlElement = result as? HyBidXMLElementEx,
                      let ad = HyBidVASTAd(xmlElement: xmlElement) else { continue }
                
                if let wrapper = ad.wrapper() {
                    processCreatives(creatives: wrapper.creatives())
                    guard let impressions = wrapper.impressions() else { continue }
                    
                    for impression in impressions {
                        guard let url = impression.url(), !url.isEmpty else { continue }
                        let vastTracker = dataModelWith(type: VASTTrackerType.IMPRESSION, url: url)
                        self.beaconsBeforeRendering.append(vastTracker)
                    }
                } else if let inLine = ad.inLine() {
                    processCreatives(creatives: inLine.creatives())
                    guard let impressions = inLine.impressions() else { continue }
                    
                    for impression in impressions {
                        guard let url = impression.url(), !url.isEmpty else { continue }
                        let vastTracker = dataModelWith(type: VASTTrackerType.IMPRESSION, url: url)
                        self.beaconsBeforeRendering.append(vastTracker)
                    }
                }
            }
        }
    }
    
    private func processCreatives(creatives: Array<HyBidVASTCreative>) {
        
        for creative in creatives {

            let linear = creative.linear()
            
            if let linear = linear, let trackingObject = linear.trackingEvents(), let trackingEvents = trackingObject.events() {
                for tracking in trackingEvents {
                    guard let event = tracking.event(), 
                          let url = tracking.url() else { return }
                    let dataModel = dataModelWith(type: event, url: url)
                    self.beaconsBeforeRendering.append(dataModel)
                }
            }
            
            if let companionAds = creative.companionAds() {
                if (self.ad?.endcardEnabled != nil && self.ad?.endcardEnabled.boolValue ?? false) || (self.ad?.endcardEnabled == nil && HyBidConstants.showEndCard) {
                    for companion in companionAds.companions() {
                        guard let trackingEvents = companion.trackingEvents(),
                              let events = trackingEvents.events() else { continue }
                        
                        for tracking in events {
                            guard let event = tracking.event(),
                                  let url = tracking.url() else { continue }
                            let dataModel = dataModelWith(type: event, url: url)
                            self.beaconsBeforeRendering.append(dataModel)
                        }
                    }
                }
            }
            
            if let linear = linear, let videoClicksObject = linear.videoClicks() {
                for clickTracking in videoClicksObject.clickTrackings() {
                    guard let content = clickTracking.content() else { return }
                    if content.count != 0 {
                        let vastTracker = dataModelWith(type: VASTTrackerType.CLICK_TRACKING, url: content)
                        self.beaconsBeforeRendering.append(vastTracker)
                    }
                }
            }
        }
    }
    
    private func fetchEndCards(vastArray: Array<Data>) {
        parseCompanionsFromArray(vastArray: vastArray)
    }
    
    private func parseCompanionsFromArray(vastArray: Array<Data>) {
        for vast in vastArray {
            let xml = String(data: vast, encoding: .utf8)
            guard let parser = HyBidXMLEx.parser(withXML: xml),
                  let rootElement = parser.rootElement(),
                  let results = rootElement.query("Ad") else { continue }
            for result in results {
                guard let ad = result as? HyBidVASTAd else { continue }
                
                if let wrapper = ad.wrapper() {
                    guard let creatives = wrapper.creatives() else { continue }
                    for creative in creatives {
                        if let companionAds = creative.companionAds() {
                            for companion in companionAds.companions() {
                                guard let companionClickThrougContent = companion.companionClickThrough().content() else { continue }
                                let vastTracker = dataModelWith(type: VASTTrackerType.COMPANION_CLICK_THROUGH, url: companionClickThrougContent)
                                self.beaconsBeforeRendering.append(vastTracker)
                            }
                        }
                    }
                } else if let inLine = ad.inLine() {
                    guard let creatives = inLine.creatives() else { continue }
                    for creative in creatives {
                        if let companionAds = creative.companionAds() {
                            for companion in companionAds.companions() {
                                guard let companionClickThrougContent = companion.companionClickThrough().content() else { continue }
                                let vastTracker = dataModelWith(type: VASTTrackerType.COMPANION_CLICK_THROUGH, url: companionClickThrougContent)
                                self.beaconsBeforeRendering.append(vastTracker)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func dataModelWith(type: String, url: String? = .none, js: String? = .none) -> HyBidDataModel {
        var properties: Dictionary<String,Any> = Dictionary()
        properties[DictionaryKeyList.type] = type.firstCapitalized
        properties[DictionaryKeyList.data] = Dictionary<String, Dictionary<String, String>> ()
        if var data = properties[DictionaryKeyList.data] as? Dictionary<String, String> {
            data[DictionaryKeyList.url] = url
            data[DictionaryKeyList.js] = js
            
            properties[DictionaryKeyList.data] = data
        }
        
        return HyBidDataModel(dictionary: properties)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              identifier == beaconsTextListSegueIdentifier,
              let beaconsListTextVC = segue.destination as? BeaconsTextListViewController,
              let beaconsListString = getBeaconsListString() else { return }
        
        beaconsListTextVC.beaconsListText = beaconsListString
    }
}

extension BeaconsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beaconsFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BeaconTableViewCell else { return UITableViewCell() }
        
        if indexPath.row >= self.beaconsFiltered.count { return cell }
        let beacon = self.beaconsFiltered[indexPath.row]
        cell.setBeacon(beacon: beacon)
        cell.accessoryType = .detailButton
        cell.beaconContentTextView.accessibilityIdentifier = "beaconTextView\(indexPath.row + 1)"
        cell.beaconContentTextView.accessibilityLabel = "beaconTextView\(indexPath.row + 1)"
        cell.beaconContentTextView.accessibilityValue = beacon.url ?? beacon.js ?? .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let beacon = self.beaconsFiltered[indexPath.row]
        UIPasteboard.general.string = beacon.url ?? beacon.js
    }
}

extension BeaconsViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate  {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            self.beaconsFiltered = self.beacons
            return
        }
        
        let keyIndex = searchController.searchBar.selectedScopeButtonIndex
        guard let key: BeaconsFilterScopeType = BeaconsFilterScopeType(rawValue: filterScope[keyIndex]) else {
            return self.beaconsFiltered.removeAll()
        }
        
        switch key {
        case .type:
            self.beaconsFiltered = self.beacons.filter { 
                return $0.type?.lowercased().contains(searchText.lowercased()) ?? false }
        case .url:
            self.beaconsFiltered = self.beacons.filter { 
                return $0.url?.lowercased().contains(searchText.lowercased()) ?? false }
        case .js:
            self.beaconsFiltered = self.beacons.filter { 
                return $0.js?.lowercased().contains(searchText.lowercased()) ?? false }
        }
    }
}

extension StringProtocol {
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
