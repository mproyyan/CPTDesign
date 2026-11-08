//
//  Variation9_DynamicIslandFloatingCapsuleView.swift
//  CPTRecommendationPage
//
//  Variation 9: Dynamic Island Floating Capsule (Focus Mode with Progressive Disclosure)
//

import SwiftUI

public struct Variation9_DynamicIslandFloatingCapsuleView: View {
    @State private var siteSnapshot = GeotechSampleData.makeSampleSite()
    @State private var selectedOverlay: MapOverlayLayer = .dqnHeatmap
    @State private var showPillarPopover = false
    @State private var confirmationToast: String?
    
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
            
            // Subtle Top Floating Layer Bar
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CPT-3D SITE CANVAS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("Sector Alpha-7")
                            .font(.headline.bold())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Spacer()
                    
                    Picker("Overlay", selection: $selectedOverlay) {
                        ForEach(MapOverlayLayer.allCases) { layer in
                            Text(layer.rawValue).tag(layer)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 360)
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
            }
            
            // Bottom-Anchored Dynamic Island Capsule
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    // Capsule Primary Row
                    HStack(alignment: .center, spacing: 14) {
                        // Point Badge
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 12, height: 12)
                            Text(siteSnapshot.reasoning.targetCPTCode)
                                .font(.title3.bold().monospaced())
                            Text("(E: 24.0, N: 16.0)")
                                .font(.caption.monospaced())
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        
                        Divider()
                            .frame(height: 24)
                        
                        // One-line synthesized XAI justification
                        VStack(alignment: .leading, spacing: 2) {
                            Text("14.2 m blindspot in northeast + suspected 4–8 m soft clay anomaly.")
                                .font(.caption.bold())
                                .foregroundStyle(Color(.label))
                            Text("Smart Exploration Stage • DQN-3D Policy")
                                .font(.caption2)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        
                        Spacer()
                        
                        // Uncertainty gain badge
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.right")
                                .foregroundStyle(Color.green)
                            Text("-28% Error")
                                .font(.caption.monospaced().bold())
                                .foregroundStyle(Color.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                        
                        // Inspect Details Info Button
                        Button {
                            showPillarPopover.toggle()
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                        }
                        .popover(isPresented: $showPillarPopover) {
                            XAIThreePillarsPopoverView(reasoning: siteSnapshot.reasoning)
                                .frame(width: 360, height: 380)
                        }
                    }
                    
                    // Action Buttons Row
                    HStack(spacing: 12) {
                        Button(role: .destructive) {
                            confirmationToast = "CPT-04 Deferred by User"
                        } label: {
                            Text("Reject Recommendation")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button {
                            confirmationToast = "CPT-04 Accepted! Job Ticket #04 Created."
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Accept Next Sounding (CPT-04)")
                            }
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                }
                .padding(16)
                .frame(maxWidth: 860)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: Color.black.opacity(0.16), radius: 20, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .overlay(
            Group {
                if let toast = confirmationToast {
                    Text(toast)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                confirmationToast = nil
                            }
                        }
                }
            }
            .padding(.bottom, 120),
            alignment: .bottom
        )
    }
}

private struct XAIThreePillarsPopoverView: View {
    let reasoning: XAIReasoning
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("XAI Reasoning Breakdown", systemImage: "sparkles")
                    .font(.headline.bold())
                Spacer()
            }
            
            Text(reasoning.formattedFullNarrative)
                .font(.caption)
                .lineSpacing(2)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 8) {
                PillarMiniRow(title: "1. Spatial Blindspot", subtitle: "14.2 m to CPT-02 • 0 density within 4m", color: .blue)
                PillarMiniRow(title: "2. Geotechnical Anomaly", subtitle: "SchemaGAN Ic Std: 0.86 • 4–8m Soft Clay", color: .purple)
                PillarMiniRow(title: "3. Efficiency & Budget", subtitle: "Push 4/12 • $1,200 / +28% model confidence", color: .emeraldGreen)
            }
            
            Spacer()
        }
        .padding(16)
    }
}

private struct PillarMiniRow: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(Color(.label))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.10, green: 0.65, blue: 0.35)
}
