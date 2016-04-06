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
    
    static let swipeRight = #selector(TutorialViewController.swipeLeft)
    static let swipeLeft = #selector(TutorialViewController.swipeRight)
    
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
        let tip2 = Tip(text: "Tip 2", image: UIImage())
        let tip3 = Tip(text: "Tip 3", image: UIImage())
        
        tips += [tip1]
        tips += [tip2]
        tips += [tip3]
    }
    
    private func setupGestures() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: .swipeRight)
        swipeRightRecognizer.direction = .Right
        view.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: .swipeRight)
        swipeLeftRecognizer.direction = .Left
        view.addGestureRecognizer(swipeLeftRecognizer)
    }
    
    @objc private func swipeRight() {
        if currentTipIndex < tips.count {
            nextTip()
        } else {
            // TODO: Go to main screen
            print("Last tip. Go to main screen")
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
        currentTipIndex += 1
    }
    
}