//
//  IntentHandler.swift
//  MessageIntent
//
//  Created by Krishna on 05/06/19.
//  Copyright © 2019 Krishna. All rights reserved.
//

import Intents
import Contacts
import UIKit

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            self.searchContact(recipients: recipients) { (finalRecipients) in
                
                // If no recipients were provided we'll need to prompt for a value.
                if finalRecipients == nil {
                    completion([INSendMessageRecipientResolutionResult.needsValue()])
                    return
                }
                if finalRecipients?.count == 0 {
                    completion([INSendMessageRecipientResolutionResult.needsValue()])
                    return
                }
                
                var resolutionResults = [INSendMessageRecipientResolutionResult]()
                
                // Implement your contact matching logic here to create an array of matching contacts
               
                switch finalRecipients!.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    
                    if intent.recipients![0].siriMatches == nil
                    {
                        resolutionResults += [INSendMessageRecipientResolutionResult.success(with: intent.recipients![0])]
                    }
                    else
                    {
                        resolutionResults += [INSendMessageRecipientResolutionResult.disambiguation(with: finalRecipients!)]
                    }
                    
                case 1:
                    // We have exactly one matching contact
                    resolutionResults += [INSendMessageRecipientResolutionResult.success(with: finalRecipients![0])]
                    
                case 0:
                    // We have no contacts matching the description provided
                    resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]
                    
                default:
                    break
                    
                }
                completion(resolutionResults)
            }
        }
    }

    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required).
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
                
        let dictMessage = NSMutableDictionary()
        dictMessage.setObject(intent.content!, forKey: "message" as NSCopying)
        dictMessage.setObject(intent.recipients![0].displayName, forKey: "recipient" as NSCopying)
        UserDefaults(suiteName: "group.logistic.test")?.set(dictMessage, forKey: "dictMessage")
        completion(response)
    }

    func searchContact(recipients : [INPerson], completionHandler: @escaping ([INPerson]?) -> Void)
    {
        let contactStore = CNContactStore()
        
        var finalContacts = [INPerson]()
        if recipients.count == 0
        {
            completionHandler(nil)
            return
        }
        for objRecipient in recipients
        {
            do {
                let predicate = CNContact.predicateForContacts(matchingName: objRecipient.displayName)
                let filteredContacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor])
                
                for objContact in filteredContacts
                {
                    if let objFilterContact = (recipients.filter{ ($0.displayName == objContact.givenName || $0.displayName == objContact.familyName || $0.displayName == objContact.middleName)}).first
                    {
                        finalContacts.append(objFilterContact)
                    }
                }
                completionHandler(finalContacts)
                
            }
            catch {
                print("unable to fetch contacts")
                completionHandler(nil)
            }
        }
    }
}
