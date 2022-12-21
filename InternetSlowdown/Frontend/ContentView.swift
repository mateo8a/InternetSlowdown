//
//  ContentView.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import SwiftUI

struct ContentView: View {
    @NSApplicationDelegateAdaptor private var appController: AppController
    
    @State var typeOfSlowdown: HelperTool.TypeOfSlowdown = .defaultSlowdown
    
    var body: some View {
        HStack{
            VStack {
                Form {
                    Picker("Slowdown options:", selection: $typeOfSlowdown) {
                        Text("Default").tag(HelperTool.TypeOfSlowdown.defaultSlowdown)
                        Text("Dial Up").tag(HelperTool.TypeOfSlowdown.dialUp)
                    }
                    .pickerStyle(.inline)
                }
            }
            VStack {
                Button("Test") {
                    appController.test(typeOfSlowdown)
                }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
