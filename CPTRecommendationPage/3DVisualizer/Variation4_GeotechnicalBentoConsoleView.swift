//
//  Variation4_GeotechnicalBentoConsoleView.swift
//  CPTRecommendationPage
//
//  Variation 4: Geotechnical Bento Console (Modular Interactive Tiles)
//

import SwiftUI
import RealityKit

public struct Variation4_GeotechnicalBentoConsoleView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var currentBorehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D GEOTECHNICAL BENTO CONSOLE")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Modular Subsurface Analysis & Decision Engine")
                        .font(.headline.bold())
                }
                Spacer()
                Text("SchemaGAN 3D Voxel Model • High Resolution")
                    .font(.caption.monospaced())
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // Top Bento Row: 60% RealityKit 3D Viewport | 40% AI Advisor Tile
            HStack(spacing: 12) {
                // Bento Tile 1: RealityKit 3D Viewport
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("3D Subsurface Volume", systemImage: "cube.transparent")
                            .font(.caption.bold())
                        Spacer()
                        HStack(spacing: 6) {
                            Text("Cut N:")
                                .font(.caption2.bold())
                            Slider(value: $slicingState.northingSlice, in: 0...40)
                                .frame(width: 80)
                                .tint(.red)
                            Text("Cut E:")
                                .font(.caption2.bold())
                            Slider(value: $slicingState.eastingSlice, in: 0...40)
                                .frame(width: 80)
                                .tint(.cyan)
                        }
                    }
                    
                    RealityKitSoilVolumeView(
                        slicingState: $slicingState,
                        selectedBorehole: currentBorehole,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: .infinity)
                
                // Bento Tile 2: AI Advisor & Foundation Feasibility
                VStack(alignment: .leading, spacing: 10) {
                    AIAdvisorPanelView(
                        advice: SubsurfaceMockData.adviceForBorehole(currentBorehole),
                        foundationReport: SubsurfaceMockData.foundationReport,
                        hazards: SubsurfaceMockData.hazardAlerts,
                        onToggleHazardFilter: { zone in
                            slicingState.activeFilterZone = zone
                        }
                    )
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(width: 380)
            }
            .frame(height: 380)
            .padding(.horizontal, 20)
            
            // Bottom Bento Row: 3 Modular Tiles
            HStack(spacing: 12) {
                // Bento Tile 3: Module 1 (Bearing Layer Depth Map)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("1. BEARING LAYER DEPTH")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("−8m → −18m")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.orange)
                    }
                    BearingLayerDepthMapView(
                        selectedCoordinate: selectedCoordinate,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(maxWidth: .infinity)
                
                // Bento Tile 4: Module 2 (Geotechnical Hazards)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.red)
                        Text("2. RISK & HAZARD ALERTS")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Soft Clay: 4–8.5m thickness (Settlement risk)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.red)
                        Text("• Liquefaction: Loose sand in NW Quadrant")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.orange)
                        Text("• Dipping Refusal: Steep 14° Southward dip")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.blue)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(maxWidth: .infinity)
                
                // Bento Tile 5: Module 4 (Virtual Borehole Log)
                VStack(alignment: .leading, spacing: 6) {
                    Text("4. VIRTUAL BOREHOLE #VB-07")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.accentColor)
                    
                    VirtualBoreholeLogView(borehole: currentBorehole)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}
