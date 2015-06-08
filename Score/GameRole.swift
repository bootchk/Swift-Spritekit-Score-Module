
import Foundation

/*
Not Int enum, but String, so it can be serialized, and printed

Using rawValue in user-facing strings.
So when computer is talking to me or self, says "you"
*/
public enum GameRole : String {
  case me = "You", opponent = "Opponent"
  
  public var opposite : GameRole {
    // RO Computed property: opposite role of self
    let result = self == GameRole.me ? GameRole.opponent : GameRole.me
    return result
    /*
    if self == .me {
      return .opponent
    }
    else {
      return .me
    }
    */
  }
  
  //  For iteration
  static let allValues = ["You", "Opponent"]
}