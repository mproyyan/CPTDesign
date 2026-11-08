//
//  Variation6_CrossSectionSoilStratigraphyView.swift
//  CPTRecommendationPage
//
//  Variation 6: Subsurface Cross-Section & Dual-Sync Canvas (Plan View + Subsurface Slice)
//

import SwiftUI

public struct Variation6_CrossSectionSoilStratigraphyView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var selectedDepthForInspection: Double?
    @State private var executionState = "Pending Review"
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation & Hero Status Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D DUAL-PROJECTION INSPECTOR")
                        .font(.caption.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Surface Grid (Plan) & Subsurface Profile A-A'")
                        .font(.headline.bold())
                }
                Spacer()
                HStack(spacing: 12) {
                    Label(siteSnapshot.reasoning.policyUsed.title, systemImage: "arrow.triangle.branch")
                        .font(.caption.bold())
                        .foregroundStyle(Color.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Text("Status: \(executionState)")
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(executionState == "Pending Review" ? Color.orange : Color.green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // Top Half: Plan View Map with Cutting Line A-A'
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("PLAN VIEW (SITE GRID 40×40m)")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Spacer()
                    Picker("Overlay", selection: $selectedOverlay) {
                        ForEach(MapOverlayLayer.allCases) { layer in
                            Text(layer.rawValue).tag(layer)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 380)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                CPTSiteMapCanvas(
                    completedPoints: siteSnapshot.completedPoints,
                    recommendedPoint: siteSnapshot.recommendedPoint,
                    candidatePoints: siteSnapshot.candidatePoints,
                    activeOverlay: selectedOverlay,
                    showCrossSectionLine: true
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            }
            .frame(maxHeight: .infinity)
            
            Divider()
            
            // Bottom Half: Vertical Stratigraphy Cross-Section & XAI Rationale Panel
            HStack(spacing: 16) {
                // Stratigraphic Cross-Section Slice
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 6) {
                            Text("A - A'")
                                .font(.caption.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            Text("SchemaGAN 3D Predicted Stratigraphy at Northing 16.0 m")
                                .font(.caption.bold())
                        }
                        Spacer()
                        Text("Robertson SBT (1990)")
                            .font(.caption2.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    SoilStratigraphyHorizontalSliceView(layers: siteSnapshot.projectedLayers)
                        .frame(maxHeight: .infinity)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity)
                
                // Right XAI Justification Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RECOMMENDED POINT")
                                .font(.caption2.bold())
                                .foregroundStyle(Color.accentColor)
                            Text(siteSnapshot.reasoning.targetCPTCode)
                                .font(.title2.bold())
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Q-Score: \(String(format: "%.3f", siteSnapshot.reasoning.qScore))")
                                .font(.caption.monospaced().bold())
                                .foregroundStyle(Color.orange)
                            Text("Gain: -\(Int(siteSnapshot.reasoning.projectedImpactPercent))% Error")
                                .font(.caption2.bold())
                                .foregroundStyle(Color.green)
                        }
                    }
                    
                    // Core XAI Sentence
                    Text(siteSnapshot.reasoning.formattedFullNarrative)
                        .font(.system(size: 11))
                        .lineSpacing(2)
                        .foregroundStyle(Color(.label))
                        .padding(8)
                        .background(Color.accentColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 3 Metric Pills
                    HStack(spacing: 8) {
                        MiniStatPill(title: "Spatial", value: "14.2 m", color: .blue)
                        MiniStatPill(title: "Anomaly", value: "4-8 m", color: .purple)
                        MiniStatPill(title: "Budget", value: "4/12 CPT", color: .emeraldGreen)
                    }
                    
                    Spacer()
                    
                    // Actions
                    HStack(spacing: 8) {
                        Button(role: .destructive) {
                            executionState = "Sounding Skipped"
                        } label: {
                            Text("Reject")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button {
                            executionState = "CPT-04 Dispatched"
                        } label: {
                            Text("Accept Push")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                }
                .padding(14)
                .frame(width: 360)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .frame(height: 250)
        }
    }
}

private struct SoilStratigraphyHorizontalSliceView: View {
    let layers: [StratigraphyLayer]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 2) {
                ForEach(layers) { layer in
                    let depthSpan = layer.depthEnd - layer.depthStart
                    let layerHeight = (depthSpan / 20.0) * geo.size.height
                    
                    HStack(spacing: 8) {
                        Text(String(format: "%.1fm", layer.depthStart))
                            .font(.system(size: 9, design: .monospaced))
                            .frame(width: 34, alignment: .trailing)
                            .foregroundStyle(Color(.secondaryLabel))
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(layer.color)
                            
                            if layer.isAnomaly {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(Color.red, lineWidth: 2)
                            }
                            
                            HStack {
                                Text(layer.sbtName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                Spacer()
                                if layer.isAnomaly {
                                    Text("HIGH ANOMALY (Ic: \(String(format: "%.2f", layer.icMean)))")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .frame(height: max(22, layerHeight - 2))
                    }
                }
            }
        }
    }
}

private struct MiniStatPill: View {
    let title: String
    let value: String
    let color: Color
    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
