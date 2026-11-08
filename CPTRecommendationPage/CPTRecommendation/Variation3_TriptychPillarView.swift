//
//  Variation3_TriptychPillarView.swift
//  CPTRecommendationPage
//
//  Variation 3: The Triptych Three-Pillar Matrix (Equal 3-Column Evidence Layout)
//

import SwiftUI

public struct Variation3_TriptychPillarView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .uncertainty
    @State private var alertTitle: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D TRIPTYCH EVIDENCE MATRIX")
                        .font(.caption.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Subsurface Investigation Decision Support")
                        .font(.headline.bold())
                }
                Spacer()
                HStack(spacing: 8) {
                    Text("RECOMMENDATION: \(siteSnapshot.reasoning.targetCPTCode)")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.accentColor)
                    Text("•")
                        .foregroundStyle(Color(.secondaryLabel))
                    Text(siteSnapshot.reasoning.policyUsed.title)
                        .font(.caption.monospaced().bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(Color.green)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // 3 Equal Pillars
            HStack(spacing: 16) {
                // MARK: - Column 1: Spatial Pillar (Blindspot Evidence)
                VStack(alignment: .leading, spacing: 12) {
                    PillarHeaderBadge(
                        number: "1",
                        title: "SPATIAL BLINDSPOT",
                        color: .blue,
                        metric: "\(String(format: "%.1f", siteSnapshot.reasoning.nearestCPTDistance)) m Gap"
                    )
                    
                    CPTSiteMapCanvas(
                        completedPoints: siteSnapshot.completedPoints,
                        recommendedPoint: siteSnapshot.recommendedPoint,
                        candidatePoints: siteSnapshot.candidatePoints,
                        activeOverlay: selectedOverlay
                    )
                    .frame(height: 320)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        MetricRow(label: "Nearest Neighbor", value: "\(siteSnapshot.reasoning.nearestCPTCode) (14.2 m)")
                        MetricRow(label: "Data Density (4m radius)", value: "0.0 points")
                        MetricRow(label: "Action Mask Status", value: "Valid (No building/water)")
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Picker("Overlay", selection: $selectedOverlay) {
                        ForEach(MapOverlayLayer.allCases) { layer in
                            Text(layer.rawValue).tag(layer)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Column 2: Complexity Pillar (Stratigraphy & Anomaly)
                VStack(alignment: .leading, spacing: 12) {
                    PillarHeaderBadge(
                        number: "2",
                        title: "STRATIGRAPHIC ANOMALY",
                        color: .purple,
                        metric: "Ic Std: \(String(format: "%.2f", siteSnapshot.reasoning.reconstructedIcStdZ))"
                    )
                    
                    // Predicted Robertson SBT Soil Column
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Robertson SBT Predicted Soil Column (0–20 m)")
                                .font(.caption.bold())
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Text("SchemaGAN 3D")
                                .font(.caption2.bold())
                                .foregroundStyle(Color.purple)
                        }
                        
                        SoilStratigraphyColumnView(layers: siteSnapshot.projectedLayers)
                            .frame(height: 320)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Critical Anomaly (4.0 - 8.0 m)")
                                .font(.caption.bold())
                                .foregroundStyle(.orange)
                        }
                        Text(siteSnapshot.reasoning.complexityReason)
                            .font(.caption)
                            .foregroundStyle(Color(.label))
                            .lineSpacing(2)
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Column 3: Efficiency & Decision Pillar
                VStack(alignment: .leading, spacing: 14) {
                    PillarHeaderBadge(
                        number: "3",
                        title: "EFFICIENCY & VALUE",
                        color: .emeraldGreen,
                        metric: "+28% Gain"
                    )
                    
                    // Recommendation Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TARGET SOUNDING")
                            .font(.caption2.bold())
                            .foregroundStyle(Color(.secondaryLabel))
                        Text(siteSnapshot.reasoning.targetCPTCode)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(Color.accentColor)
                        
                        Text("Coordinates: E \(String(format: "%.1f", siteSnapshot.reasoning.easting)) m, N \(String(format: "%.1f", siteSnapshot.reasoning.northing)) m")
                            .font(.subheadline.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Synthesized Reasoning Box
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SYNTHESIZED RATIONALE")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.accentColor)
                        Text(siteSnapshot.reasoning.formattedFullNarrative)
                            .font(.caption)
                            .lineSpacing(3)
                            .foregroundStyle(Color(.label))
                    }
                    .padding(12)
                    .background(Color.accentColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Budget Progress
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Investigation Budget")
                                .font(.caption.bold())
                            Spacer()
                            Text("$\(Int(siteSnapshot.reasoning.costThisPushUSD)) per CPT")
                                .font(.caption2.monospaced())
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        ProgressView(value: Double(siteSnapshot.reasoning.currentCPTNumber), total: Double(siteSnapshot.reasoning.totalBudgetCPTs))
                            .tint(.emeraldGreen)
                        HStack {
                            Text("CPT 4 of 12 completed")
                                .font(.caption2)
                            Spacer()
                            Text("$\(Int(siteSnapshot.reasoning.remainingBudgetUSD)) remaining")
                                .font(.caption2.monospaced().bold())
                                .foregroundStyle(Color.emeraldGreen)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                    
                    // Decision Action Buttons
                    VStack(spacing: 10) {
                        Button {
                            alertTitle = "Accepted CPT-04. Work order issued."
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Accept Recommendation")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        
                        Button(role: .destructive) {
                            alertTitle = "Rejected CPT-04. Re-evaluating next best alternative."
                        } label: {
                            Text("Reject / Choose Alternative")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .alert(alertTitle ?? "", isPresented: Binding(
            get: { alertTitle != nil },
            set: { if !$0 { alertTitle = nil } }
        )) {
            Button("OK", role: .cancel) {}
        }
    }
}

// MARK: - Soil Stratigraphy Column Subcomponent
public struct SoilStratigraphyColumnView: View {
    public let layers: [StratigraphyLayer]
    
    public init(layers: [StratigraphyLayer]) {
        self.layers = layers
    }
    
    public var body: some View {
        VStack(spacing: 2) {
            ForEach(layers) { layer in
                let heightRatio = (layer.depthEnd - layer.depthStart) / 20.0
                HStack(spacing: 10) {
                    // Depth label
                    Text(String(format: "%.1fm", layer.depthStart))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .frame(width: 32, alignment: .trailing)
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    // Stratigraphy Block
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(layer.color)
                        
                        if layer.isAnomaly {
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(Color.red, lineWidth: 2)
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(layer.sbtName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                Text("Ic: \(String(format: "%.2f", layer.icMean)) • qc: \(String(format: "%.1f", layer.coneResistanceQc)) MPa")
                                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Color.black.opacity(0.7))
                            }
                            Spacer()
                            if layer.isAnomaly {
                                Text("ANOMALY")
                                    .font(.system(size: 8, weight: .heavy))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.red)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .frame(height: max(28, CGFloat(heightRatio * 260)))
                }
            }
            // Bottom 20m label
            HStack {
                Text("20.0m")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .frame(width: 32, alignment: .trailing)
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
            }
        }
    }
}

private struct PillarHeaderBadge: View {
    let number: String
    let title: String
    let color: Color
    let metric: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(number)
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(color)
                .foregroundStyle(.white)
                .clipShape(Circle())
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(Color(.label))
            Spacer()
            Text(metric)
                .font(.caption2.monospaced().bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(Capsule())
        }
    }
}

private struct MetricRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            Text(value)
                .font(.caption.monospaced().bold())
                .foregroundStyle(Color(.label))
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
