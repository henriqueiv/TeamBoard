//
//  TutorialViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/6/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

// MARK: - Architecture
private extension Selector {
    
    static let swipeRight = #selector(TutorialViewController.swipeRight)
    static let swipeLeft = #selector(TutorialViewController.swipeLeft)
    
}

struct Tip {
    let text:String
    let image:UIImage
}

// MARK: - TutorialViewController
class TutorialViewController: UIViewController {
    
    // MARK: Private vars
    private var tips = [Tip]()
    private var currentTipIndex = 0 {
        didSet {
            let currentTip = tips[currentTipIndex]
            // TODO: Set tip's info on the screen
            print(currentTip)
        }
    }
    
    override func viewDidLoad() {
        createTips()
        setupGestures()
    }
    
    // MARK: Private helpers
    private func createTips() {
        let tip1 = Tip(text: "Tip 1", image: UIImage())
        tips += [tip1]
    }
    
    private func setupGestures() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: .swipeRight)
        swipeRightRecognizer.direction = .Right
        view.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: .swipeLeft)
        swipeLeftRecognizer.direction = .Left
        view.addGestureRecognizer(swipeLeftRecognizer)
    }
    
    @objc private func swipeRight() {
        if currentTipIndex < tips.count-1 {
            nextTip()
        } else {
            print("Last tip. Go to main screen")
            
            // TODO: Go to main screen
            let sb = UIStoryboard(name: "OrganizationSelection", bundle: NSBundle.mainBundle())
            let vc = sb.instantiateInitialViewController()
            presentViewController(vc!, animated: true, completion: nil)
        }
    }
    
    @objc private func swipeLeft() {
        if currentTipIndex > 0 {
            previousTip()
        } else {
            // Do nothing
            print("No previous tip")
        }
    }
    
    private func nextTip() {
        currentTipIndex += 1
    }
    
    private func previousTip() {
        currentTipIndex -= 1
    }
    
}