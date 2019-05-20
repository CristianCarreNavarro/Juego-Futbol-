//
//  MenuScene.swift
//  Juego
//
//  Created by Cristian Carreño Navarro on 12/04/2019.
//  Copyright © 2019 Cristian Carreño Navarro. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    // Node references
    var backgroundEmmiter:SKEmitterNode!
        var background:SKSpriteNode!
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    
    
    // Initialization
    override func didMove(to view: SKView) {
        
        // Background starfield
       backgroundEmmiter = SKEmitterNode(fileNamed: "Starfield")
      
        backgroundEmmiter.position = CGPoint(x: 0, y: self.frame.size.height)
        backgroundEmmiter.advanceSimulationTime(10)
        self.addChild(backgroundEmmiter)
        backgroundEmmiter.zPosition = -1
  
        backgroundEmmiter = self.childNode(withName: "starfield") as? SKEmitterNode
        backgroundEmmiter?.advanceSimulationTime(10)
        
  
        background = SKSpriteNode(texture: SKTexture(imageNamed: "gol"))
        background.position = CGPoint(x: 0, y:  self.frame.size.height)
      background.size = CGSize(width: self.frame.maxX+600, height: self.frame.maxY+1000)
        
        self.addChild(background)
        background.zPosition = -1
        
        
        newGameButtonNode = SKSpriteNode(texture: SKTexture(imageNamed: "newgame"))
        newGameButtonNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(newGameButtonNode)
        newGameButtonNode.zPosition = 1
      
        newGameButtonNode!.name = "newgame"
        
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as? SKSpriteNode
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as? SKLabelNode
        
        
        // Remember the difficulty level from prior execution
        if UserDefaults.standard.bool(forKey: "hard") {
            difficultyLabelNode?.text = "Hard"
        }
        else {
            difficultyLabelNode?.text = "Easy"
        }
   
    }
    
    // User touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // First finger in screen
        if let location = touches.first?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            // First node under the finger
            let nodeName = nodesArray.first?.name
            if nodeName == "newgame" {
                newGame()
            }
            else if nodeName == "difficultyButton" {
                changeDifficulty()
            }
        }
    }
    
 
    func newGame() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
      
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(gameScene, transition:transition)
    }
    
  
    func changeDifficulty() {
        // General userdata storage (settings, ...)
        let userDefaults = UserDefaults.standard
        if (difficultyLabelNode.text == "Easy") {
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        }
        else {
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
        }
        // Save all changes
        userDefaults.synchronize()
    }
}
