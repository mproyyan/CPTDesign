//
//  Variation7_AnalyticalMetricConsoleView.swift
//  CPTRecommendationPage
//
//  Variation 7: Analytical Metric Console (Data-Dense Aviation/Telemetry Style HUD)
//

import SwiftUI

public struct Variation7_AnalyticalMetricConsoleView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var selectedCandidateIndex: Int = 0
    @State private var systemStatusLog = "SchemaGAN-3D Convergence: 99.4% • Action Mask Active"
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // HUD Status Line
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("CPT-3D TELEMETRY CONSOLE")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundStyle(Color(.label))
                    Text("•")
                        .foregroundStyle(Color(.secondaryLabel))
                    Text(systemStatusLog)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                Spacer()
                Text("Policy: \(siteSnapshot.reasoning.policyUsed.rawValue) • Step 04/12")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Divider()
            
            HStack(spacing: 16) {
                // MARK: - Left 48%: Analytical Telemetry & Candidate Rankings
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        // Formula Card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DQN VALUE FUNCTION DECOMPOSITION")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color.accentColor)
                            Text("Q(s, a) = ΔH(Uncertainty) - λ · Cost(Distance, Rig)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(.label))
                            HStack {
                                Text("Score: 0.914")
                                    .font(.caption2.monospaced().bold())
                                    .foregroundStyle(Color.orange)
                                Text("=")
                                    .font(.caption2)
                                Text("Gain: +0.982")
                                    .font(.caption2.monospaced().bold())
                                    .foregroundStyle(Color.green)
                                Text("-")
                                    .font(.caption2)
                                Text("Cost: 0.068")
                                    .font(.caption2.monospaced().bold())
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        // Top Candidate Ranking Table
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CANDIDATE RANKING TABLE (TOP 3)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(.secondaryLabel))
                            
                            ForEach(Array(siteSnapshot.alternatives.enumerated()), id: \.offset) { index, cand in
                                HStack {
                                    Text("#\(cand.rank)")
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundStyle(index == 0 ? Color.accentColor : Color(.secondaryLabel))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(cand.code)
                                            .font(.system(size: 12, weight: .bold))
                                        Text("E: \(String(format: "%.1f", cand.easting)), N: \(String(format: "%.1f", cand.northing)) • \(cand.primaryPillar)")
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundStyle(Color(.secondaryLabel))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Q: \(String(format: "%.3f", cand.qScore))")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundStyle(index == 0 ? Color.orange : Color(.label))
                                        Text("+\(String(format: "%.1f", cand.uncertaintyGainPercent))% gain")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundStyle(Color.green)
                                    }
                                }
                                .padding(10)
                                .background(selectedCandidateIndex == index ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    selectedCandidateIndex = index
                                }
                            }
                        }
                        
                        // Pillar Telemetry Bars
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PILLAR TELEMETRY")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(.secondaryLabel))
                            
                            TelemetryBar(label: "Spatial Blindspot", value: 14.2, max: 20.0, unit: "m", color: .blue)
                            TelemetryBar(label: "SchemaGAN Ic Std", value: 0.86, max: 1.0, unit: "σ", color: .purple)
                            TelemetryBar(label: "Budget Consumption", value: 4.0, max: 12.0, unit: "cpts", color: .emeraldGreen)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right 52%: Precision Site Grid Map & Actions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("SPATIAL DISPERSION VIEW")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(.secondaryLabel))
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
                    
                    // XAI Explanation Card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("RATIONALE: \(siteSnapshot.reasoning.targetCPTCode)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Text("Confidence: 94.2%")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(Color.green)
                        }
                        Text(siteSnapshot.reasoning.formattedFullNarrative)
                            .font(.system(size: 11))
                            .lineSpacing(2)
                            .foregroundStyle(Color(.label))
                    }
                    .padding(10)
                    .background(Color.accentColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Actions Bar
                    HStack(spacing: 12) {
                        Button {
                            systemStatusLog = "Alternative Candidate B selected by Engineer."
                        } label: {
                            Text("Override (Pick #2)")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            systemStatusLog = "CPT-04 Order Dispatched to Field Rig via WITSML."
                        } label: {
                            Text("Accept #1 (CPT-04)")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct TelemetryBar: View {
    let label: String
    let value: Double
    let max: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
                Text("\(String(format: "%.1f", value)) \(unit)")
                    .font(.caption2.monospaced().bold())
                    .foregroundStyle(color)
            }
            ProgressView(value: value, total: max)
                .tint(color)
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
