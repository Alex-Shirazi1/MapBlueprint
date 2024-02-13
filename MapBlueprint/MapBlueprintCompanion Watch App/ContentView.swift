//
//  ContentView.swift
//  MapBlueprintCompanion Watch App
//
//  Created by Alex Shirazi on 2/12/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "fuelpump.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
