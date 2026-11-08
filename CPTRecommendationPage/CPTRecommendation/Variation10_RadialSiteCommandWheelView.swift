//
//  Variation10_RadialSiteCommandWheelView.swift
//  CPTRecommendationPage
//
//  Variation 10: Radial Site Command Wheel (Spatial Context with Circular Pillar Telemetry)
//

import SwiftUI

public struct Variation10_RadialSiteCommandWheelView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var commandStatus: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "safari.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("RADIAL SITE COMMAND WHEEL")
                        .font(.headline.bold())
                    Text("•")
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Polar Sector Analytics & Sequential Optimization")
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }
                Spacer()
                Picker("Overlay", selection: $selectedOverlay) {
                    ForEach(MapOverlayLayer.allCases) { layer in
                        Text(layer.rawValue).tag(layer)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 340)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // 3-Section Radial Command Interface
            HStack(spacing: 16) {
                // MARK: - Left Rail: Sector Telemetry Diagnostics
                VStack(alignment: .leading, spacing: 12) {
                    Text("QUADRANT TELEMETRY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    QuadrantCard(
                        sector: "NE Quadrant (0° - 90°)",
                        status: "CRITICAL BLINDSPOT",
                        statusColor: .orange,
                        detail: "14.2m gap to CPT-02. Highest model variance. CPT-04 is located here."
                    )
                    
                    QuadrantCard(
                        sector: "NW Quadrant (270° - 360°)",
                        status: "SURFACE RESTRICTION",
                        statusColor: .blue,
                        detail: "Retention pond detected. Points masked out by DQN action mask."
                    )
                    
                    QuadrantCard(
                        sector: "SE Quadrant (90° - 180°)",
                        status: "OBSTACLE MASKED",
                        statusColor: .secondary,
                        detail: "Existing building structure footprint. Penetrations prohibited."
                    )
                    
                    QuadrantCard(
                        sector: "SW Quadrant (180° - 270°)",
                        status: "OBSERVED & STABLE",
                        statusColor: .green,
                        detail: "CPT-01 observed (depth 18.5m). Low stratigraphic uncertainty."
                    )
                    
                    Spacer()
                }
                .frame(width: 260)
                
                Divider()
                
                // MARK: - Center: Circular Polar Site Map Portal
                VStack(spacing: 8) {
                    HStack {
                        Text("POLAR GRID PORTAL (SITE CENTROID 20m, 20m)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(.secondaryLabel))
                        Spacer()
                        Text("Bearing: 056° (NE) • Radius: 5.7m from Center")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    ZStack {
                        // Circular Radar Rings
                        Canvas { context, size in
                            let center = CGPoint(x: size.width / 2, y: size.height / 2)
                            let radii: [CGFloat] = [size.width * 0.15, size.width * 0.30, size.width * 0.45]
                            for r in radii {
                                var p = Path()
                                p.addArc(center: center, radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                                context.stroke(p, with: .color(Color(.separator).opacity(0.4)), lineWidth: 1)
                            }
                        }
                        
                        CPTSiteMapCanvas(
                            completedPoints: siteSnapshot.completedPoints,
                            recommendedPoint: siteSnapshot.recommendedPoint,
                            candidatePoints: siteSnapshot.candidatePoints,
                            activeOverlay: selectedOverlay
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right Rail: XAI Pillars & Command Deck
                VStack(alignment: .leading, spacing: 14) {
                    Text("RADIAL DECISION ENGINE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    // Recommendation Hero
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(siteSnapshot.reasoning.targetCPTCode)
                                .font(.title.bold())
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Text("Q: 0.914")
                                .font(.subheadline.monospaced().bold())
                                .foregroundStyle(Color.orange)
                        }
                        Text("E: 24.0 m, N: 16.0 m")
                            .font(.caption.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Full Narrative Card
                    Text(siteSnapshot.reasoning.formattedFullNarrative)
                        .font(.system(size: 11))
                        .lineSpacing(2)
                        .padding(10)
                        .background(Color.accentColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 3 Pillar Progress Bars
                    VStack(alignment: .leading, spacing: 10) {
                        PillarArcRow(name: "Pillar 1: Spatial Gap", stat: "14.2 m", progress: 0.71, color: .blue)
                        PillarArcRow(name: "Pillar 2: Ic Variance", stat: "0.86 σ", progress: 0.86, color: .purple)
                        PillarArcRow(name: "Pillar 3: Plan Progress", stat: "4/12 CPT", progress: 0.33, color: .emeraldGreen)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                    
                    // Actions
                    VStack(spacing: 8) {
                        Button {
                            commandStatus = "CPT-04 Confirmed! Sounding Initiated."
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Engage CPT-04")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        
                        Button(role: .destructive) {
                            commandStatus = "CPT-04 Rejected. Searching other sectors."
                        } label: {
                            Text("Reject / Shift Sector")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .frame(width: 280)
            }
            .padding(16)
        }
        .overlay(
            Group {
                if let status = commandStatus {
                    Text(status)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                commandStatus = nil
                            }
                        }
                }
            }
            .padding(.bottom, 24),
            alignment: .bottom
        )
    }
}

private struct QuadrantCard: View {
    let sector: String
    let status: String
    let statusColor: Color
    let detail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(sector)
                    .font(.system(size: 11, weight: .bold))
                Spacer()
            }
            Text(status)
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .foregroundStyle(statusColor)
            Text(detail)
                .font(.system(size: 10))
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(2)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct PillarArcRow: View {
    let name: String
    let stat: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
                Text(stat)
                    .font(.caption2.monospaced().bold())
                    .foregroundStyle(color)
            }
            ProgressView(value: progress)
                .tint(color)
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
