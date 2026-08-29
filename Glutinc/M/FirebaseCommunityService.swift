import Foundation

/// Compatibility name. Community posts are stored in CloudKit public DB
/// (`iCloud.com.sga.Glutinc`), not on-device files or a per-user database.
enum FirebaseCommunityService {
    static var shared: CloudKitService { .shared }
}
