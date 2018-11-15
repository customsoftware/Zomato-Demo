//
//  SearchResultsTableViewController.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    let detailSegueID = "showRestaurantDetail"
    let userInfoRestaurantKey = "restaurant"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = ZomatoRestarauntManager.shared
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier else { return }
        switch segueID {
        case detailSegueID:
            if let detailVC = segue.destination as? RestaurantDetailsViewController,
                let userInfo = sender as? [String: Any],
                let selectedRestaurant = userInfo[userInfoRestaurantKey] as? ZomatoRestaraunt {
                detailVC.displayedRestaurant = selectedRestaurant
            }
            
        default:()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRestaurant = ZomatoRestarauntManager.shared.restarauntList[indexPath.row]
        var userInfo = [String: Any]()
        userInfo[userInfoRestaurantKey] = selectedRestaurant
        performSegue(withIdentifier: detailSegueID, sender: userInfo)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class RestarauntSummaryCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    var owningRestaraunt: ZomatoRestaraunt? {
        didSet {
            guard let owningRestaraunt = owningRestaraunt else { return }
            name.text = owningRestaraunt.name ?? "Not set"
            address.text = owningRestaraunt.cuisines ?? "None stated"
            rating.text = "\(owningRestaraunt.user_rating?.aggregate_rating ?? 0)"
            rating.layer.borderColor = UIColor.darkGray.cgColor
            rating.layer.borderWidth = 1.03
            rating.backgroundColor = owningRestaraunt.user_rating?.color
        }
    }
}
