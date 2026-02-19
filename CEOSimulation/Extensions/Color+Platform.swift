import SwiftUI

extension Color {
    /// Replaces `Color(.systemGray6)` — card/container backgrounds
    static var platformCardBackground: Color {
        #if os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color(.systemGray6)
        #endif
    }

    /// Replaces `Color(.systemGray5)` — secondary/inset backgrounds
    static var platformSecondaryBackground: Color {
        #if os(macOS)
        Color(NSColor.underPageBackgroundColor)
        #else
        Color(.systemGray5)
        #endif
    }

    /// Replaces `Color(.systemGray4)` — tertiary fills / track backgrounds
    static var platformTertiaryFill: Color {
        #if os(macOS)
        Color(NSColor.separatorColor)
        #else
        Color(.systemGray4)
        #endif
    }

    /// Window/sheet background — replaces UIColor.systemBackground / NSColor.windowBackgroundColor
    static var platformWindowBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
}
