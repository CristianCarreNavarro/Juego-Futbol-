//
//  GameScene.swift
//  Juego
//
//  Created by DAM on 09/04/2019.
//  Copyright © 2019 DAM. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
// Necesario para tratar con colisiones SKPhysicsContactDelegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    // Alien spawning
    var gameTimer:Timer!

    
    var pelota = SKSpriteNode()
    // Nodo para el fondo de la pantalla
    var fondo = SKSpriteNode()
    
    var audioPlayer: AVAudioPlayer?
    
    // Nodo label para la puntuacion
    var labelPuntuacion = SKLabelNode()
    var puntuacion = 0
    
    // Nodos para los tubos
    var tubo1 = SKSpriteNode()
    var tubo2 = SKSpriteNode()
    
    // Texturas de la mosquita
    var pelotaTexture1 = SKTexture()
    var pelotaTexture2 = SKTexture()
    
    // Textura de los tubos
    var texturaTubo1 = SKTexture()
    var texturaTubo2 = SKTexture()
    
    // altura de los huecos
    var alturaHueco = CGFloat()
    
    // timer para crear tubos y huecos
    var timer = Timer()
    var futbolista2Timer = Timer()
    var futbolista3Timer = Timer()
    var pointTimer = Timer()
    // boolean para saber si el juego está activo o finalizado
    var gameOver = false
    
    // Variables para mostrar tubos de forma aleatoria
    var cantidadAleatoria = CGFloat()
    var compensacionTubos = CGFloat()
    
    
    enum tipoNodo: UInt32 {
        case pelota = 1
        case obstaculoCategory =  2
        case sumarPunto = 6
        case huecoTubos = 4
        case playerCategory = 16
        
      
    }
    
    // Función equivalente a viewDidLoad
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        reiniciar()
        playMusic()
    }
    
    
    func playMusic() {
        guard let url = Bundle.main.url(forResource: "olivermusica", withExtension: "mp3") else {
            print("not found")
            
            return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.play()
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    
    func reiniciar() {
        
        // Creamos los timers
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.ponerEstalactitas), userInfo: nil, repeats: true)
        futbolista2Timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.addFutbolista2), userInfo: nil, repeats: true)
        futbolista3Timer = Timer.scheduledTimer(timeInterval: 17, target: self, selector: #selector(self.addFutbolista3), userInfo: nil, repeats: true)
        pointTimer =  Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.addPunto), userInfo: nil, repeats: true)
        
        // Ponemos la etiqueta con la puntuacion
        ponerPuntuacion()
        
        pelotaAnimation()
        // Definimos la altura de los huecos
        alturaHueco = pelota.size.height * 3
        
        //ponemos fondo, creamos el punto de contacto con el fondo
        crearFondoConAnimacion()
        crearSuelo()
        
        //funcion de golpeo
        
    }
    
    func ponerPuntuacion() {
        labelPuntuacion.fontName = "Arial"
        labelPuntuacion.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 250)
        labelPuntuacion.fontSize = 80
        labelPuntuacion.text = "0"
        labelPuntuacion.zPosition = 2
        self.addChild(labelPuntuacion)
    }
    
    
    
    
    @objc func ponerEstalactitas() {
        
        // Acción para mover los tubos
        let moveObstacles = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 80))
        
        // Acción para borrar los tubos cuando desaparecen de la pantalla para no tener infinitos nodos en la aplicación
        let deleteObstacles = SKAction.removeFromParent()
        
        
        // Acción que enlaza las dos acciones (la que pone tubos y la que los borra)
        let moveDeleteObstacles = SKAction.sequence([moveObstacles, deleteObstacles])
        
        // Numero entre 0 y la mitad de alto de la pantalla (para que los tubos aparezcan a alturas diferentes)
        cantidadAleatoria = CGFloat(arc4random() % UInt32(self.frame.height/2))
        
        // Compensación para evitar que a veces salga un único tubo porque el otro está fuera de la pantalla
        compensacionTubos = cantidadAleatoria - self.frame.height / 4
        
        let futbolistaTexture = SKTexture(imageNamed: "futbolista1.png")
        let futbolista = SKSpriteNode(texture: futbolistaTexture)
        futbolista.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + futbolistaTexture.size().height / 2 + alturaHueco + compensacionTubos)
        futbolista.zPosition = 0
      
        // Le damos cuerpo físico al tubo
        futbolista.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "futbolista1.png"), alphaThreshold: 0.5, size: futbolista.size)
        // Para que no caiga
        futbolista.physicsBody!.isDynamic = false
        
        // Categoría de collision
        futbolista.physicsBody!.categoryBitMask = tipoNodo.obstaculoCategory.rawValue
        
        // con quien colisiona
        futbolista.physicsBody!.collisionBitMask = tipoNodo.pelota.rawValue
        
        // Hace contacto con
        futbolista.physicsBody!.contactTestBitMask = tipoNodo.pelota.rawValue
        
        futbolista.run(moveDeleteObstacles)
        
        self.addChild(futbolista)
        
        let porteroTexture = SKTexture(imageNamed: "portero1.png")
        let portero = SKSpriteNode(texture: porteroTexture)
        portero.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "portero1.png"), alphaThreshold: 0.5, size:porteroTexture.size())
        portero.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - porteroTexture.size().height / 15 - alturaHueco + compensacionTubos)
        portero.zPosition = 0
        portero.run(moveDeleteObstacles)
        portero.physicsBody = SKPhysicsBody(rectangleOf: porteroTexture.size())
        portero.physicsBody!.isDynamic = false
        portero.physicsBody!.categoryBitMask = tipoNodo.obstaculoCategory.rawValue
        portero.physicsBody!.collisionBitMask = tipoNodo.pelota.rawValue
        portero.physicsBody!.contactTestBitMask = tipoNodo.pelota.rawValue
        self.addChild(portero)
        
        // Hueco entre los tubos
        let nodoHueco = SKSpriteNode()
        
        nodoHueco.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + compensacionTubos)
     
        nodoHueco.zPosition = 1
        nodoHueco.run(moveDeleteObstacles)
        
        self.addChild(nodoHueco)
        
    }
    
    func crearSuelo() {
        let suelo = SKNode()
        suelo.position = CGPoint(x: -self.frame.midX, y: -self.frame.height / 2)
        suelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        // el suelo se tiene que estar quieto
        suelo.physicsBody!.isDynamic = false
        
        // Categoría para collision
        suelo.physicsBody!.categoryBitMask = tipoNodo.obstaculoCategory.rawValue
        // Colisiona con la mosquita
        suelo.physicsBody!.collisionBitMask = tipoNodo.pelota.rawValue
        // contacto con el suelo
        suelo.physicsBody!.contactTestBitMask = tipoNodo.pelota.rawValue
        
        self.addChild(suelo)
    }
    
    func crearFondoConAnimacion() {
        // Textura para el fondo
        let texturaFondo = SKTexture(imageNamed: "fondoCesped.png")
        
        // Acciones del fondo (para hacer ilusión de movimiento)
        // Desplazamos en el eje de las x cada 0.3s
        let movimientoFondo = SKAction.move(by: CGVector(dx: -texturaFondo.size().width, dy: 0), duration: 4)
        
        let movimientoFondoOrigen = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)
        
        // repetimos hasta el infinito
        let movimientoInfinitoFondo = SKAction.repeatForever(SKAction.sequence([movimientoFondo, movimientoFondoOrigen]))
        
        // Necesitamos más de un fondo para que no se vea la pantalla en negro
        
        // contador de fondos
        var i: CGFloat = 0
        
        while i < 2 {
            // Le ponemos la textura al fondo
            fondo = SKSpriteNode(texture: texturaFondo)
            
            // Indicamos la posición inicial del fondo
            fondo.position = CGPoint(x: texturaFondo.size().width * i, y: self.frame.midY)
            
            // Estiramos la altura de la imagen para que se adapte al alto de la pantalla
            fondo.size.height = self.frame.height
            
            // Indicamos zPosition para que quede detrás de todo
            fondo.zPosition = -1
            
            // Aplicamos la acción
            fondo.run(movimientoInfinitoFondo)
            // Ponemos el fondo en la escena
            self.addChild(fondo)
            
            // Incrementamos contador
            i += 1
        }
        
    }
    
    func pelotaAnimation() {
        pelota.zPosition = 1
        
        // Asignamos las texturas de la pelota
       pelotaTexture1 = SKTexture(imageNamed: "pelota.png")
       pelotaTexture2 = SKTexture(imageNamed: "pelota2.png")
        
        // Creamos la animación que va intercambiando las texturas
        // para que parezca que la pelota va volando
        
        // Acción que indica las texturas y el tiempo de cada uno
        let animacion = SKAction.animate(with: [pelotaTexture1, pelotaTexture2], timePerFrame: 0.2)
        
        // Creamos la acción que hace que se vaya cambiando de textura
        // infinitamente
        let animacionInfinita = SKAction.repeatForever(animacion)
        
        // Le ponemos la textura inicial al nodo
        pelota = SKSpriteNode(texture: pelotaTexture1)
        
        pelota.position = CGPoint(x: self.frame.minX+50, y: self.frame.midY)
        pelota.size = CGSize(width: 70, height: 70)
        pelota.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "pelota.png"), alphaThreshold: 0.5, size: pelota.size)
        
        // Al inicial la pelota está quieta
        pelota.physicsBody?.isDynamic = true
        
        // Añadimos su categoría
        pelota.physicsBody!.categoryBitMask = tipoNodo.pelota.rawValue
    
        // Indicamos la categoría de colisión con el suelo/tubos
        pelota.physicsBody!.collisionBitMask = tipoNodo.obstaculoCategory.rawValue | tipoNodo.sumarPunto.rawValue
        
        // Hace contacto con (para que nos avise)
        pelota.physicsBody!.contactTestBitMask = tipoNodo.obstaculoCategory.rawValue | tipoNodo.sumarPunto.rawValue
        
        
        // Aplicamos la animación a la pelota
        pelota.run(animacionInfinita)
        
        pelota.zPosition = 0
        
        // Ponemos la pelota en la escena
        self.addChild(pelota)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            // En cuanto el usuario toque la pantalla le damos dinámica a la pelota (caerá)
            pelota.physicsBody!.isDynamic = true
            
            // Le damos una velocidad a la pelota para que la velocidad al caer sea constante
            pelota.physicsBody!.velocity = CGVector(dx: 0, dy: 1)
            
            // Le aplicamos un impulso a la pelota para que suba cada vez que pulsemos la pantalla

            pelota.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            // si toca la pantalla cuando el juego ha acabado, lo reiniciamos para volver a jugar
            gameOver = false
            puntuacion = 0
            self.speed = 1
            self.removeAllChildren()
            reiniciar()
        }
        
    }
    
    // Función para tratar las colisiones o contactos de nuestros nodos
    func didBegin(_ contact: SKPhysicsContact) {
        // en contact tenemos bodyA y bodyB que son los cuerpos que hicieron contacto
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        print(cuerpoA.categoryBitMask)
        print(cuerpoB.categoryBitMask)
   
        if(cuerpoA.categoryBitMask == tipoNodo.sumarPunto.rawValue && cuerpoB.categoryBitMask == tipoNodo.pelota.rawValue
            || cuerpoA.categoryBitMask == tipoNodo.pelota.rawValue && cuerpoB.categoryBitMask == tipoNodo.sumarPunto.rawValue){
            print("Colision con puntos")
            puntuacion = puntuacion + 1
            if(cuerpoA.categoryBitMask  == tipoNodo.pelota.rawValue){
                cuerpoB.node?.removeFromParent()}
            
            labelPuntuacion.text = String(puntuacion)
        } else {
            gameOver = true
            // Frenamos todo
            self.speed = 0
            // Paramos el timer
            timer.invalidate()
            futbolista2Timer.invalidate()
            futbolista3Timer.invalidate()
            labelPuntuacion.text = "Game Over"
            pointTimer.invalidate()
        }
    }
    
    
    
    
    
    
    @objc func  addFutbolista2() {
        let futbolista2 = SKSpriteNode(imageNamed: "futbolista2.png")
        futbolista2.setScale(0.70)
        futbolista2.zPosition = 1
        futbolista2.physicsBody?.affectedByGravity = false
        
        let randomMinePosition = GKRandomDistribution(lowestValue: Int(self.frame.minY), highestValue: Int(self.frame.maxY))
        let position = CGFloat(randomMinePosition.nextInt())
        
        futbolista2.position = CGPoint(x: self.frame.maxX, y:position)
        // Physical properties
        futbolista2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "futbolista2.png"), alphaThreshold: 0.5, size: futbolista2.size)
        futbolista2.physicsBody?.isDynamic = false
        // Collision mask
        futbolista2.physicsBody?.categoryBitMask = tipoNodo.obstaculoCategory.rawValue
        futbolista2.physicsBody?.contactTestBitMask = tipoNodo.obstaculoCategory.rawValue | tipoNodo.pelota.rawValue
        futbolista2.physicsBody?.collisionBitMask = 0
        self.addChild(futbolista2)
        // Alien basic movement
        let animationDuration:TimeInterval = 30
        let actionMove = SKAction.moveBy(x: -self.frame.maxX , y:0, duration: animationDuration )
        let actionRemove = SKAction.removeFromParent()
        let actionLeftRight = SKAction.sequence([ actionMove, actionRemove ])
        
        futbolista2.run(actionLeftRight)
    }
    
    
    
    @objc func  addFutbolista3() {
        let futbolista3 = SKSpriteNode(imageNamed: "futbolista3.png")
        futbolista3.setScale(0.50)
        futbolista3.zPosition = 1
        futbolista3.physicsBody?.affectedByGravity = false
        
        let randomfutbolistaPosition = GKRandomDistribution(lowestValue: Int(self.frame.minY), highestValue: Int(self.frame.maxY))
        let position = CGFloat(randomfutbolistaPosition.nextInt())
        
        futbolista3.position = CGPoint(x: self.frame.maxX , y:position)
        // Physical properties
        futbolista3.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "futbolista3.png"), alphaThreshold: 0.5, size: futbolista3.size)
        futbolista3.physicsBody?.isDynamic = false
        // Collision mask
        futbolista3.physicsBody?.categoryBitMask = tipoNodo.obstaculoCategory.rawValue
        futbolista3.physicsBody?.contactTestBitMask = tipoNodo.obstaculoCategory.rawValue | tipoNodo.pelota.rawValue
        futbolista3.physicsBody?.collisionBitMask = 0
        self.addChild(futbolista3)
        
        let animationDuration:TimeInterval = 10
        let actionMove = SKAction.moveBy(x:  -self.frame.maxX  , y:0, duration: animationDuration )
        let actionRemove = SKAction.removeFromParent()
        let actionLeftRight = SKAction.sequence([ actionMove, actionRemove ])
        
        futbolista3.run(actionLeftRight)
    }
    
    @objc func addPunto() {
        let punto = SKSpriteNode(imageNamed: "punto.png")
        punto.setScale(0.2)
        punto.zPosition = 1
        
        let randomPointPosition = GKRandomDistribution(lowestValue: Int(self.frame.minY), highestValue: Int(self.frame.maxY))
        let position = CGFloat(randomPointPosition.nextInt())
        
        punto.position = CGPoint(x: self.frame.maxX+50, y:position)
        // Physical properties
        punto.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "punto.png"), alphaThreshold: 0.5, size: punto.size)
        punto.physicsBody?.isDynamic = true
        punto.physicsBody?.affectedByGravity = false
     
        // Collision mask
        punto.physicsBody?.categoryBitMask = tipoNodo.sumarPunto.rawValue
        punto.physicsBody?.contactTestBitMask = tipoNodo.pelota.rawValue
        punto.physicsBody?.collisionBitMask = tipoNodo.pelota.rawValue
        self.addChild(punto)
        
        let animationDuration:TimeInterval = 7.5
        let actionMove = SKAction.moveBy(x: self.frame.minX-1800, y:0, duration: animationDuration )
        let actionRemove = SKAction.removeFromParent()
        let actionLeftRight = SKAction.sequence([ actionMove, actionRemove ])
        
        punto.run(actionLeftRight)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
