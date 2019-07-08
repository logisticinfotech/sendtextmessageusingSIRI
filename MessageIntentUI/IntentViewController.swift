//
//  IntentViewController.swift
//  MessageIntentUI
//
//  Created by Krishna on 05/06/19.
//  Copyright © 2019 Krishna. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling, INUIHostedViewSiriProviding {
    
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var constLblMessageTop: NSLayoutConstraint!
    @IBOutlet weak var constLblMessageBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    // MARK: - INUIHostedViewControlling
    
    func configure(with interaction: INInteraction, context: INUIHostedViewContext, completion: @escaping (CGSize) -> Void) {
        
        let intent = interaction.intent as! INSendMessageIntent
        lblMessage.text = intent.content
        
        if intent.content == nil
        {
            constLblMessageTop.constant = 0
            constLblMessageBottom.constant = 0
        }
        else
        {
            constLblMessageTop.constant = 10
            constLblMessageBottom.constant = 10
        }
        
        viewMessage.layer.cornerRadius = 10
        self.viewMessage.layoutIfNeeded()
        let size = CGSize.init(width: lblMessage.frame.width + 50, height: lblMessage.frame.height + 80)
        completion(size)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    var displaysMessage: Bool{
        return true
    }
}
