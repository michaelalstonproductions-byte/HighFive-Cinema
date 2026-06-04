import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum HFPosterAssetHealth {
    static func hasImage(named assetName: String?) -> Bool {
        guard let assetName, !assetName.isEmpty else { return false }
#if canImport(UIKit)
        return UIImage(named: assetName) != nil
#else
        return true
#endif
    }
}
