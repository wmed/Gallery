import Foundation

class EventHub {
    
    typealias Action = () -> Void
    
    static let shared = EventHub()
    
    // MARK: Initialization
    
    init() {}
    
    var close: Action?
    var doneWithImages: Action?
    var doneWithVideos: Action?
    var stackViewTouched: Action?
    var batchOn: Action?
    var batchOff: Action?
    var imageTabSelected: Action?
    var videoTabSelected: Action?
    //var doneTouched: Action?
}
