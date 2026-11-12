//
//  SnapzyMockNotesWindow.swift
//  Snapzy
//
//  Faithful floating Apple Notes window component for onboarding walkthrough.
//

import SwiftUI

struct SnapzyMockNotesWindow: View, Equatable {
  static func == (lhs: SnapzyMockNotesWindow, rhs: SnapzyMockNotesWindow) -> Bool {
    true
  }

  var body: some View {
    VStack(spacing: 0) {
      // Notes Window Toolbar
      HStack(spacing: 10) {
        // Traffic Lights
        HStack(spacing: 6.5) {
          Circle().fill(Color(red: 1.0, green: 0.36, blue: 0.33)).frame(width: 10, height: 10)
          Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.18)).frame(width: 10, height: 10)
          Circle().fill(Color(red: 0.15, green: 0.79, blue: 0.25)).frame(width: 10, height: 10)
        }

        // Sidebar and back controls
        HStack(spacing: 5) {
          toolbarControl(systemName: "sidebar.left", size: 11.5)
          toolbarControl(systemName: "chevron.left", size: 10.5)
        }
        .padding(.leading, 4)

        Spacer()

        // Center Title & Subtitle
        VStack(spacing: 0.5) {
          Text(L10n.Demo.copy048)
            .font(.system(size: 11.5, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.88))

          Text("57 notes")
            .font(.system(size: 8.5, weight: .regular))
            .foregroundStyle(Color.black.opacity(0.45))
        }

        Spacer()

        // Right Action Controls
        HStack(spacing: 5) {
          toolbarControl(systemName: "square.and.pencil", size: 11.5)
          toolbarControl(systemName: "chevron.right.2", size: 10.5)
          toolbarControl(systemName: "magnifyingglass", size: 10.5)
        }
      }
      .padding(.horizontal, 14)
      .frame(height: 36)
      .background(Color(white: 0.985))

      Rectangle()
        .fill(Color.black.opacity(0.06))
        .frame(height: 0.5)

      // Note Prose Content
      VStack(alignment: .leading, spacing: 10) {
        Text(L10n.Demo.copy049)
          .font(.system(size: 9.5, weight: .regular))
          .foregroundStyle(Color.black.opacity(0.40))
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.top, 4)

        Text(L10n.Demo.copy050)
          .font(.system(size: 11.5, weight: .regular))
          .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.17))
          .lineSpacing(3.5)

        Text(L10n.Demo.copy051)
          .font(.system(size: 11.5, weight: .regular))
          .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.17))
          .lineSpacing(3.5)

        Text(L10n.Demo.copy052)
          .font(.system(size: 11, weight: .regular))
          .italic()
          .foregroundStyle(Color(red: 0.20, green: 0.20, blue: 0.22))
          .lineSpacing(3)

        Text(L10n.Demo.copy053)
          .font(.system(size: 11.5, weight: .regular))
          .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.17))
      }
      .padding(.horizontal, 18)
      .padding(.top, 10)
      .padding(.bottom, 18)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .background(Color.white)
    }
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .strokeBorder(Color.black.opacity(0.10), lineWidth: 0.5)
    )
    .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 12)
    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
  }

  private func toolbarControl(systemName: String, size: CGFloat) -> some View {
    Image(systemName: systemName)
      .font(.system(size: size, weight: .medium))
      .foregroundStyle(Color.black.opacity(0.65))
      .frame(width: 22, height: 20)
      .background(
        RoundedRectangle(cornerRadius: 5, style: .continuous)
          .fill(Color.black.opacity(0.04))
          .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
              .strokeBorder(Color.black.opacity(0.07), lineWidth: 0.5)
          )
      )
  }
}
