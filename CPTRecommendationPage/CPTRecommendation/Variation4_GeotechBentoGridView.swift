//
//  Variation4_GeotechBentoGridView.swift
//  CPTRecommendationPage
//
//  Variation 4: Geotech Bento Grid (Modular Information Tiles)
//

import SwiftUI

public struct Variation4_GeotechBentoGridView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var bannerNotification: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 14) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D GEOTECHNICAL BENTO")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Sequential CPT Optimization Dashboard")
                        .font(.title3.bold())
                }
                Spacer()
                HStack(spacing: 8) {
                    Label(siteSnapshot.reasoning.policyUsed.title, systemImage: "cpu")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(Color.green)
                        .clipShape(Capsule())
                    
                    Text("Grid: 40 × 40 m")
                        .font(.caption.monospaced())
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Top Bento Row: 60% Map Canvas | 40% Hero Recommendation Tile
            HStack(spacing: 14) {
                // Bento Tile 1: Interactive Map
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Site Grid & Model Heatmap", systemImage: "map")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Picker("Overlay", selection: $selectedOverlay) {
                            ForEach(MapOverlayLayer.allCases) { layer in
                                Text(layer.rawValue).tag(layer)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 320)
                    }
                    
                    CPTSiteMapCanvas(
                        completedPoints: siteSnapshot.completedPoints,
                        recommendedPoint: siteSnapshot.recommendedPoint,
                        candidatePoints: siteSnapshot.candidatePoints,
                        activeOverlay: selectedOverlay
                    )
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: .infinity)
                
                // Bento Tile 2: Hero Recommendation & XAI Narrative
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("OPTIMAL NEXT DRILL", systemImage: "sparkles")
                            .font(.caption.bold())
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text("DQN Q: \(String(format: "%.3f", siteSnapshot.reasoning.qScore))")
                            .font(.caption.monospaced().bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(siteSnapshot.reasoning.targetCPTCode)
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(Color(.label))
                        Text("(E: \(String(format: "%.1f", siteSnapshot.reasoning.easting)) m, N: \(String(format: "%.1f", siteSnapshot.reasoning.northing)) m)")
                            .font(.subheadline.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    // Uncertainty Reduction Pill
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .foregroundStyle(Color.green)
                        Text("Projected Uncertainty Reduction: -\(Int(siteSnapshot.reasoning.projectedImpactPercent))%")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.green)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Narrative Text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("XAI REASONING SUMMARY")
                            .font(.caption2.bold())
                            .foregroundStyle(Color(.secondaryLabel))
                        Text(siteSnapshot.reasoning.formattedFullNarrative)
                            .font(.subheadline)
                            .lineSpacing(3)
                            .foregroundStyle(Color(.label))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(width: 440)
            }
            .frame(height: 380)
            .padding(.horizontal, 20)
            
            // Bottom Bento Row: 3 Modular Pillar & Action Tiles
            HStack(spacing: 14) {
                // Tile 3: Spatial Blindspot
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.triangle.swap")
                            .foregroundStyle(Color.blue)
                        Text("Spatial Blindspot")
                            .font(.subheadline.bold())
                        Spacer()
                        Text("\(String(format: "%.1f", siteSnapshot.reasoning.nearestCPTDistance)) m")
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(Color.blue)
                    }
                    Text("Nearest CPT: \(siteSnapshot.reasoning.nearestCPTCode). Zero observed data in 4 m radius.")
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Sector: \(siteSnapshot.reasoning.spatialSector)")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.blue)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Tile 4: Stratigraphic Complexity
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "layers.fill")
                            .foregroundStyle(Color.purple)
                        Text("Geological Complexity")
                            .font(.subheadline.bold())
                        Spacer()
                        Text("Ic Std: \(String(format: "%.2f", siteSnapshot.reasoning.reconstructedIcStdZ))")
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(Color.purple)
                    }
                    Text(siteSnapshot.reasoning.suspectedFeature)
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Depth: 4.0 m – 8.0 m unconfirmed")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.purple)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Tile 5: Budget & Rapid Decision Actions
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PROGRESS & BUDGET")
                                .font(.caption2.bold())
                                .foregroundStyle(Color(.secondaryLabel))
                            Text("CPT \(siteSnapshot.reasoning.currentCPTNumber) of \(siteSnapshot.reasoning.totalBudgetCPTs) • $\(Int(siteSnapshot.reasoning.costThisPushUSD))/push")
                                .font(.caption.bold())
                        }
                        Spacer()
                        Text("$\(Int(siteSnapshot.reasoning.remainingBudgetUSD)) rem.")
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(Color.emeraldGreen)
                    }
                    
                    HStack(spacing: 10) {
                        Button(role: .destructive) {
                            bannerNotification = "Rejected CPT-04. Recalculating next point..."
                        } label: {
                            Text("Reject")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button {
                            bannerNotification = "CPT-04 Confirmed! Work order created."
                        } label: {
                            Text("Accept Push")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .overlay(
            Group {
                if let notification = bannerNotification {
                    Text(notification)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                bannerNotification = nil
                            }
                        }
                }
            }
            .padding(.bottom, 24),
            alignment: .bottom
        )
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
