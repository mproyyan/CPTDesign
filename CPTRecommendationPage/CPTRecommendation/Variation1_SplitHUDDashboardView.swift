//
//  Variation1_SplitHUDDashboardView.swift
//  CPTRecommendationPage
//
//  Variation 1: The Split HUD Command (60/40 Split Canvas & XAI Executive Rail)
//

import SwiftUI

public struct Variation1_SplitHUDDashboardView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var showConfirmationAlert = false
    @State private var confirmedActionTitle = ""
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                // MARK: - Left 60%: Interactive Geotechnical Map Canvas
                VStack(alignment: .leading, spacing: 14) {
                    // Top App Header & Telemetry Pill
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CPT-3D SITE OPTIMIZATION")
                                .font(.caption.bold())
                                .foregroundStyle(Color(.secondaryLabel))
                            Text("Sector Alpha-7 Subsurface Investigation")
                                .font(.title3.bold())
                                .foregroundStyle(Color(.label))
                        }
                        Spacer()
                        // Investigation Stage Badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text(siteSnapshot.reasoning.policyUsed.title)
                                .font(.caption.bold())
                                .foregroundStyle(Color.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    // Map Area
                    CPTSiteMapCanvas(
                        completedPoints: siteSnapshot.completedPoints,
                        recommendedPoint: siteSnapshot.recommendedPoint,
                        candidatePoints: siteSnapshot.candidatePoints,
                        activeOverlay: selectedOverlay,
                        showCrossSectionLine: false
                    )
                    
                    // Bottom Map Controls
                    HStack {
                        Picker("Overlay", selection: $selectedOverlay) {
                            ForEach(MapOverlayLayer.allCases) { layer in
                                Label(layer.rawValue, systemImage: layer.iconName).tag(layer)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 520)
                        
                        Spacer()
                        
                        // Site Grid Scale Info
                        Text("Grid: 40 × 40 m • 2.0 m res")
                            .font(.caption2.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .padding(20)
                .frame(width: proxy.size.width * 0.58)
                
                Divider()
                
                // MARK: - Right 40%: Structured XAI Executive Rail
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. Hero Recommendation Banner
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("NEXT DRILL TARGET")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.accentColor)
                                Spacer()
                                Text("Q-Score: \(String(format: "%.3f", siteSnapshot.reasoning.qScore))")
                                    .font(.caption.bold().monospaced())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundStyle(Color.orange)
                                    .clipShape(Capsule())
                            }
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text(siteSnapshot.reasoning.targetCPTCode)
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(.label))
                                Text("E: \(String(format: "%.1f", siteSnapshot.reasoning.easting)) m, N: \(String(format: "%.1f", siteSnapshot.reasoning.northing)) m")
                                    .font(.subheadline.monospaced())
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            
                            // Estimated Impact Callout
                            HStack(spacing: 8) {
                                Image(systemName: "chart.line.downtrend.xyaxis")
                                    .foregroundStyle(.green)
                                Text("Reduces Geological Uncertainty by \(Int(siteSnapshot.reasoning.projectedImpactPercent))%")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.green)
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // 2. Full XAI Narrative Template
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Why This Point?", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                            
                            Text(siteSnapshot.reasoning.formattedFullNarrative)
                                .font(.subheadline)
                                .lineSpacing(4)
                                .foregroundStyle(Color(.label))
                        }
                        .padding(16)
                        .background(Color.accentColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
                        )
                        
                        // 3. Three Reasoning Pillars Breakdown
                        Text("REASONING PILLARS")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.secondaryLabel))
                        
                        // Pillar 1: Spatial
                        PillarCardView(
                            icon: "arrow.triangle.swap",
                            color: .blue,
                            title: "Spatial Blindspot",
                            subtitle: "\(String(format: "%.1f", siteSnapshot.reasoning.nearestCPTDistance)) m from \(siteSnapshot.reasoning.nearestCPTCode)",
                            detail: "Zero observed CPT data within 4 m. Northeast sector holds highest spatial ignorance."
                        )
                        
                        // Pillar 2: Complexity
                        PillarCardView(
                            icon: "layers.fill",
                            color: .purple,
                            title: "Stratigraphic Complexity",
                            subtitle: "SchemaGAN Ic Std: \(String(format: "%.2f", siteSnapshot.reasoning.reconstructedIcStdZ))",
                            detail: siteSnapshot.reasoning.suspectedFeature
                        )
                        
                        // Pillar 3: Efficiency & Stage
                        PillarCardView(
                            icon: "banknote",
                            color: .emeraldGreen,
                            title: "Efficiency & Policy",
                            subtitle: "\(siteSnapshot.reasoning.currentCPTNumber)/\(siteSnapshot.reasoning.totalBudgetCPTs) Pushes • $\(Int(siteSnapshot.reasoning.costThisPushUSD))",
                            detail: siteSnapshot.reasoning.efficiencyReason
                        )
                        
                        Spacer(minLength: 16)
                        
                        // 4. Primary Decision Actions
                        HStack(spacing: 12) {
                            Button(role: .destructive) {
                                confirmedActionTitle = "CPT-04 Rejected. Requesting Alternative..."
                                showConfirmationAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Reject / Override")
                                }
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            
                            Button {
                                confirmedActionTitle = "CPT-04 Accepted! Drilling Order Dispatched to Rig."
                                showConfirmationAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Accept Push")
                                }
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                        }
                    }
                    .padding(20)
                }
                .frame(width: proxy.size.width * 0.42)
                .background(Color(.systemBackground))
            }
        }
        .alert(confirmedActionTitle, isPresented: $showConfirmationAlert) {
            Button("Dismiss", role: .cancel) {}
        }
    }
}

private struct PillarCardView: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(.label))
                    Spacer()
                    Text(subtitle)
                        .font(.caption.bold().monospaced())
                        .foregroundStyle(color)
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
