//
//  Variation8_DecisionMatrixComparatorView.swift
//  CPTRecommendationPage
//
//  Variation 8: Decision Matrix & Counterfactual Comparator (Side-by-Side Comparison)
//

import SwiftUI

public struct Variation8_DecisionMatrixComparatorView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var chosenOption: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D COUNTERFACTUAL COMPARATOR")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("AI Recommendation vs Alternative Candidate")
                        .font(.headline.bold())
                }
                Spacer()
                HStack(spacing: 8) {
                    Label(siteSnapshot.reasoning.policyUsed.title, systemImage: "arrow.left.arrow.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Picker("Overlay", selection: $selectedOverlay) {
                        ForEach(MapOverlayLayer.allCases) { layer in
                            Text(layer.rawValue).tag(layer)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 320)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // Top Half: Map with highlighted pair
            CPTSiteMapCanvas(
                completedPoints: siteSnapshot.completedPoints,
                recommendedPoint: siteSnapshot.recommendedPoint,
                candidatePoints: siteSnapshot.candidatePoints,
                activeOverlay: selectedOverlay
            )
            .frame(height: 290)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Divider()
                .padding(.vertical, 8)
            
            // Bottom Half: Side-by-Side Comparison Cards
            HStack(spacing: 16) {
                // Left Column: AI Recommendation (CPT-04)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("AI BEST CHOICE", systemImage: "sparkles")
                            .font(.caption.bold())
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text("Rank #1 • Q: 0.914")
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(Color.orange)
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(siteSnapshot.reasoning.targetCPTCode)
                            .font(.title2.bold())
                        Text("E: 24.0 m, N: 16.0 m")
                            .font(.subheadline.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    // Evidence Metrics
                    VStack(alignment: .leading, spacing: 4) {
                        ComparisonRow(metric: "Uncertainty Error Gain", valA: "-28.0%", isWinnerA: true)
                        ComparisonRow(metric: "Blindspot Distance", valA: "14.2 m", isWinnerA: true)
                        ComparisonRow(metric: "Anomaly Resolution", valA: "High (4-8m soft clay)", isWinnerA: true)
                        ComparisonRow(metric: "Testing Cost", valA: "$1,200", isWinnerA: false)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text("Why this beats Alternative: Targets high-variance SchemaGAN layer that candidate B completely misses.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button {
                        chosenOption = "AI Recommendation (CPT-04) Approved"
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Accept AI Choice (CPT-04)")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
                .padding(14)
                .background(Color.accentColor.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                )
                
                // Right Column: Alternative Candidate (Candidate B)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("ENGINEER ALTERNATIVE", systemImage: "person.crop.circle")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.secondaryLabel))
                        Spacer()
                        Text("Rank #2 • Q: 0.785")
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("Candidate B")
                            .font(.title2.bold())
                        Text("E: 18.0 m, N: 34.0 m")
                            .font(.subheadline.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    // Evidence Metrics
                    VStack(alignment: .leading, spacing: 4) {
                        ComparisonRow(metric: "Uncertainty Error Gain", valA: "-19.5% (-8.5% lower)", isWinnerA: false)
                        ComparisonRow(metric: "Blindspot Distance", valA: "12.8 m (1.4m closer)", isWinnerA: false)
                        ComparisonRow(metric: "Anomaly Resolution", valA: "Low (Uniform strata)", isWinnerA: false)
                        ComparisonRow(metric: "Testing Cost", valA: "$1,200", isWinnerA: false)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text("Engineer Advantage: Closer to existing site access road, but leaves the northeast soft clay lens completely unverified.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button {
                        chosenOption = "Manual Override: Candidate B Selected"
                    } label: {
                        HStack {
                            Image(systemName: "hand.tap")
                            Text("Override with Candidate B")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
            .frame(maxHeight: .infinity)
        }
        .overlay(
            Group {
                if let opt = chosenOption {
                    Text(opt)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                chosenOption = nil
                            }
                        }
                }
            }
            .padding(.bottom, 24),
            alignment: .bottom
        )
    }
}

private struct ComparisonRow: View {
    let metric: String
    let valA: String
    let isWinnerA: Bool
    
    var body: some View {
        HStack {
            Text(metric)
                .font(.system(size: 10))
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            HStack(spacing: 4) {
                if isWinnerA {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.green)
                }
                Text(valA)
                    .font(.system(size: 10, weight: isWinnerA ? .bold : .regular, design: .monospaced))
                    .foregroundStyle(isWinnerA ? Color(.label) : Color(.secondaryLabel))
            }
        }
    }
}
