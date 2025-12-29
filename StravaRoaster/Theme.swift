import SwiftUI

extension Color {
    static let roastOrange = Color(red: 1.0, green: 0.4, blue: 0.0)
    static let roastRed = Color(red: 0.9, green: 0.2, blue: 0.1)
    
    static let backgroundGray = Color(uiColor: .systemGray6)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
}

struct RoastButton: ViewModifier {
    let isDestructive: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDestructive ? Color.roastRed : Color.roastOrange)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func roastButtonStyle(destructive: Bool = false) -> some View {
        modifier(RoastButton(isDestructive: destructive))
    }
}
