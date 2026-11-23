import SwiftUI

public struct StatBarView: View {
    public var title: String
    public var value: Double
    public var color: Color
    public var sfSymbol: String
    
    public init(title: String, value: Double, color: Color, sfSymbol: String) {
        self.title = title
        self.value = value
        self.color = color
        self.sfSymbol = sfSymbol
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.16))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.85), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width * CGFloat(value / 100.0), geo.size.width)), height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: value)
                }
            }
            .frame(height: 8)
        }
    }
}
