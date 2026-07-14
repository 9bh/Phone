import SwiftUI

struct HistoryView: View {
    init() {}
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 56))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("No Activity Yet")
                        .font(.headline)
                    
                    Text("Recent vault activity will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("History")
    }
}
