import SwiftUI

struct SettingsView: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var isShowingChangePasscode: Bool = false
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    var body: some View {
        List {
            Section(header: Text("Security")) {
                Toggle("Face ID", isOn: $sessionManager.isBiometricEnabled)
                
                Picker("Auto Lock", selection: $sessionManager.autoLockDuration) {
                    ForEach(AutoLockDuration.allCases) { duration in
                        Text(duration.title).tag(duration)
                    }
                }
            }
            
            Section(header: Text("Account")) {
                HStack {
                    Text("Recovery Email")
                    Spacer()
                    Text(sessionManager.recoveryEmail ?? "Not Configured")
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Button("Change Passcode") {
                    isShowingChangePasscode = true
                }
                .foregroundColor(.accentColor)
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build Number")
                    Spacer()
                    Text(appBuild)
                        .foregroundColor(.secondary)
                }
            }
            
            #if DEBUG
            Section(header: Text("Developer Debug Section")) {
                HStack {
                    Text("Environment")
                    Spacer()
                    Text("Debug")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(appBuild)
                        .foregroundColor(.secondary)
                }
                
                Button("Simulate App Lock") {
                    sessionManager.simulateLock()
                }
                .foregroundColor(.orange)
                
                Button("Reset to First Setup") {
                    sessionManager.resetToFirstSetup()
                }
                .foregroundColor(.red)
            }
            #endif
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $isShowingChangePasscode) {
            ChangePasscodeView()
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
