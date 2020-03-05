//
//  ContentView.swift
//  Full iOS Example
//
//  Created by Etienne Vautherin on 27/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import SwiftUI

struct ServiceView: View {
    @ObservedObject var service: GreatService
//    var service: GreatService
    
    var body: some View {
        Toggle(isOn: service.bindedStarted) {
            HStack {
                service.image
                    .resizable()
                    .frame(width: 32.0, height: 32.0)

                Text(service.name)
            }
        }
    }
}


struct ContentView: View {
    @ObservedObject var model = AppModel.shared
    var body: some View {
        VStack {
            List(model.services) { (service) in
                ServiceView(service: service)
            }
//            Button(action: {
//                self.model.add()
//            }) {
//                Text("Add")
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
