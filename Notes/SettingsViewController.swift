//
//  SettingsViewController.swift
//  Notes
//
//  Created by Pallav Trivedi on 25/08/16.
//  Copyright © 2016 CodeIt. All rights reserved.
//

import UIKit
import QuartzCore
class SettingsViewController: UIViewController {

    @IBOutlet weak var animateButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didClickOnAnimateButton(sender: AnyObject)
    {
        
        self.imageView.alpha = 1.0;
        let imageFrame = self.imageView.frame
        
        var viewOrigin = self.imageView.frame.origin
        viewOrigin.y = viewOrigin.y + imageFrame.size.height / 2.0
        viewOrigin.x = viewOrigin.x + imageFrame.size.width / 2.0
        
        self.imageView.layer.position = viewOrigin;
        
        let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
        fadeOutAnimation.toValue = 0.3
        fadeOutAnimation.fillMode = kCAFillModeForwards
        fadeOutAnimation.removedOnCompletion = false
        
        let resizeAnimation = CABasicAnimation.init(keyPath: "bounds.size")
        resizeAnimation.toValue = NSValue.init(CGSize: CGSizeMake(40.0, imageFrame.size.height * (40.0 / imageFrame.size.width)))
        resizeAnimation.fillMode = kCAFillModeForwards
        resizeAnimation.removedOnCompletion = false
        
        let pathAnimation = CAKeyframeAnimation.init(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        
        let endPointX = UIScreen.mainScreen().bounds.width - (UIScreen.mainScreen().bounds.width)/2
        let endPoint = CGPointMake(endPointX, 760.0);
        
        let curvedPath = CGPathCreateMutable();
        CGPathMoveToPoint(curvedPath, nil, viewOrigin.x, viewOrigin.y);
        CGPathAddCurveToPoint(curvedPath, nil, endPoint.x, viewOrigin.y, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
        pathAnimation.path = curvedPath;
        
        
        let group = CAAnimationGroup()
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = false;
        group.animations = [fadeOutAnimation,pathAnimation,resizeAnimation]
        group.duration = 0.7;
        group.delegate = self;
        group.setValue(imageView, forKey: "noteCellBeingDeleted")
        imageView.layer.addAnimation(group, forKey: "savingAnimation")

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
