//
//  ChoosePage.swift
//  DoItOrElse2
//
//  Created by jose on 3/16/24.
//

import Foundation
import SwiftUI
import SwiftData

struct ChoosePage: View {
    @State private var chosenPunishment: Punishment?;
    @State private var settings: AppSettings = SettingsService.getSettings()!;
    
    func onPress() {
        print(settings)
    }
    
    
    var body: some View {
        VStack{
            Text("Choose where it all goes to.").font(.largeTitle)
            Text("Feeling a little vindictive? Or a little charitable? Change all that here.").font(.title2)
            
            ForEach(Punishments, id: \.name) { punishment in
//                Text(punishment.name).font(.title3)
                Button(action: onPress) {
//                    Text("ASSASAAS")
                    Text(String(settings.selected))
                }
                Text(punishment.description)
            }
                
        }
    }
}
