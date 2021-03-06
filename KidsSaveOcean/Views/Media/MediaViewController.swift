//
//  MediaViewController.swift
//  KidsSaveOcean
//
//  Created by Maria Soboleva on 2/8/19.
//  Copyright © 2019 KidsSaveOcean. All rights reserved.
//

import UIKit

class MediaViewController: WebIntegrationViewController, Instantiatable, NotificationProtocol {
    var notificationTargets: [NotificationTarget] = [.newsAndMedia, .policyChange]
    
    override var originalWebUrlString: String {
        return "https://www.kidssaveocean.com/updates"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearNotifications()
    }
}

