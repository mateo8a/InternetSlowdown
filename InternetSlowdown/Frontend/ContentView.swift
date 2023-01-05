//
//  ContentView.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import SwiftUI

struct ContentView: View {
    @NSApplicationDelegateAdaptor private var appController: AppController
    
    @State var slowdownType: SlowdownType = .defaultSlowdown
    @State var slowdownDuration: TimeInterval = 600
    
    var body: some View {
        HStack{
            VStack {
                Form {
                    Picker("Slowdown options:", selection: $slowdownType) {
                        Text("Default").tag(SlowdownType.defaultSlowdown)
                        Text("Dial Up").tag(SlowdownType.dialUp)
                    }
                    .pickerStyle(.inline)
                }
            }
            VStack {
                Button("Start slowdown") {
                    let endDate = Date(timeIntervalSinceNow: slowdownDuration)
                    appController.startSlowdown(slowdownType: slowdownType, endDate: endDate)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
