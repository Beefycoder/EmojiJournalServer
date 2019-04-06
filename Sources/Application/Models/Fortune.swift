//
//  Fortune.swift
//  Application
//
//  Created by Pat Butler on 2019-03-27.
//

import Foundation
import SwiftyRequest
import LoggerAPI
import CircuitBreaker

struct Fortune : Codable {
   
   let fortune : String?
   
   enum CodingKeys: String, CodingKey {
      case fortune = "fortune"
   }
   
   init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      fortune = try values.decodeIfPresent(String.self, forKey: .fortune)
   }
   
}

class FortuneClient {
   private static var baseURL: String {
      return ProcessInfo.processInfo.environment["FORTUNESERVER"] ?? "http://yerkee.com"
   }
   private static var fortuneURL: String {
      return "\(baseURL)/api/fortune/all"
   }
   
   public static func getFortune(completion: @escaping (String?) -> Void) {
      let errorFortune = "No fortune is good fortune"
      let errorFallback = {
         (error: BreakerError, msg: String) -> Void in
         Log.error("FortuneClient fallback with \(error)")
         return completion(errorFortune)
      }
      let circuitParameters = CircuitParameters(timeout: 2000, maxFailures: 2, rollingWindow: 5000, fallback: errorFallback)
      let request = RestRequest(method: .get, url: fortuneURL)
      request.circuitParameters = circuitParameters
      request.responseObject() {
         (response: RestResponse<Fortune>) in
         switch response.result {
         case .success(let result):
            let fortune = result.fortune
            return completion(fortune)
         case .failure(let error):
            Log.error("FortuneClient request failed with \(error)")
            return completion(errorFortune)
         }
      }
   }
}
