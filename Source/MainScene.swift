import Foundation

class MainScene: CCNode {
    weak var dpad: CCSprite!
    weak var joystick: CCSprite!
    weak var player: CCSprite!
    
    var stickActive: Bool = false
    var velocity: CGPoint = CGPoint.zero
    var angularVelocity: CGFloat = 0
    var location: CGPoint!
    
    // Set the speed of the player's movement 
    var speed: CGFloat = 0.1
    
    override init!() {
        super.init()
        
        location = CGPoint()
        self.isUserInteractionEnabled = true
    }
    
    override func update(_ delta: CCTime) {
        if self.velocity.x != 0 || self.velocity.y != 0 {
            player.position = ccpAdd(player.position, self.velocity)
        }
        
        if self.velocity.x != 0 || self.velocity.y != 0 {
            player.rotation = Float(self.angularVelocity)
        }
    }
    
    func dpadStart() {
        if (joystick.boundingBox().contains(location)) {
            stickActive = true
        } else {
            stickActive = false
        }
    }
    
    func dpadMoved() {
        if (stickActive == true) {
            let vector = CGVector(dx: location.x - dpad.position.x, dy: location.y - dpad.position.y)
            let angle = atan2(vector.dy, vector.dx)
            let degree = angle * (180 / CGFloat.pi)
            let radians = CGFloat.pi / 2
            let length: CGFloat = dpad.boundingBox().size.height / 2
            let xDist: CGFloat = sin(angle - radians) * length
            let yDist: CGFloat = cos(angle - radians) * length
            
            joystick.position = CGPoint(x: dpad.position.x - xDist, y: dpad.position.y + yDist)
            
            if (dpad.boundingBox().contains(location)) {
                joystick.position = location
                
            } else {
                joystick.position = CGPoint(x: dpad.position.x - xDist, y: dpad.position.y + yDist)
            }
            
            self.velocity = ccp(xDist * -speed, yDist * speed)
            
            self.angularVelocity = -(degree - 90)
        }
    }
    
    func dpadMovedEnded() {
        if (stickActive == true) {
            let move = CCActionMoveTo(duration: 0.1, position: dpad.position)
            joystick.run(move)
        }
        
        self.resetVelocity()
    }
    
    func resetVelocity() {
        self.velocity = CGPoint.zero
    }
    
    // MARK: - Touch devices
    
#if os(iOS)
    
    override func touchBegan(_ touch: UITouch!, with event: UIEvent!) {
        location = touch.location(in: self)
        
        dpadStart()
    }
    
    override func touchMoved(_ touch: UITouch!, with event: UIEvent!) {
        location = touch.location(in: self)
    
        dpadMoved()
    }
    
    override func touchEnded(_ touch: UITouch!, with event: UIEvent!) {
        dpadMovedEnded()
    }
    
    override func touchCancelled(_ touch: UITouch!, with event: UIEvent!) {
        self.resetVelocity()
    }
    
    // MARK: - Mac OS X
    
#elseif os(OSX)
    
    override func mouseDown(_ theEvent: NSEvent!) {
        location = theEvent.location(in: self)
        
        dpadStart()
    }
    
    override func mouseDragged(_ theEvent: NSEvent!) {
        location = theEvent.location(in: self)
        
        dpadMoved()
    }
    
    override func mouseUp(_ theEvent: NSEvent!) {
        location = theEvent.location(in: self)
        
        dpadMovedEnded()
    }
    
#endif

}
