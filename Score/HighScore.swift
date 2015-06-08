
import Foundation

class HighScore {
  /*
  Persistent high score.
  
  Implementation: userDefaults
  
  Responsibility:
  - understand gameMode and set the proper score for the mode
  
  Solitary sets one persistent recordScore.
  Two-player cooperative sets a different recordScore.
  
  In two-player cooperative, there is only one clock.
  One person can set a new recordScore (for themselves)
  while the same time does not set a new recordScore for the other.
  (They have their own record, and it might not be exceeded.)
  
  */
  // TODO: low separate recordScores for two-player cooperative
  /*
  if gameMode.isSolitary else two_player_high_score_preference
  var recordTimeTwoPlayerCooperative : NSTimeInterval = 0
  */
  
  // Canonical use of singletong UserDefaults
  let userDefaults  = NSUserDefaults.standardUserDefaults()
  
  var recordTimeSolitary : NSTimeInterval {
    let result = userDefaults.doubleForKey("solitary_high_score_preference")
    // result is zero if never set before
    return result
  }
  
  
  // MARK: Solitary
  
  func checkAndRecordTimeRecordSet(newTime: NSTimeInterval) -> Bool {
    let result = newTime > recordTimeSolitary
    if result {
      recordNewTimeRecord(newTime)
    }
    return result
  }
  
  private func recordNewTimeRecord(newTime : NSTimeInterval) {
    //    recordMaxTime = newTime
    // TODO: Enhancement Make record score retrievable at any time.
    // Currently it is visible to user only at end of round.
    userDefaults.setDouble(newTime, forKey:"solitary_high_score_preference")
  }
  
}