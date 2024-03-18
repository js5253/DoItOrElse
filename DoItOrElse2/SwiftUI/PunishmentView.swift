//
//  PunishmentView.swift
//  DoItOrElse2
//
//  Created by jose on 3/18/24.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkwebView = WKWebView()
        let request = URLRequest(url: url)
        wkwebView.load(request)
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
struct PunishmentView : View {
    @State private var selected: Int = 0;
    @State private var owed: Int = 0;
    @State private var url: String = Punishments[0].url
    init() {
        
    }
    var body: some View {
        VStack {
            HStack {
            Text(String("$\(owed)"))
                .task {
                    owed = await EventsService.shared.getAmountOwed()
                }
                Spacer()
                Picker("Punishment", selection: $selected) {
                    ForEach(Array(Punishments.enumerated()), id: \.offset) { index, element in
                      // ...
                        Text(element.name).tag(index)
                    }
                }
            }.padding(6)
            WebView(url: URL(string: url)!)

                .ignoresSafeArea()
                .navigationTitle("Do it... or Else")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: selected, {
                    url = Punishments[selected].url
                }
                )
        }
        HStack {
            Button(action: {}) {
                Text("I did it!!!")
            }
            Spacer(minLength: 40)
            Button(action: {}) {
                Text("Nevermind...")
            }
        }.padding(6)
    }
}
