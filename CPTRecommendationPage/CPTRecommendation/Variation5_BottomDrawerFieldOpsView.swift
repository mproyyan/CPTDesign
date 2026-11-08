//
//  Variation5_BottomDrawerFieldOpsView.swift
//  CPTRecommendationPage
//
//  Variation 5: Rugged Field-Ops Bottom Sheet (Tactical Landscape Split with Heavy Touch Targets)
//

import SwiftUI

public struct Variation5_BottomDrawerFieldOpsView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var showingConfirmation = false
    @State private var statusFeedback: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top 52%: Tactical Map View with Large Mode Controls
            ZStack(alignment: .topTrailing) {
                CPTSiteMapCanvas(
                    completedPoints: siteSnapshot.completedPoints,
                    recommendedPoint: siteSnapshot.recommendedPoint,
                    candidatePoints: siteSnapshot.candidatePoints,
                    activeOverlay: selectedOverlay
                )
                
                // Overlay controls placed as prominent floating buttons
                HStack(spacing: 8) {
                    ForEach(MapOverlayLayer.allCases) { layer in
                        Button {
                            selectedOverlay = layer
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: layer.iconName)
                                Text(layer.rawValue)
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(selectedOverlay == layer ? Color.accentColor : Color(.systemBackground).opacity(0.85))
                            .foregroundStyle(selectedOverlay == layer ? Color.white : Color(.label))
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(16)
            }
            .frame(maxHeight: .infinity)
            
            Divider()
            
            // Bottom 48%: High-Contrast Field-Ops Drawer
            VStack(spacing: 12) {
                // Tactical Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text("TARGET SOUNDING")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(Color.accentColor)
                            Text("•")
                                .foregroundStyle(Color(.secondaryLabel))
                            Text("STAGE: SMART EXPLORATION (DQN)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.green)
                        }
                        HStack(spacing: 12) {
                            Text(siteSnapshot.reasoning.targetCPTCode)
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundStyle(Color(.label))
                            Text("E: \(String(format: "%.1f", siteSnapshot.reasoning.easting)) m • N: \(String(format: "%.1f", siteSnapshot.reasoning.northing)) m")
                                .font(.headline.monospaced().bold())
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                    Spacer()
                    // Uncertainty Gain Highlight
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("GAIN VALUE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("+28% MODEL CONFIDENCE")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // 3 Prominent Tactical Pillar Cards
                HStack(spacing: 12) {
                    // Pillar 1: Spatial
                    TacticalPillarTile(
                        icon: "scope",
                        badge: "SPATIAL BLINDSPOT",
                        badgeColor: .blue,
                        mainStat: "\(String(format: "%.1f", siteSnapshot.reasoning.nearestCPTDistance)) m Gap",
                        caption: "Farthest from existing CPTs. 0 tests within 4 m."
                    )
                    
                    // Pillar 2: Geology Anomaly
                    TacticalPillarTile(
                        icon: "exclamationmark.triangle.fill",
                        badge: "GEOLOGY ANOMALY",
                        badgeColor: .orange,
                        mainStat: "4.0 – 8.0 m Depth",
                        caption: "SchemaGAN warns of possible soft clay lens (Ic > 2.95)."
                    )
                    
                    // Pillar 3: Budget & Rig
                    TacticalPillarTile(
                        icon: "dollarsign.circle.fill",
                        badge: "BUDGET & SCHEDULE",
                        badgeColor: .emeraldGreen,
                        mainStat: "Push 4 of 12",
                        caption: "Cost: $\(Int(siteSnapshot.reasoning.costThisPushUSD)) • $\(Int(siteSnapshot.reasoning.remainingBudgetUSD)) remaining."
                    )
                }
                
                // Large 54pt Touch Buttons for Gloved Rig Use
                HStack(spacing: 16) {
                    Button(role: .destructive) {
                        statusFeedback = "Sounding Deferred / Rejected. Operator Override."
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill")
                                .font(.title3)
                            Text("HOLD / REJECT PUSH")
                                .font(.headline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button {
                        statusFeedback = "CPT-04 APPROVED! Rig hydraulics engaged."
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title3)
                            Text("CONFIRM & PUSH CPT-04")
                                .font(.title3.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
        }
        .overlay(
            Group {
                if let feedback = statusFeedback {
                    Text(feedback)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.9))
                        .clipShape(Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                statusFeedback = nil
                            }
                        }
                }
            }
            .padding(.bottom, 80),
            alignment: .bottom
        )
    }
}

private struct TacticalPillarTile: View {
    let icon: String
    let badge: String
    let badgeColor: Color
    let mainStat: String
    let caption: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(badgeColor)
                Text(badge)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(badgeColor)
            }
            Text(mainStat)
                .font(.title3.bold().monospaced())
                .foregroundStyle(Color(.label))
            Text(caption)
                .font(.caption2)
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(badgeColor.opacity(0.3), lineWidth: 1)
        )
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
