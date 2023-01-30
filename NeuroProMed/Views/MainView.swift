//
//  MainView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 11.06.2021.
//

import SwiftUI

extension MainView {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var selectedTab = 0
        
        @Published var alertMessage = ""
        @Published var activeAlert: ActiveAlert?
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
        
        func loadData() async {
            do {
                try await appState.loadData()
            } catch {
                print("")
            }
        }
    }
}

struct MainView: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            if viewModel.isUserDoctor {
                PatientsView(viewModel: .init(), appState: appState)
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text(label(.patients))
                    }
                    .tag(0)
            }
            AppointmentsView(viewModel: .init(), appState: appState)
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text(label(.appointments))
                }
                .tag(1)
            ProfileView(viewModel: .init(), appState: appState)
                .tabItem {
                    Image(systemName: "person.crop.rectangle.fill")
                    Text(label(.myProfile))
                }
                .tag(2)
        }
        .listStyle(.insetGrouped)
        .task {
            await viewModel.loadData()
        }
        .onReceive(appState.$selectedAppointmentID) { publisher in
            viewModel.selectedTab = 1
        }
        .alert(item: $viewModel.activeAlert) { item in
            switch item {
            case .warning:
                fallthrough
            case .error:
                return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            case .settingsIssue:
                return Alert(
                    title: Text(label(.biometricsPermissionDenied)),
                    message: Text(viewModel.alertMessage),
                    primaryButton: .cancel(),
                    secondaryButton: .default(Text(label(.appSettings)), action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                )
            }
            
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: .init(), appState: .shared)
    }
}
