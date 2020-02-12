//
//  FavoritesViewController.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/7/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit

class FavoritesViewController: UITableViewController {
    
    var placeNames: [String] = []

    weak var delegate: PlacesFavoritesDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceName", for: indexPath)
        cell.textLabel?.text = placeNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Send the information about the tapped cell to the MapViewController using a custom protocol and delegate.
        delegate?.favoritePlace(name: placeNames[indexPath.row])
        // Dismiss the FavoritesViewController
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: { })
    }
    
}

