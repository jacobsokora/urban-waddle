//
//  Restaurant+CoreDataClass.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/27/18.
//  Copyright © 2018 waddlers. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation
import UIKit

public class Restaurant: NSManagedObject {
    public enum Status: Int16 {
        case uninterested = 0
        case interested = 1
        case disliked = 2
        case liked = 3
    }

    @NSManaged public var name: String
    @NSManaged public var note: String?
    @NSManaged public var yelpId: String
    @NSManaged public var yelpPrice: String?
    @NSManaged public var yelpRating: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var phoneNumber: String?
    public var rawStatus: Int16 {
        get {
            willAccessValue(forKey: "rawStatus")
            defer { didAccessValue(forKey: "rawStatus") }
            
            return primitiveValue(forKey: "rawStatus") as! Int16
        }
        set {
            willChangeValue(forKey: "rawStatus")
            defer { didChangeValue(forKey: "rawStatus") }

            setPrimitiveValue(newValue, forKey: "rawStatus")
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: rawStatus) ?? .uninterested
        }
        set {
            rawStatus =  newValue.rawValue
        }
    }
    
    @nonobjc func loadData(from yelpRestaurant: YelpRestaurant, with status: Status) {
        loadData(from: yelpRestaurant, with: status, note: nil)
    }
    
    @nonobjc func loadData(from yelpRestaurant: YelpRestaurant, with status: Status, note: String?) {
        self.status = status
        self.name = yelpRestaurant.name
        self.note = note
        self.yelpId = yelpRestaurant.id
        self.yelpPrice = yelpRestaurant.price ?? ""
        self.yelpRating = yelpRestaurant.rating
        self.latitude = yelpRestaurant.coordinates.latitude
        self.longitude = yelpRestaurant.coordinates.longitude
        self.phoneNumber = yelpRestaurant.phone
    }
    
    @nonobjc func distance(to: CLLocation) -> Double {
        let fromLocation = CLLocation(latitude: latitude, longitude: longitude)
        return to.distance(from: fromLocation)
    }
    
    @nonobjc static func add(restaurant: YelpRestaurant, status: Restaurant.Status) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSOverwriteMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Restaurant", in: context)
        let data = Restaurant(entity: entity!, insertInto: context)
        data.loadData(from: restaurant, with: status)
        do {
            try context.save()
        } catch {
            print("Failed to add restaurant: \(error.localizedDescription)")
        }
    }
    
    @nonobjc static func remove(restaurant yelpRestaurant: YelpRestaurant) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.mergePolicy = NSOverwriteMergePolicy
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.yelpId == yelpRestaurant.id {
                    context.delete(restaurant)
                    try context.save()
                    return
                }
            }
        } catch {
            print("Failed to delete restaurant: \(error.localizedDescription)")
        }
    }
    
    @nonobjc static func getAllInterestedRestaurants() -> [Restaurant] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants = [Restaurant]()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.status != .uninterested {
                    restaurants.append(restaurant)
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func getAllNonInterestedRestaurants() -> [Restaurant] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants = [Restaurant]()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.status == .uninterested {
                    restaurants.append(restaurant)
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func getAllSavedIds() -> [String] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurantIds = [String]()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                restaurantIds.append(restaurant.yelpId)
            }
        } catch {
            print("Failed to load data")
        }
        return restaurantIds
    }
}
