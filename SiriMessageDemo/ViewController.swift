//
//  ViewController.swift
//  SiriMessageDemo
//
//  Created by Krishna on 03/06/19.
//  Copyright © 2019 Krishna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblRecipientName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(setMessageValue), name: NSNotification.Name(rawValue: "MessageSent"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setMessageValue()
    {
        if let dictMessage = UserDefaults(suiteName: "group.logistic.test")?.object(forKey: "dictMessage")
        {
            lblMsg.text = (dictMessage as! NSDictionary).object(forKey: "message") as? String
            lblRecipientName.text = (dictMessage as! NSDictionary).object(forKey: "recipient") as? String
        }
    }
}

