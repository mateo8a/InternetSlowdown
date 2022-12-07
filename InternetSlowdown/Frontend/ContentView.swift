//
//  ContentView.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import SwiftUI

struct ContentView: View {
    @NSApplicationDelegateAdaptor private var appDelegate: AppController
    
    var body: some View {
        VStack {            
            Button("Start slowdown") {
                appDelegate.startSlowdown()
            }
            Button("Install helper tool (daemon)") {
                appDelegate.installHelperTool()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
