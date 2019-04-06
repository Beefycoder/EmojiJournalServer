//
//  EntryRoutes.swift
//  Application
//
//  Created by Pat Butler on 2019-03-22.
//

import Foundation
import LoggerAPI
import KituraContracts

enum DateError: String, Error {
   case invalidDate
}

let journalEntryDecoder: () -> BodyDecoder = {
   let decoder = JSONDecoder()
   decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
   let container = try decoder.singleValueContainer()
   let dateNum = try? container.decode(Double.self)
   if let dateNum = dateNum, let timeInterval = TimeInterval(exactly: dateNum) {
      let dateValue = Date(timeIntervalSinceReferenceDate: timeInterval)
      return dateValue
   }
   guard let dateStr = try? container.decode(String.self) else {
      throw DateError.invalidDate
   }
   let formatter = DateFormatter()
   formatter.calendar = Calendar(identifier: .iso8601)
   formatter.locale = Locale(identifier: "en_US_POSIX")
   formatter.timeZone = TimeZone(secondsFromGMT: 0)
   formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
   if let date = formatter.date(from: dateStr) {
      return date
      }
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
      if let date = formatter.date(from: dateStr) {
         return date
      }
      throw DateError.invalidDate
   })
   return decoder
}

func initializeEntryRoutes(app:App) {
    app.router.post("/entries", handler: addEntry)
    app.router.get("/entries", handler: getEntries)
    app.router.delete("/entries", handler: deleteEntry)
    app.router.put("/entries", handler: modifyEntry)
    app.router.get("/entries", handler: getOneEntry)
    app.router.decoders[.json] = journalEntryDecoder
    Log.info("Journal entry routes created")
}

func addEntry(user: UserAuth, entry: JournalEntry, completion: @escaping (JournalEntry?, RequestError?) -> Void) {
   
   FortuneClient.getFortune() { fortune in
      var savedEntry = entry
      savedEntry.id = UUID().uuidString
      savedEntry.fortune = fortune
      savedEntry.save(for: user, completion)
   }
}

func getEntries(user: UserAuth, query: JournalEntryParams?, completion: @escaping ([JournalEntry]?, RequestError?) -> Void) -> Void {
   JournalEntry.findAll(matching: query, for: user, completion: completion)
}

func deleteEntry(user: UserAuth, id: String, completion: @escaping (RequestError?) -> Void) {
   JournalEntry.delete(id: id, for: user, completion: completion)
}

func modifyEntry(user: UserAuth, id: String, entry: JournalEntry, completion: @ escaping (JournalEntry?, RequestError?) -> Void) {
   entry.update(id: id, for: user, completion)
}

func getOneEntry(user: UserAuth, id: String, completion: @ escaping (JournalEntry?, RequestError?) -> Void) {
   JournalEntry.find(id: id, for: user, completion)
}
