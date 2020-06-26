import Foundation

public struct JSONData: Decodable {
    public let contents: [Video]
}
public struct Video: Decodable {
    public let id: String
    public let staticContentId: Int
    public let eventContentId: Int
    public let eventId: String
    public let webPermalink: String
    public let description: String
    public let title: String
    public let topicIds: [Int]
    public let type: String
    public let trackId: Int
    public let startTime: String
    public let endTime: String
    public let media: Media?
}

public struct Media: Decodable {
    public let duration: Int
}
