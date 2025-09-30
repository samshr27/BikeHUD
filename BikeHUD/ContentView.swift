//
//  ContentView.swift
//  BikeHUD
//
//  Created by Samuel Shrestha on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tracker = RideTracker()
    @AppStorage("units") private var units: String = "mph"
    @State private var startDate = Date()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Text(formattedSpeed)
                    .font(.system(size: 140, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)

                HStack(spacing: 24) {
                    tile("Avg", value: formattedAvg)
                    tile("Dist", value: formattedDistance)
                    tile("Time", value: rideTimeString)
                }

                Spacer()

                Picker("Units", selection: $units) {
                    Text("mph").tag("mph")
                    Text("km/h").tag("kmh")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            .padding()
            .onAppear {
                tracker.requestPermission()
                startDate = Date()
            }
        }
        .statusBarHidden(true)
        .preferredColorScheme(.dark)
    }

    // MARK: Derived
    private var speedConverted: Double {
        tracker.speedMps * (units == "mph" ? 2.23693629 : 3.6)
    }
    private var elapsed: TimeInterval { Date().timeIntervalSince(startDate) }
    private var avgSpeed: Double {
        let mps = tracker.distanceMeters / max(1, elapsed)
        return mps * (units == "mph" ? 2.23693629 : 3.6)
    }

    private var formattedSpeed: String { String(format: "%.0f", speedConverted) + (units == "mph" ? " mph" : " km/h") }
    private var formattedAvg: String { String(format: "%.1f", avgSpeed) }
    private var formattedDistance: String {
        if units == "mph" { String(format: "%.2f mi", tracker.distanceMeters / 1609.344) }
        else { String(format: "%.2f km", tracker.distanceMeters / 1000.0) }
    }
    private var rideTimeString: String {
        let t = Int(elapsed); let h=t/3600, m=(t%3600)/60, s=t%60
        return (h>0 ? "\(h)h " : "") + String(format: "%02dm %02ds", m, s)
    }

    private func tile(_ title: String, value: String) -> some View {
        VStack {
            Text(value).font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.white.opacity(0.7))
        }
        .padding(.vertical, 8).padding(.horizontal, 12)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

