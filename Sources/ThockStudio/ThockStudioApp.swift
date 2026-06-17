import SwiftUI

@main
struct ThockStudioApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopoverView()
                .environmentObject(model)
                .frame(width: 360)
        } label: {
            Image(systemName: model.menuBarSymbol)
        }
        .menuBarExtraStyle(.window)

        WindowGroup("Thock Studio", id: "main") {
            RootWindowView()
                .environmentObject(model)
                .frame(minWidth: 760, minHeight: 520)
                .onAppear {
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
        .defaultSize(width: 920, height: 640)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Open Thock Studio") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
