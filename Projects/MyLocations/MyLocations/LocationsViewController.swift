//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by 管君 on 9/11/18.
//  Copyright © 2018 管君. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchResult = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchResult.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchResult.sortDescriptors = [sortDescriptor]
        do {
            locations = try managedObjectContext.fetch(fetchResult)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let location = locations[indexPath.row]
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        }
        else {
            addressLabel.text = ""
        }
        return cell
    }
    
}
