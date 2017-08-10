//
//  DataController.swift
//  TwitterForwarder
//
//  Created by Danno on 7/14/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit
import CoreData

enum TweetStatus: Int {
    case onInternet = 0
    case offline = 1
}

protocol DataControllerDelegate: class {
    func dataController(_ dataController: DataController, didInsertTweet tweet: Tweet)
}

class DataController: NSObject {
    var username: String?
    weak var delegate: DataControllerDelegate?
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "TwitterForwarder")
        super.init()
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("An error occurred loading persistent store \(error)")
            }
        }
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Util methods 

private extension DataController {
    
    func findTweet(withId messageId: String, context: NSManagedObjectContext) -> Tweet? {
        do {
            let fetchRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "messageId == %@", messageId)
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Core Data error: \(error)")
            return nil
        }
    }
    
    func insertTweet(fromDictionary dictionary: [ String: Any ], context: NSManagedObjectContext) -> Tweet {
        let tweet = NSEntityDescription.insertNewObject(forEntityName: String(describing: Tweet.self), into: context) as! Tweet
        tweet.text = dictionary[PacketKeys.content] as? String
        let time = dictionary[PacketKeys.date] as! UInt64
        tweet.time = Double(time)
        tweet.own = false
        tweet.userId = dictionary[PacketKeys.sender] as? String
        let onlineSent = dictionary[PacketKeys.posted] as! Bool
        tweet.status = onlineSent ? .onInternet : .offline
        tweet.messageId  = dictionary[PacketKeys.id] as? String
        return tweet
    }
}

// MARK: - Client methods

extension DataController {
    
    func insertOwnTweet(withText text: String){
        persistentContainer.performBackgroundTask { context in
            context.automaticallyMergesChangesFromParent = true
            let tweet = NSEntityDescription.insertNewObject(forEntityName: String(describing: Tweet.self), into: context) as! Tweet
            tweet.text = text
            tweet.time = Date().timeIntervalSince1970
            tweet.own = true
            tweet.userId = self.username ?? ""
            tweet.status = TweetStatus.offline
            tweet.messageId  = UUID().uuidString
            self.saveContext(context: context)
            self.persistentContainer.viewContext.perform {
                let mainTweet = self.persistentContainer.viewContext.object(with: tweet.objectID) as! Tweet
                self.delegate?.dataController(self, didInsertTweet: mainTweet)
            }
        }
    }
    
    func processReceivedTweet(withDictionary dictionary: [ String: Any ] ) {
        self.persistentContainer.performBackgroundTask { context in
            context.automaticallyMergesChangesFromParent = true
            let tweet = self.findTweet(withId: dictionary[PacketKeys.id]! as! String, context: context)
            if let tweet = tweet {
                if tweet.status == .offline && dictionary[PacketKeys.posted] as! Bool {
                    tweet.status = .onInternet
                    self.saveContext(context: context)
                }
            } else {
                let tweet = self.insertTweet(fromDictionary: dictionary, context: context)
                self.saveContext(context: context)
                self.persistentContainer.viewContext.perform {
                    let mainTweet = self.persistentContainer.viewContext.object(with: tweet.objectID) as! Tweet
                    self.delegate?.dataController(self, didInsertTweet: mainTweet)
                }
            }
        }
    }
    
    func createFeedFetchedResultController() -> NSFetchedResultsController<Tweet> {
        let fetchRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Tweet.time), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: persistentContainer.viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            print("Error fetching blocked users: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func findPendingTweetsToPost() -> [Tweet] {
        let fetchRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Tweet.time), ascending: false)
        let rawStatus = TweetStatus.offline.rawValue
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "rawStatus == \(rawStatus)")
        fetchRequest.fetchLimit = 20
        do  {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            return results
            
        } catch {
            print("Error fetching blocked user result")
            return [Tweet]()
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        saveContext(context: context)
    }
    
    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}
