//
//  ContentView.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import SwiftUI

struct ContentView: View {
    @NSApplicationDelegateAdaptor private var appController: AppController
    
    @State var slowdownType: HelperTool.SlowdownType = .defaultSlowdown
    
    var body: some View {
        HStack{
            VStack {
                Form {
                    Picker("Slowdown options:", selection: $slowdownType) {
                        Text("Default").tag(HelperTool.SlowdownType.defaultSlowdown)
                        Text("Dial Up").tag(HelperTool.SlowdownType.dialUp)
                    }
                    .pickerStyle(.inline)
                }
            }
            VStack {
                Button("Test") {
                    appController.test(slowdownType)
                }
                Button("Start slowdown") {
                    appController.startSlowdown(slowdownType: slowdownType)
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
