//
//  JournalEntry.swift
//  Application
//
//  Created by Pat Butler on 2019-03-22.
//

import Foundation
import KituraContracts
import SwiftKueryORM

struct JournalEntry: Model {
   var id: String?
   var emoji: String
   var date: Date
   var fortune: String?
   
   init(_ entry: UserJournalEntry) {
      self.id = entry.id
      self.emoji = entry.emoji
      self.date = entry.date
      self.fortune = entry.fortune
   }
   
   func save(for user: UserAuth, _ completion: @escaping(JournalEntry?, RequestError?) -> Void) -> Void {
      let complete = { (entry: UserJournalEntry?, error: RequestError?) -> Void in
         guard let entry = entry else {
            return completion(nil, error)
         }
         completion(JournalEntry(entry), error)
      }
      UserJournalEntry(self, for: user).save(using: Database.default, complete)
   }
   static func findAll(matching: JournalEntryParams?, for user: UserAuth, completion: @escaping ([JournalEntry]?, RequestError?) -> Void) -> Void {
      let complete = { (entries: [UserJournalEntry]?, error: RequestError?) -> Void in
         guard let entries = entries else {
            return completion(nil, error)
         }
         var journalEntries = [JournalEntry]()
         for entry in entries {
            journalEntries.append(JournalEntry(entry))
         }
         completion(journalEntries, error)
      }
      UserJournalEntry.findAll(using: Database.default, matching: UserJournalEntryParams(matching, for: user), complete)
   }
   static func delete(id: String, for user: UserAuth, completion: @escaping (RequestError?) -> Void) -> Void {
      let complete = { (entry: UserJournalEntry?, error: RequestError?) -> Void in
         guard let entry = entry else {
            return completion(error)
         }
         if entry.user != user.id {
            return completion(RequestError.forbidden)
         }
         UserJournalEntry.delete(id: id, completion)
      }
      UserJournalEntry.find(id: id, complete)
   }
   func update(id: String, for user: UserAuth, _ completion: @escaping (JournalEntry?, RequestError?) -> Void) -> Void {
      let findComplete = { (entry: UserJournalEntry? , error: RequestError?) -> Void in
         guard let entry = entry else {
            return completion(nil, error)
         }
         if entry.user != user.id {
            return completion(nil, RequestError.forbidden)
         }
         let updateComplete = { (entry: UserJournalEntry?, error: RequestError?) -> Void in
            guard let entry = entry else {
               return completion(nil, error)
            }
            completion(JournalEntry(entry), error)
         }
         UserJournalEntry(self, for: user).update(id: id, updateComplete)
      }
      UserJournalEntry.find(id: id, findComplete)
   }
   static func find(id: String, for user: UserAuth, _ completion: @escaping (JournalEntry?, RequestError?) -> Void) -> Void {
      let complete = { (entry: UserJournalEntry?, error: RequestError?) -> Void in
         guard let entry = entry else {
            return completion(nil, error)
         }
         if entry.user != user.id {
            return completion(nil, RequestError.forbidden)
         }
         return completion(JournalEntry(entry), nil)
      }
      UserJournalEntry.find(id: id, complete)
   }
   
   static func deleteAll(for user: UserAuth, _ completion: @escaping (RequestError?) -> Void) -> Void {
      UserJournalEntry.deleteAll(using: Database.default, matching: UserQuery(user), completion)
   }
}

struct JournalEntryParams: QueryParams {
   var emoji: String?
}

struct UserJournalEntry: Model {
   var id: String?
   var emoji: String
   var date: Date
   var user: String
   var fortune: String?
   
   init(_ journalEntry: JournalEntry, for user: UserAuth) {
      self.id = journalEntry.id
      self.emoji = journalEntry.emoji
      self.date = journalEntry.date
      self.user = user.id
      self.fortune = journalEntry.fortune
   }
}

struct UserQuery: QueryParams {
   let user: String
   init(_ user: UserAuth) {
      self.user = user.id
   }
}

struct UserJournalEntryParams: QueryParams {
   let user: String
   let emoji: String?
   
   init(_ query: JournalEntryParams?, for user: UserAuth) {
      self.user = user.id
      self.emoji = query?.emoji
   }
}
