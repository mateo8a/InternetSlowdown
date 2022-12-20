//
//  ContentView.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import SwiftUI

struct ContentView: View {
    @NSApplicationDelegateAdaptor private var appController: AppController
    
    var body: some View {
        VStack {            
            Button("Start slowdown") {
                appController.startSlowdown()
            }
            Button("Stop slowdown") {
                appController.stopSlowdown()
            }
            Button("Install helper tool (daemon)") {
                appController.installHelperTool()
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
