//
//  SearchResultsTableViewController.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = ZomatoRestarauntManager.shared
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier else { return }
        switch segueID {
        case ZomatoResources.Keys.detailSegueID:
            if let detailVC = segue.destination as? RestaurantDetailsViewController,
                let userInfo = sender as? [String: Any],
                let selectedRestaurant = userInfo[ZomatoResources.Keys.userInfoRestaurantKey] as? ZomatoRestaraunt {
                detailVC.displayedRestaurant = selectedRestaurant
                setBackButtonText(to: ZomatoResources.Strings.navigateBackButton)
            }
            
        default:()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRestaurant = ZomatoRestarauntManager.shared.restarauntList[indexPath.row]
        var userInfo = [String: Any]()
        userInfo[ZomatoResources.Keys.userInfoRestaurantKey] = selectedRestaurant
        performSegue(withIdentifier: ZomatoResources.Keys.detailSegueID, sender: userInfo)
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
            name.text = owningRestaraunt.name ?? ZomatoResources.Strings.defaultNotSet
            address.text = owningRestaraunt.cuisines ?? ZomatoResources.Strings.defaultNoneStated
            rating.text = "\(owningRestaraunt.user_rating?.aggregate_rating ?? 0)"
            rating.layer.borderColor = UIColor.darkGray.cgColor
            rating.layer.borderWidth = 1.03
            rating.backgroundColor = owningRestaraunt.user_rating?.color
        }
    }
}
