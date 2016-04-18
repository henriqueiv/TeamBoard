//
//  TBOInteractionController.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/15/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOInteractionController {
    var state : InteractionState = .WaitingForInteraction
    enum InteractionState {
        case Active
        case WaitingForInteraction
        case Inactive
    }
    
    /**
     Update state from user interactions following this flow below.
     
     - Active -> WaitingForInteraction.
     - WaitingForInteraction -> Inactive.
     - Inactive stays Inactive.
     */
    func updateState(){
        switch(state){
        case .Active:
            setWaiting()
            break
        case .WaitingForInteraction:
            setInactive()
            break
        case .Inactive:
            return
        }
    }
    
    func setActive(){
        state = .Active
    }
    func setInactive(){
        state = .Inactive
    }
    func setWaiting(){
        state = .WaitingForInteraction
    }
}