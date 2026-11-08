//
//  Variation7_BoreholeComparisonWorkbenchView.swift
//  CPTRecommendationPage
//
//  Variation 7: Comparative Borehole Workbench (Real vs AI Ground Truth Diff)
//

import SwiftUI
import RealityKit

public struct Variation7_BoreholeComparisonWorkbenchView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D GROUND TRUTH VALIDATION WORKBENCH")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Measured Real CPT vs SchemaGAN Virtual Extracted Sounding")
                        .font(.headline.bold())
                }
                Spacer()
                HStack(spacing: 8) {
                    Label("Real CPT-02", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color.green)
                    Text("vs")
                        .font(.caption)
                    Label("Virtual #VB-07 (±9.8%)", systemImage: "sparkles")
                        .font(.caption.bold())
                        .foregroundStyle(Color.purple)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            HStack(spacing: 16) {
                // MARK: - Left 48%: RealityKit 3D Volume & Bearing Depth Inset
                VStack(spacing: 10) {
                    RealityKitSoilVolumeView(
                        slicingState: $slicingState,
                        selectedBorehole: SubsurfaceMockData.sampleBoreholeVirtual,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                    
                    HStack(spacing: 12) {
                        // Mini Bearing Map
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hard Layer Contour")
                                .font(.system(size: 8, weight: .bold))
                            BearingLayerDepthMapView(selectedCoordinate: selectedCoordinate)
                                .frame(width: 140, height: 70)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Slicing Planes")
                                .font(.caption2.bold())
                            HStack {
                                Text("N:")
                                Slider(value: $slicingState.northingSlice, in: 0...40).tint(.red)
                            }
                            HStack {
                                Text("E:")
                                Slider(value: $slicingState.eastingSlice, in: 0...40).tint(.cyan)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right 52%: Side-by-Side Dual Borehole Comparator
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        // Real CPT Column
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MEASURED GROUND TRUTH")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.green)
                            VirtualBoreholeLogView(borehole: SubsurfaceMockData.sampleBoreholeReal)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Virtual AI Extracted Column
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SCHEMAGAN PREDICTION")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.purple)
                            VirtualBoreholeLogView(borehole: SubsurfaceMockData.sampleBoreholeVirtual)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Comparison Diff & Advisor
                    AIAdvisorPanelView(
                        advice: SubsurfaceMockData.adviceForBorehole(SubsurfaceMockData.sampleBoreholeVirtual),
                        foundationReport: SubsurfaceMockData.foundationReport,
                        hazards: SubsurfaceMockData.hazardAlerts
                    )
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .frame(width: 480)
            }
            .padding(14)
        }
    }
}
