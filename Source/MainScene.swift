import Foundation

class MainScene: CCScene {
    weak var dpad: CCSprite!
    weak var joystick: CCSprite!
    weak var player: CCSprite!
    
    var stickActive: Bool = false
    var velocity: CGPoint = CGPointMake(0, 0)
    var angularVelocity: CGFloat = 0
    var location: CGPoint!
    
    override init!() {
        super.init()
        
        location = location.self
        self.userInteractionEnabled = true
    }
    
    override func update(delta: CCTime) {
        if self.velocity.x != 0 || self.velocity.y != 0 {
            player.position = ccpAdd(player.position, self.velocity)
        }
        
        if self.velocity.x != 0 || self.velocity.y != 0 {
            player.rotation = Float(self.angularVelocity)
        }
    }
    
    func dpadStart() {
        if (CGRectContainsPoint(joystick.boundingBox(), location)) {
            stickActive = true
        } else {
            stickActive = false
        }
    }
    
    func dpadMoved() {
        if (stickActive == true) {
            let vector = CGVector(dx: location.x - dpad.position.x, dy: location.y - dpad.position.y)
            let angle = atan2(vector.dy, vector.dx)
            let degree = angle * CGFloat(180 / M_PI)
            let radians = CGFloat(M_PI / 2)
            let length: CGFloat = dpad.boundingBox().size.height / 2
            let xDist: CGFloat = sin(angle - radians) * length
            let yDist: CGFloat = cos(angle - radians) * length
            
            joystick.position = CGPointMake(dpad.position.x - xDist, dpad.position.y + yDist)
            
            if (CGRectContainsPoint(dpad.boundingBox(), location)) {
                joystick.position = location
                
            } else {
                joystick.position = CGPointMake(dpad.position.x - xDist, dpad.position.y + yDist)
            }
            
            self.velocity = ccp(xDist * -0.1, yDist * 0.1)
            
            self.angularVelocity = -(degree - 90)
        }
    }
    
    func dpadMovedEnded() {
        if (stickActive == true) {
            let move = CCActionMoveTo(duration: 0.1, position: dpad.position)
            joystick.runAction(move)
        }
        
        self.resetVelocity()
    }
    
    func resetVelocity() {
        self.velocity = CGPointZero
    }
    
    // MARK: - Touch devices
    
#if os(iOS)
    
    override func touchBegan(touch: UITouch!, withEvent event: UIEvent!) {
        location = touch.locationInNode(self)
        
        dpadStart()
    }
    
    override func touchMoved(touch: UITouch!, withEvent event: UIEvent!) {
        location = touch.locationInNode(self)
    
        dpadMoved()
    }
    
    override func touchEnded(touch: UITouch!, withEvent event: UIEvent!) {
        dpadMovedEnded()
    }
    
    override func touchCancelled(touch: UITouch!, withEvent event: UIEvent!) {
        self.resetVelocity()
    }
    
    // MARK: - Mac OS X
    
#elseif os(OSX)
    
    override func mouseDown(theEvent: NSEvent!) {
        location = theEvent.locationInNode(self)
        
        dpadStart()
    }
    
    override func mouseDragged(theEvent: NSEvent!) {
        location = theEvent.locationInNode(self)
        
        dpadMoved()
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        location = theEvent.locationInNode(self)
        
        dpadMovedEnded()
    }
    
#endif

}
