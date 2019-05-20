//
//  GameViewController.swift
//  Juego
//
//  Created by DAM on 09/04/2019.
//  Copyright © 2019 DAM. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let view = self.view as! SKView? {
            
            // Present the scene
            let menuScene = MenuScene(size: CGSize(width: 400, height: 800))
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        
           view.presentScene(menuScene)
            }
    }
        
        
    
        
            
    
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
