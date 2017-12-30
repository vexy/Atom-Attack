import CoreGraphics

public extension Int {
  public static func random(_ n: Int) -> Int {
    return Int(arc4random_uniform(UInt32(n)))
  }
}
