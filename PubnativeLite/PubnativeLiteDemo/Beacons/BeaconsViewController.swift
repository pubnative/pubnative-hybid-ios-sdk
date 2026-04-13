//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

private enum BeaconsFilterScopeType: String, CaseIterable {
    case type = "type"
    case url = "url"
    case js = "js"
}

class BeaconsViewController: UIViewController {

    @IBOutlet weak var beaconsTableView: UITableView!
    @IBOutlet weak var beaconsNumberLabel: UILabel!

    private let beaconsTextListSegueIdentifier = "goingToBeaconsListText"
    private let searchController = UISearchController(searchResultsController: nil)
    private let filterScope = BeaconsFilterScopeType.allCases.map { $0.rawValue }
    private var beacons: [HyBidBeaconItem] = [] {
        didSet {
            beaconsFiltered = beacons
        }
    }
    private let cellIdentifier = "BeaconTableViewCell"
    private var selectedSegmentIndex = 0
    private var beaconsFiltered: [HyBidBeaconItem] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.beaconsTableView.reloadData()
                self.beaconsNumberLabel.text = "Number of beacons: \(self.beaconsFiltered.count)"
                self.beaconsNumberLabel.accessibilityIdentifier = "numberOfBeaconsLabel"
                self.beaconsNumberLabel.accessibilityLabel = "numberOfBeaconsLabel"
                self.beaconsNumberLabel.accessibilityValue = "\(self.beaconsFiltered.count)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        beaconsTableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        setSearchController()
        setAdBeaconsList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedSegmentIndex == 0 {
            setAdBeaconsList()
        }
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
        beacons = []
        beaconsFiltered = []
    }

    private func setAdBeaconsList() {
        cleanValues()
        HyBidBeaconsInspector.shared.adBeaconsFromLastResponse { [weak self] items in
            guard let self else { return }
            DispatchQueue.main.async {
                self.beacons = items
                self.updateSearchResults(for: self.searchController)
            }
        }
    }

    private func setFiredBeaconsList() {
        cleanValues()
        let items = HyBidBeaconsInspector.shared.firedBeacons()
        beacons = items
        updateSearchResults(for: searchController)
    }

    private func getBeaconsListString() -> String? {
        let beaconsCodableValues = beaconsFiltered.map { [$0.type: $0.content] }
        guard !beaconsCodableValues.isEmpty,
              let data = try? JSONEncoder().encode(beaconsCodableValues),
              let stringData = String(data: data, encoding: .utf8),
              !stringData.isEmpty else { return nil }
        return stringData
    }

    @IBAction func copyBeaconsToClipboard(_ sender: Any) {
        let beaconsListString = getBeaconsListString() ?? "No beacons to copy"
        UIPasteboard.general.string = beaconsListString
        // Feedback so user knows copy ran (helps in Simulator where paste might be in another app)
        let message = beaconsListString != "No beacons to copy" ? "Beacons copied to clipboard." : "No beacons to copy."
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func changingBeaconsList(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        if sender.selectedSegmentIndex == 0 {
            setAdBeaconsList()
        } else {
            setFiredBeaconsList()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed || isMovingFromParent {
            HyBid.reportingManager().clearAllReports()
        }
    }

    @IBAction func dismissButtonTouchUpInside(_ sender: UIButton) {
        searchController.dismiss(animated: true)
        dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              identifier == beaconsTextListSegueIdentifier,
              let beaconsListTextVC = segue.destination as? BeaconsTextListViewController,
              let beaconsListString = getBeaconsListString() else { return }
        beaconsListTextVC.beaconsListText = beaconsListString
    }
}

// MARK: - Table view
extension BeaconsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        beaconsFiltered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BeaconTableViewCell else {
            return UITableViewCell()
        }
        if indexPath.row >= beaconsFiltered.count { return cell }
        let beacon = beaconsFiltered[indexPath.row]
        cell.setBeacon(beacon)
        cell.accessoryType = .detailButton
        cell.beaconContentTextView.accessibilityIdentifier = "beaconTextView\(indexPath.row + 1)"
        cell.beaconContentTextView.accessibilityLabel = "beaconTextView\(indexPath.row + 1)"
        cell.beaconContentTextView.accessibilityValue = beacon.content
        return cell
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let beacon = beaconsFiltered[indexPath.row]
        UIPasteboard.general.string = beacon.content
    }
}

// MARK: - Search
extension BeaconsViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            beaconsFiltered = beacons
            return
        }
        let keyIndex = searchController.searchBar.selectedScopeButtonIndex
        guard let key = BeaconsFilterScopeType(rawValue: filterScope[keyIndex]) else {
            beaconsFiltered = []
            return
        }
        switch key {
        case .type:
            beaconsFiltered = beacons.filter { $0.type.lowercased().contains(searchText.lowercased()) }
        case .url:
            beaconsFiltered = beacons.filter { ($0.url ?? "").lowercased().contains(searchText.lowercased()) }
        case .js:
            beaconsFiltered = beacons.filter { ($0.js ?? "").lowercased().contains(searchText.lowercased()) }
        }
    }
}
