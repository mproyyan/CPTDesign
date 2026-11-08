//
//  Variation3_SplitViewportDualProjectionView.swift
//  CPTRecommendationPage
//
//  Variation 3: Synchronized Dual-Viewport Projection (50/50 3D Volume & 2D GIS Map)
//

import SwiftUI
import RealityKit

public struct Variation3_SplitViewportDualProjectionView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var currentBorehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual
    @State private var activeMapLayer: Int = 0 // 0: Bearing Depth, 1: Uncertainty Fog, 2: Hazards
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Synchronized Twin Status Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SYNCHRONIZED GEOTECHNICAL TWIN")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    HStack(spacing: 8) {
                        Text("3D RealityKit Volume")
                            .font(.headline.bold())
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundStyle(Color.accentColor)
                        Text("2D Planar Heatmap GIS")
                            .font(.headline.bold())
                    }
                }
                Spacer()
                Text("Cursor: E: \(String(format: "%.1f", selectedCoordinate.0))m, N: \(String(format: "%.1f", selectedCoordinate.1))m")
                    .font(.caption.monospaced().bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            HStack(spacing: 16) {
                // MARK: - Left 50%: RealityKit 3D Volume
                VStack(spacing: 10) {
                    RealityKitSoilVolumeView(
                        slicingState: $slicingState,
                        selectedBorehole: currentBorehole,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                    
                    // Slicing Handles Deck
                    HStack(spacing: 12) {
                        Text("Cut N:")
                            .font(.caption2.bold())
                        Slider(value: $slicingState.northingSlice, in: 0...40)
                            .tint(.red)
                        Text("Cut E:")
                            .font(.caption2.bold())
                        Slider(value: $slicingState.eastingSlice, in: 0...40)
                            .tint(.cyan)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right 50%: 2D GIS Map & Docked Inspector
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("2D GIS SPATIAL PROJECTION")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Picker("Layer", selection: $activeMapLayer) {
                                Text("Hard Layer Depth").tag(0)
                                Text("Uncertainty Fog").tag(1)
                                Text("Hazards").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 260)
                        }
                        
                        BearingLayerDepthMapView(
                            selectedCoordinate: selectedCoordinate,
                            onSelectCoordinate: { x, y in
                                selectedCoordinate = (x, y)
                            }
                        )
                        .frame(height: 200)
                        
                        // Virtual Borehole Log
                        VirtualBoreholeLogView(borehole: currentBorehole)
                        
                        // AI Advisor & Foundation Feasibility
                        AIAdvisorPanelView(
                            advice: SubsurfaceMockData.adviceForBorehole(currentBorehole),
                            foundationReport: SubsurfaceMockData.foundationReport,
                            hazards: SubsurfaceMockData.hazardAlerts
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(14)
        }
    }
}
