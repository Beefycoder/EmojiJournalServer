//
//  UserRoutes.swift
//  Application
//
//  Created by Pat Butler on 2019-03-26.
//

import Foundation
import LoggerAPI
import Kitura

func initializeUserRoutes(app: App) {
    app.router.post("/user", handler: addUser)
    app.router.delete("/user", handler: deleteUser)
    Log.info("User routes created.")
}

func addUser(user: UserAuth, completion: @escaping (UserAuth?, RequestError?) -> Void) {
    user.save(completion)
}
func deleteUser(user: UserAuth, id: String, completion: @escaping (RequestError?) -> Void) {
    if user.id != id {
        completion(RequestError.forbidden)
    }
   JournalEntry.deleteAll(for: user) { error in
      if let error = error {
         return completion (error)
      }
      return UserAuth.delete(id: id, completion)
   }
}
