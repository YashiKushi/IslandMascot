import ActivityKit
import SwiftUI
import WidgetKit

/// Конфигурация Live Activity & Dynamic Island
struct IslandMascotDynamicIslandWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MascotAttributes.self) { context in
            // Представление для Экрана блокировки (Lock Screen Banner)
            LockScreenMascotBanner(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // РАЗВЕРНУТЫЙ ВИД ОСТРОВА (Expanded)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text(context.state.faceEmoji)
                            .font(.system(size: 32))
                        Text(context.state.emoji)
                            .font(.system(size: 18))
                    }
                    .padding(.leading, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 3) {
                        HStack(spacing: 4) {
                            Text("💖")
                            Text("\(Int(context.state.happiness))%")
                                .font(.caption2)
                                .bold()
                        }
                        HStack(spacing: 4) {
                            Text("⚡️")
                            Text("\(Int(context.state.energy))%")
                                .font(.caption2)
                                .bold()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 4)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.state.mascotName)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        Text(context.state.statusText)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                        Text(context.state.thought)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                    )
                    .padding(.top, 4)
                }
            } compactLeading: {
                // КОМПАКТНЫЙ ВИД СЛЕВА
                HStack(spacing: 2) {
                    Text(context.state.faceEmoji)
                        .font(.system(size: 14))
                }
                .padding(.leading, 4)
            } compactTrailing: {
                // КОМПАКТНЫЙ ВИД СПРАВА
                HStack(spacing: 2) {
                    Text(context.state.emoji)
                        .font(.system(size: 12))
                    Text("\(Int(context.state.happiness))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.pink)
                }
                .padding(.trailing, 4)
            } minimal: {
                // МИНИМАЛЬНЫЙ ВИД (когда несколько Live Activities)
                Text(context.state.faceEmoji)
                    .font(.system(size: 12))
            }
            .keylineTint(.accentColor)
        }
    }
}

/// Представление на экране блокировки
struct LockScreenMascotBanner: View {
    var state: MascotAttributes.ContentState
    
    var body: some View {
        HStack(spacing: 12) {
            Text(state.faceEmoji)
                .font(.system(size: 42))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(state.mascotName)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                    Text("• \(state.statusText)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(state.emoji)
                }
                
                Text(state.thought)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    Text("🍔 \(Int(state.hunger))%")
                    Text("⚡️ \(Int(state.energy))%")
                    Text("💖 \(Int(state.happiness))%")
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(14)
    }
}

