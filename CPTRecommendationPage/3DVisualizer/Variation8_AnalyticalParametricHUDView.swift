//
//  Variation8_AnalyticalParametricHUDView.swift
//  CPTRecommendationPage
//
//  Variation 8: Parametric Telemetry & Geophysical Logging HUD (Deep Data Density)
//

import SwiftUI
import RealityKit

public struct Variation8_AnalyticalParametricHUDView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var scrubbedDepth: Double = 6.5 // meters
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // HUD Status Bar
            HStack {
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("CPT-3D GEOPHYSICAL TELEMETRY CONSOLE")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                    Text("• Wireline Stream: qc, fs, Ic Normalized")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                Spacer()
                Text("Scrubbed Depth: −\(String(format: "%.1f", scrubbedDepth)) m")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.orange)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Divider()
            
            HStack(spacing: 12) {
                // MARK: - Left 28%: Continuous Geophysical Log Curves
                VStack(alignment: .leading, spacing: 8) {
                    Text("WIRELINE LOG CHANNELS (0–20m)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    HStack(spacing: 8) {
                        LogChannelTrack(channelName: "qc (MPa)", color: .orange, maxVal: 30.0, currentVal: 1.2)
                        LogChannelTrack(channelName: "fs (kPa)", color: .blue, maxVal: 200.0, currentVal: 22.0)
                        LogChannelTrack(channelName: "Ic Index", color: .purple, maxVal: 4.0, currentVal: 3.22)
                    }
                    
                    // Depth Scrubber Slider
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Depth Slicer Plane:")
                            .font(.caption2.bold())
                        Slider(value: $scrubbedDepth, in: 0...20)
                            .tint(.orange)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(width: 250)
                
                Divider()
                
                // MARK: - Center 44%: RealityKit 3D Volume Viewport
                VStack(spacing: 8) {
                    RealityKitSoilVolumeView(
                        slicingState: $slicingState,
                        selectedBorehole: SubsurfaceMockData.sampleBoreholeVirtual,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                    
                    HStack(spacing: 12) {
                        Text("Cut N:")
                        Slider(value: $slicingState.northingSlice, in: 0...40).tint(.red)
                        Text("Cut E:")
                        Slider(value: $slicingState.eastingSlice, in: 0...40).tint(.cyan)
                    }
                    .padding(6)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right 28%: Bearing Map, Foundation & Advisor
                VStack(spacing: 10) {
                    Text("BEARING STRATUM CONTOURS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    BearingLayerDepthMapView(
                        selectedCoordinate: selectedCoordinate,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                    .frame(height: 150)
                    
                    AIAdvisorPanelView(
                        advice: SubsurfaceMockData.adviceForBorehole(SubsurfaceMockData.sampleBoreholeVirtual),
                        foundationReport: SubsurfaceMockData.foundationReport,
                        hazards: SubsurfaceMockData.hazardAlerts
                    )
                }
                .frame(width: 310)
            }
            .padding(12)
        }
    }
}

private struct LogChannelTrack: View {
    let channelName: String
    let color: Color
    let maxVal: Double
    let currentVal: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text(channelName)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(color)
            
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.secondarySystemBackground))
                    
                    // Synthetic curve line
                    Path { p in
                        p.move(to: CGPoint(x: geo.size.width * 0.4, y: 0))
                        p.addLine(to: CGPoint(x: geo.size.width * 0.6, y: geo.size.height * 0.2))
                        p.addLine(to: CGPoint(x: geo.size.width * 0.15, y: geo.size.height * 0.4))
                        p.addLine(to: CGPoint(x: geo.size.width * 0.35, y: geo.size.height * 0.7))
                        p.addLine(to: CGPoint(x: geo.size.width * 0.9, y: geo.size.height))
                    }
                    .stroke(color, lineWidth: 1.5)
                }
            }
            .frame(height: 320)
            
            Text(String(format: "%.1f", currentVal))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}
