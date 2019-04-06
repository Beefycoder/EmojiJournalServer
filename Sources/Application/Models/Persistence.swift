//
//  Persistence.swift
//  Application
//
//  Created by Pat Butler on 2019-03-25.
//

import Foundation
import SwiftKueryORM
import SwiftKueryPostgreSQL
import LoggerAPI

class Persistence {
    static func setUp() {
        let pool = PostgreSQLConnection.createPool(
            host: ProcessInfo.processInfo.environment["DBHOST"] ?? "localhost",
            port: 5432,
            options: [.databaseName("emojijournal"), .userName(ProcessInfo.processInfo.environment["DBUSER"] ?? "postgres"), .password(ProcessInfo.processInfo.environment["DBPASSWORD"] ?? "nil"), ], poolOptions: ConnectionPoolOptions(initialCapacity: 10,
                                                                                                                                                                                                                                          maxCapacity: 50, timeout: 1000) )
        Database.default = Database(pool)
        
        do {
            try UserJournalEntry.createTableSync()
        } catch let error {
            // Database table already exists
            if let requestError = error as? RequestError, requestError.rawValue == RequestError.ormQueryError.rawValue {
                Log.info("Table \(UserJournalEntry.tableName) already exists")
            } else {
                Log.error("Database connection error: " + "\(String(describing: error))")
            }
        }
        do {
            try UserAuth.createTableSync()
        } catch let error {
            //Database table already exists
            if let requestError = error as? RequestError, requestError.rawValue == RequestError.ormQueryError.rawValue {
                Log.info("Table \(UserAuth.tableName) already exists")
            } else {
                Log.error("Database connection error: " + "\(String(describing: error))")
            }
        }
    }
    
}
