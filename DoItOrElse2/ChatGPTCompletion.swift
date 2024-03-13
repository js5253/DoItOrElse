//
//  ChatGPTCompletion.swift
//  DoItOrElse2
//
//  Created by jose on 3/4/24.
//

import Foundation
struct PardonResponse: Codable {
    var pardoned: Bool
    var description: String
}
struct ChatGPTMessage: Codable {
    var role: String
        var content: PardonResponse

        enum CodingKeys: String, CodingKey {
            case role, content
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            role = try container.decode(String.self, forKey: .role)
            
            // Decode the "content" JSON string into Data
            let contentString = try container.decode(String.self, forKey: .content)
            guard let contentData = contentString.data(using: .utf8) else {
                throw DecodingError.dataCorruptedError(forKey: .content, in: container, debugDescription: "Invalid JSON string")
            }
            
            // Decode the Data into PardonResponse struct
            content = try JSONDecoder().decode(PardonResponse.self, from: contentData)
        }
}
struct Choice: Codable {
var index: Int
    var message: ChatGPTMessage
}

struct ChatGPTResponse : Codable {
var id: String
var object: String
var created: Int
var model: String
var choices: [Choice]
}
