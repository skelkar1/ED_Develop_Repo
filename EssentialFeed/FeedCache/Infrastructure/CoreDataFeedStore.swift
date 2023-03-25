//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by sarika kelkar on 07/03/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrivalCompletion) {
//        completion(.empty)
//        let context = self.context
//        context.perform {
        perform{ context in
            do{
//                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
//                request.returnsObjectsAsFaults = false
//                if let cache = try context.fetch(request).first {
                if let cache = try ManagedCache.find(in: context) {
//                    completion(.found(feed: cache.feed
//                        .compactMap {$0 as? ManagedFeedImage}
//                        .map{
//                            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
//                        },
//                                      timestamp: cache.timestamp))
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }

            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
//        let context =  self.context
//        context.perform {
        perform{ context in
            do {
//                let managedCache = ManagedCache(context: context)
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
//                managedCache.feed = NSOrderedSet(array: feed.map{ local in
//                    let managed = ManagedFeedImage(context: context)
//                    managed.id = local.id
//                    managed.imageDescription = local.description
//                    managed.location = local.location
//                    managed.url = local.url
//                    return managed
//                })
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
                
            } catch {
                completion(error)
            }
        }
            
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
//        completion(nil)
//        let context = self.context
//        context.perform {
        perform{  context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}


