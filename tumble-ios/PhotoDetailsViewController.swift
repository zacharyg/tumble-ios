//
//  PhotoDetailsViewController.swift
//  tumble-ios
//
//  Created by Zachary West Guo on 9/15/16.
//  Copyright © 2016 zechariah. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    @IBOutlet weak var detailImage: UIImageView!
    
    var photoUrl:NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImage.setImageWithURL(photoUrl!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
