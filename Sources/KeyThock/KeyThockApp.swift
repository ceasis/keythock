import SwiftUI

@main
struct KeyThockApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopoverView()
                .environmentObject(model)
                .frame(width: 360)
        } label: {
            if model.menuBarHasPermissionIssue {
                Image(nsImage: model.menuBarAlertImage)
            } else {
                Image(systemName: model.menuBarSymbol)
            }
        }
        .menuBarExtraStyle(.window)

        WindowGroup("KeyThock", id: "main") {
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
                Button("Open KeyThock") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
