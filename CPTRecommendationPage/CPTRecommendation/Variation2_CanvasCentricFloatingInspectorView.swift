//
//  Variation2_CanvasCentricFloatingInspectorView.swift
//  CPTRecommendationPage
//
//  Variation 2: Canvas-Centric Floating Inspector (Immersive Map with Glassmorphism Overlays)
//

import SwiftUI

public struct Variation2_CanvasCentricFloatingInspectorView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var isInspectorExpanded = true
    @State private var selectedPillarIndex = 0
    @State private var actionMessage: String?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fullscreen Canvas
            CPTSiteMapCanvas(
                completedPoints: siteSnapshot.completedPoints,
                recommendedPoint: siteSnapshot.recommendedPoint,
                candidatePoints: siteSnapshot.candidatePoints,
                activeOverlay: selectedOverlay
            )
            .ignoresSafeArea(edges: .all)
            
            // Top Floating Island Pill
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.yellow)
                    
                    Text("AI Recommendation Active:")
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    Text(siteSnapshot.reasoning.targetCPTCode)
                        .font(.headline.bold())
                        .foregroundStyle(Color(.label))
                    
                    Text("•")
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    Text("E: \(String(format: "%.1f", siteSnapshot.reasoning.easting)), N: \(String(format: "%.1f", siteSnapshot.reasoning.northing))")
                        .font(.subheadline.monospaced())
                    
                    Text("•")
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    Text("Uncertainty: -28%")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
                .overlay(
                    Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.top, 16)
                
                Spacer()
            }
            
            // Bottom-Leading Overlay Toggle Controls
            VStack {
                Spacer()
                HStack {
                    Picker("Layer", selection: $selectedOverlay) {
                        ForEach(MapOverlayLayer.allCases) { layer in
                            Text(layer.rawValue).tag(layer)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 420)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
                    
                    Spacer()
                }
                .padding(.leading, 24)
                .padding(.bottom, 24)
            }
            
            // Trailing Floating Glass Inspector Card
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 14) {
                    // Card Header with minimize button
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DQN-3D INFERENCE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.accentColor)
                            Text("Explainable Decision Card")
                                .font(.headline.bold())
                        }
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isInspectorExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isInspectorExpanded ? "chevron.right.circle.fill" : "chevron.left.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                    
                    if isInspectorExpanded {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 14) {
                                // Recommendation Box
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(siteSnapshot.reasoning.targetCPTCode)
                                            .font(.title2.bold())
                                        Text("Q: \(String(format: "%.3f", siteSnapshot.reasoning.qScore)) • Gain: 28%")
                                            .font(.caption.monospaced().bold())
                                            .foregroundStyle(Color.orange)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Policy Mode")
                                            .font(.caption2)
                                            .foregroundStyle(Color(.secondaryLabel))
                                        Text(siteSnapshot.reasoning.policyUsed.rawValue)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.15))
                                            .foregroundStyle(Color.green)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground).opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                // Core XAI Narrative
                                Text(siteSnapshot.reasoning.formattedFullNarrative)
                                    .font(.system(size: 13))
                                    .lineSpacing(3)
                                    .foregroundStyle(Color(.label))
                                    .padding(12)
                                    .background(Color.accentColor.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                // Pillar Switcher Tabs
                                Picker("Pillar", selection: $selectedPillarIndex) {
                                    Text("Spatial").tag(0)
                                    Text("Stratigraphy").tag(1)
                                    Text("Cost & Stage").tag(2)
                                }
                                .pickerStyle(.segmented)
                                
                                // Dynamic Pillar Evidence
                                Group {
                                    if selectedPillarIndex == 0 {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Label("Spatial Blindspot Metric", systemImage: "arrow.triangle.swap")
                                                .font(.caption.bold())
                                                .foregroundStyle(Color.blue)
                                            Text("• Nearest CPT: \(siteSnapshot.reasoning.nearestCPTCode) at \(String(format: "%.1f", siteSnapshot.reasoning.nearestCPTDistance)) m")
                                                .font(.caption)
                                            Text("• Density within 4m radius: 0.0 (Complete blindspot)")
                                                .font(.caption)
                                            Text("• Access Mask: Clean ground, outside retention zone.")
                                                .font(.caption)
                                        }
                                    } else if selectedPillarIndex == 1 {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Label("Geological Anomaly Metric", systemImage: "waveform.path.ecg")
                                                .font(.caption.bold())
                                                .foregroundStyle(Color.purple)
                                            Text("• Reconstructed Ic Std Z: \(String(format: "%.2f", siteSnapshot.reasoning.reconstructedIcStdZ))")
                                                .font(.caption)
                                            Text("• Suspected Anomaly: 4.0 m – 8.0 m depth")
                                                .font(.caption)
                                            Text("• Risk: Sharp soft clay boundary unconfirmed.")
                                                .font(.caption)
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Label("Budget & Hybrid Policy", systemImage: "chart.bar.xaxis")
                                                .font(.caption.bold())
                                                .foregroundStyle(Color.emeraldGreen)
                                            Text("• Progress: Push 4 of 12 planned soundings")
                                                .font(.caption)
                                            Text("• Cost this test: $\(Int(siteSnapshot.reasoning.costThisPushUSD))")
                                                .font(.caption)
                                            Text("• Budget remaining: $\(Int(siteSnapshot.reasoning.remainingBudgetUSD))")
                                                .font(.caption)
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Color(.secondarySystemBackground).opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                // Decision Buttons
                                HStack(spacing: 8) {
                                    Button(role: .destructive) {
                                        actionMessage = "Rejected recommendation CPT-04"
                                    } label: {
                                        Text("Reject")
                                            .font(.caption.bold())
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 38)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                    
                                    Button {
                                        actionMessage = "Accepted CPT-04! Dispatching."
                                    } label: {
                                        Text("Accept Push")
                                            .font(.caption.bold())
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 38)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                    }
                }
                .padding(18)
                .frame(width: isInspectorExpanded ? 380 : 80)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: -4, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                )
                .padding(.trailing, 24)
                .padding(.vertical, 24)
            }
        }
        .overlay(
            Group {
                if let msg = actionMessage {
                    Text(msg)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                actionMessage = nil
                            }
                        }
                }
            }
            .padding(.bottom, 30),
            alignment: .bottom
        )
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
