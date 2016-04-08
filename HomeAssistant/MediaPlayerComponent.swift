//
//  MediaPlayerComponent.swift
//  HomeAssistant
//
//  Created by Robbie Trencheny on 4/5/16.
//  Copyright © 2016 Robbie Trencheny. All rights reserved.
//

import Foundation
import ObjectMapper

let isPlayingTransform = TransformOf<Bool, String>(fromJSON: { (value: String?) -> Bool? in
    return Bool(String(value!) == "playing")
}, toJSON: { (value: Bool?) -> String? in
    if let value = value {
        if value == true {
            return "playing"
        } else {
            return "paused"
        }
    }
    return nil
})

let isIdleTransform = TransformOf<Bool, String>(fromJSON: { (value: String?) -> Bool? in
    return Bool(String(value!) == "idle")
}, toJSON: { (value: Bool?) -> String? in
    if let value = value {
        if value == true {
            return "idle"
        } else {
            return ""
        }
    }
    return nil
})

class MediaPlayer: SwitchableEntity {
    
    var IsPlaying: Bool = false
    var IsIdle: Bool = false
    var IsVolumeMuted: Bool?
    var MediaContentID: String?
    var MediaContentType: String?
    var MediaDuration: Int?
    var MediaTitle: String?
    var VolumeLevel: Float?
    
    required init?(_ map: Map) {
        super.init(value: map)
    }
    
    required init() {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        IsPlaying        <- (map["state"], isPlayingTransform)
        IsIdle           <- (map["state"], isIdleTransform)
        IsVolumeMuted    <- map["attributes.is_volume_muted"]
        MediaContentID   <- map["attributes.media_content_id"]
        MediaContentType <- map["attributes.media_content_type"]
        MediaDuration    <- map["attributes.media_duration"]
        MediaTitle       <- map["attributes.media_title"]
        VolumeLevel      <- map["attributes.volume_level"]
    }
    
    func humanReadableMediaDuration() -> String {
        if let durationSeconds = self.MediaDuration {
            let hours = durationSeconds / 3600
            let minutes = (durationSeconds % 3600) / 60
            let seconds = (durationSeconds % 3600) % 60
            return "\(hours):\(minutes):\(seconds)"
        } else {
            return "00:00:00"
        }
    }
    
    func muteOn() {
        HomeAssistantAPI.sharedInstance.CallService("media_player", service: "volume_mute", serviceData: ["entity_id": self.ID, "is_volume_muted": "on"])
    }
    func muteOff() {
        HomeAssistantAPI.sharedInstance.CallService("media_player", service: "volume_mute", serviceData: ["entity_id": self.ID, "is_volume_muted": "off"])
    }
    func setVolume(newVolume: Float) {
        let fixedVolume = newVolume/100
        HomeAssistantAPI.sharedInstance.CallService("media_player", service: "volume_set", serviceData: ["entity_id": self.ID, "volume_level": fixedVolume])
    }
    
    override var ComponentIcon: String {
        return "mdi:cast"
    }
    
    override func StateIcon() -> String {
        return (self.State != "off" && self.State != "idle") ? "mdi:cast-connected" : "mdi:cast"
    }
}