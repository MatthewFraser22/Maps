//
//  Response.swift
//  Maps
//
//  Created by Matthew Fraser on 2021-07-09.
//

import Foundation

// MARK: - Response

struct Response: Codable {
	let status: String
	let code, version: Int
	let payload: Payload?
}

// MARK: - Payload

struct Payload: Codable {
	let feed: String?
	let page, totalItemCount, totalPages: Int?
	let items: [Item]?
}

// MARK: - Item

struct Item: Codable {
	let id: Int?
	let title: String?
	let permalink, url: String?
	let ctype, created, modified: String?
	let createdEpoch, modifiedEpoch, privacyLevel: Int?
	let createdVia: String?
	let location: Location?
	let precis, coverImage: String?
	let displayImage: DisplayImage?
	let data: DataClass?
	let motorcycle: JSONNull?
	let source: String?
	let metaInfo: MetaInfo?
	let author: Author?
	let userMetaInfo: UserMetaInfo?
	let body: JSONNull?
	let sort: String?
}

// MARK: - Author

struct Author: Codable {
	let id: Int?
	let name, realName: String?
	let avatar: Avatar?
}

// MARK: - Avatar

struct Avatar: Codable {
	let list, thumb, original: String?
}

// MARK: - DataClass

struct DataClass: Codable {
	let origin, destination: Destination?
	let distance, duration: Int?
	let path: JSONNull?
	let polyline: String?
}

// MARK: - Destination

struct Destination: Codable {
	let lat, lng: Double?
}

// MARK: - DisplayImage

struct DisplayImage: Codable {
	let title, raw, thumb, list: String?
	let original: String?
}

// MARK: - Location

struct Location: Codable {
	let isDefaultLocation: Bool?
	let lastUpdated: Int?
	let lat, lng: Double?
	let geohash, country, countryCode, state: String?
	let stateCode, city, streetName, streetNumber: String?
	let postalCode, userFriendlyLocation: String?
}

// MARK: - MetaInfo

struct MetaInfo: Codable {
	let upVotes, downVotes, commentCount, views: Int?
}

// MARK: - UserMetaInfo

struct UserMetaInfo: Codable {
	let isAuthor, isEditable, isDeletable, isLiked: Bool?
	let isFollowingAuthor: Bool?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
		return true
	}

	public var hashValue: Int {
		return 0
	}

	public init() {}

	public required init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if !container.decodeNil() {
			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}
