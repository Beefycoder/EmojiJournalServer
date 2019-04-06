//
//  WebClientRoutes.swift
//  Application
//
//  Created by Pat Butler on 2019-03-26.
//

import Foundation
import LoggerAPI
import KituraStencil
import Kitura
import SwiftKueryORM

fileprivate extension UserJournalEntry {
   var displayDate: String {
      get{
         let formatter = DateFormatter()
         formatter.dateStyle = .long
         return formatter.string(from: self.date)
      }
   }
   
   var displayTime: String {
      get{
         let formatter = DateFormatter()
         formatter.timeStyle = .long
         return formatter.string(from: self.date)
      }
   }
   var backgroundColorCode: String {
      get {
         guard let substring = id?.suffix(6).uppercased() else {
            return "000000"
         }
         return substring
      }
   }
}

struct JournalEntryWeb: Codable {
   var id: String?
   var emoji: String
   var date: Date
   var displayDate: String
   var displayTime: String
   var backgroundColorCode: String
   var user: String
}

func initializeWebClientRoutes(app: App) {
   app.router.setDefault(templateEngine: StencilTemplateEngine())
   app.router.all(middleware: StaticFileServer(path: "./public"))
   app.router.get("/client", handler: showClient)
   Log.info("Web client routes created")
}

func showClient(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
   UserJournalEntry.findAll(using: Database.default) { entries, error in
      guard let entries = entries else {
         response.status(.serviceUnavailable).send(json: ["Message": "Service unavailable" + "\(String(describing: error?.localizedDescription))"])
         return
      }
      var sortedEntries = entries.sorted(by: { $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970
      })
      if let username = request.cookies["username"]?.value, !username.isEmpty {
         sortedEntries = sortedEntries.filter { $0.user == username }
         
      }
      var webEntries = [JournalEntryWeb]()
      for entry in sortedEntries {
         webEntries.append(JournalEntryWeb(id: entry.id, emoji: entry.emoji, date: entry.date, displayDate: entry.displayDate, displayTime: entry.displayTime, backgroundColorCode: entry.backgroundColorCode, user: entry.user))
      }
      do {
         try response.render("home.stencil", with: webEntries, forKey: "entries")
      } catch let error {
         response.status(.internalServerError).send(error.localizedDescription)
      }
   }
   
}
