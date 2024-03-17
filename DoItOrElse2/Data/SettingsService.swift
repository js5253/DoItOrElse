//
//  SettingsService.swift
//  DoItOrElse2
//
//  Created by jose on 3/16/24.
//

import Foundation
import SwiftData

@Model public class AppSettings {
    var selected: Int = 0;

    
    init(selected: Int) {
        self.selected = selected
    }
}

class SettingsService {
    
    public var context: ModelContext? = nil;
    private var container: ModelContainer? = nil;
    
    static let shared: SettingsService = {
        let instance = SettingsService()
        Task {
            await instance.initialize()
        }
        // setup code
        return instance
    }()
    
    func initialize() async {
        do {
            container = try ModelContainer(for: AppSettings.self);
            context = await container?.mainContext
        } catch {
            print(error)
        }
    }
    static func getSettings() -> AppSettings? {
        do {
            return (try SettingsService.shared.context?.fetch(.init(predicate: #Predicate {
                (settings: AppSettings) in
                return true == true
            }))[0])
        } catch {
            return nil;

        }
    }
}
