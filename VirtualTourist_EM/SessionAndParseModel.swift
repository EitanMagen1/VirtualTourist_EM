//
//  SessionAndParseModel.swift
//  OnTheMap-EM1
//
//  Created by Lauren Efron on 14/01/2016.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation

class SessionAndParseModel {
    
    static let sheredInstance = SessionAndParseModel()

    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    
    // MARK: Initializers
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    /* Takes variable requests, client (udacity or parse) ,perform session, return result and  succesful respond to be parsed as completion handeler*/
    func sessionAndParseTask(request: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var parsedResult: AnyObject!
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: false, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    
                    completionHandler(result: nil, error: NSError(domain: "sessionAndParseTask", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Status code: \(response.statusCode)"]))
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")                    
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse JSONResponse */
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                          do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse JSON")
                }
                completionHandler(result: parsedResult, error: nil) // insert the data to the completion handeler
            })
        }
        
        task.resume()
        return task
    }
    
    
}
