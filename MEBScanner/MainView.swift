//
//  MainView.swift
//  MEBScanner
//
//  Created by Tolnai Zoltán on 25/02/2024.
//

import SwiftUI

struct MainView: View {

    @State private var selectedTab = 0
    @StateObject var manager = ConnectionManager.shared()
    
    var tabItems: [TabItem] = [
        TabItem(image: "gauge.with.dots.needle.bottom.50percent", label: "Dashboard", view: DashboardView(), tag: 0),
        TabItem(image: "apple.terminal", label: "Terminal", view: TerminalView(), tag: 1),
        TabItem(image: "gearshape", label: "Settings", view: SettingsView(), tag: 2),
    ]
    
    var body: some View {
        VStack(alignment: .leading){
            TabView(selection: $selectedTab) {
                ForEach(tabItems) { item in
                    AnyView(item.view)
                        .tabItem {
                            Label(item.label, systemImage: item.image)
                        }
                        .tag(item.tag)
                }
            }
        }.environmentObject(manager)
    }
}

#Preview {
    MainView()
}
