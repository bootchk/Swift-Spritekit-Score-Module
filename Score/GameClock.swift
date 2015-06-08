
import Foundation
import SpriteKit


class GameClock {
  /*
  Object to plugin to a SKScene to display a counting up game clock in a SKLabelNode of the scene.
  The time on the clock is unpaused playing time.
  
  If game (actually the scene the clock is plugged into) is paused, clock pauses also.
  Note that subtrees of the scene can be paused by pausing the root of the subtree.
  
  The clock can also be paused even though the simulation is running.
  
  Displays seconds from time zero.
  */
  
  let dateComponentsFormatter = NSDateComponentsFormatter()
  
  var runningTimeInterval : NSTimeInterval // A Double, in units of second.
  var view : SKLabelNode!
  var isPluggedIn : Bool = false
  var isRunning = false
  
  var formattedGameTime : String {
    /*
    Format to default format of NSDateComponentsFormatter (no leading digits, resolution in seconds.
    Typically "Minutes:Seconds".
    I think it will be formatted according to locale, i.e. "Minutes.Seconds" in Europe.
    If you want a different format, fiddle with this.
    */
    let result = dateComponentsFormatter.stringFromTimeInterval(self.timeInterval())
    return result!
  }
  
  
  init(view: SKLabelNode) {
    println("GameClock.init")
    self.view = view  // Label node that displays gameclock
    self.runningTimeInterval = 0
  }
  
  
  func pluginToScene(scene: SKScene) {
    /*
    Install an action on scene to call tick() periodically.
    
    Similar to a timer, but driven by simulation update, and is pauseable along with scene.
    
    Call this once, and after you remove actions from scene.
    
    Implementation: Create nested structure of actions.
    */
    println("GameClock.pluginToScene")
    if !isPluggedIn {
      innerPluginToScene(scene)
    }
    else {
      NSLog("Plugin gameClock already plugged in.")
    }
  }
  
  private func innerPluginToScene(scene: SKScene) {
    let waitAction = SKAction.waitForDuration(1)  // Every half second avoids 2 second jumps
    // bind self's tick() method to block to be run periodically
    let runBlockAction = SKAction.runBlock({ self.tick() })
    let sequenceAction = SKAction.sequence([waitAction, runBlockAction])
    let repeatAction = SKAction.repeatActionForever(sequenceAction)
    scene.runAction(repeatAction, withKey: "gameClock")
    
    // Without this, seconds don't display until after 1 minute
    dateComponentsFormatter.unitsStyle = .Abbreviated // .Short
    
    isPluggedIn = true
  }
  
  
  func unPlug(scene: SKScene) {
    // unplug and clear view
    // Design: we could let the clock run, but wasted cpu cycles
    println("GameClock.unPlug")
    scene.removeActionForKey("gameClock") // if no action, fails quietly
    view.text = ""
    isPluggedIn = false
  }
  
  
  // MARK: start, pause, and reset
  
  /*
  Pause and resume are not usually necessary, since when SpriteKit is paused,
  ticks don't come and the game clock does not advance.
  
  That is, if game is over but gameScene still updating, call stop() and when you are done with displayed time, reset()
  If game is not over but just paused, then pausing gameScene will pause clock.
  */
  func stop() {
    // Stop. Hold the displayed time
    // assert(isRunning)
    isRunning = false
  }
  
  /* This doesn't work, ticks pile up
  func resume() {
    isRunning = true
  }
  */
  
  func startOrContinue() {
    // Can be called even if already running
    isRunning = true
  }
  
  func start() {
    assert(!isRunning)
    isRunning = true
  }
  
  func reset() {
    /* Stop and set to 0. */
    // startTime = NSDate.timeIntervalSinceReferenceDate()  // Not a date
    stop()
    runningTimeInterval = 0
  }
  
  func resetAndStart() {
    reset()
    start()
  }
  
  func tick() {
    /*
    Method called when to update GameClock view.
    Depends on regular calls for time keeping.
    Also affects how often the view is updated.
    If the format of the view displays seconds digits and you want to increment by 1 second, you should call this every second.
    
    Typically called every second by using pluginToScene()
    */
    // println("GameClock.tick()")
    if isRunning {
      runningTimeInterval = runningTimeInterval + 1
      view.text = formattedGameTime
    }
  }
  
  // TODO: low, var
  func timeInterval() -> NSTimeInterval {
    // timeInterval of self in whatever units NSTimeInterval is in
    // assert(startTime != nil, "reset was called earlier")
    /*
    let nowTime = NSDate.timeIntervalSinceReferenceDate()
    let result = nowTime - startTime!
    */
    let result = runningTimeInterval
    return result
    // timeInterval = startDate?.timeIntervalSinceDate(deltaTimeInterval)
  }
  
  func formattedTimeInterval(timeInterval : NSTimeInterval) -> String {
    // Format a given time
    return dateComponentsFormatter.stringFromTimeInterval(timeInterval)!
  }
  
  
}