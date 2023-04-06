//
//  ActivityViewController.swift
//  Quotely
//
//  Created by Brilliant Gamez on 9/15/22.
//

import Foundation
import UIKit

class ActivityViewController : UIViewController {

    var uiImage:UIImage!

    @objc func shareImage() {
        let vc = UIActivityViewController(activityItems: [uiImage!], applicationActivities: [])
        vc.excludedActivityTypes =  [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        present(vc,
                animated: true,
                completion: nil)
        vc.popoverPresentationController?.sourceView = self.view
    }
}
