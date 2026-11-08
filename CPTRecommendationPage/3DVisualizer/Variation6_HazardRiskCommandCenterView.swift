//
//  Variation6_HazardRiskCommandCenterView.swift
//  CPTRecommendationPage
//
//  Variation 6: Hazard & Risk Command Center (Safety & Liquefaction Isolation)
//

import SwiftUI
import RealityKit

public struct Variation6_HazardRiskCommandCenterView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var currentBorehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual
    @State private var selectedHazardMode: Int = 0 // 0: All, 1: Soft Clay, 2: Liquefaction, 3: Hard Layer
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Hazard Alert Ticker
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundStyle(Color.red)
                    Text("HAZARD MITIGATION CONSOLE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color.red)
                }
                
                Spacer()
                
                // 3D Iso-Surface Isolation Quick Toggles
                Picker("Iso-Surface Filter", selection: $selectedHazardMode) {
                    Text("All Strata").tag(0)
                    Text("⚠ Soft Clay Only").tag(1)
                    Text("⚡ Liquefaction Sand").tag(2)
                    Text("⚓ Bearing Layer").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(width: 480)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.08))
            
            Divider()
            
            HStack(spacing: 14) {
                // MARK: - Left Rail: Detailed Hazard Dossier & Module 1 Bearing Map
                VStack(alignment: .leading, spacing: 10) {
                    Text("ACTIVE GEOTECHNICAL RISKS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.red)
                    
                    ForEach(SubsurfaceMockData.hazardAlerts) { hazard in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Image(systemName: hazard.severity.iconName)
                                    .foregroundStyle(hazard.severity.color)
                                Text(hazard.title)
                                    .font(.system(size: 10, weight: .bold))
                            }
                            Text(hazard.depthSpan)
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundStyle(hazard.severity.color)
                            Text(hazard.engineeringImpact)
                                .font(.system(size: 9))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Text("BEARING STRATUM CONTOUR")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    BearingLayerDepthMapView(
                        selectedCoordinate: selectedCoordinate,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                    .frame(height: 140)
                    
                    Spacer()
                }
                .frame(width: 270)
                
                Divider()
                
                // MARK: - Center: RealityKit 3D Hazard Isolation Viewport
                VStack(spacing: 8) {
                    RealityKitSoilVolumeView(
                        slicingState: $slicingState,
                        selectedBorehole: currentBorehole,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                        }
                    )
                    
                    HStack(spacing: 12) {
                        Text("Slice Northing:")
                            .font(.caption2.bold())
                        Slider(value: $slicingState.northingSlice, in: 0...40)
                            .tint(.red)
                        Toggle("Confidence Fog", isOn: $slicingState.showConfidenceFogOverlay)
                            .font(.caption2.bold())
                            .toggleStyle(.button)
                            .tint(.green)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right Rail: Foundation Feasibility & AI Sign-off
                VStack(spacing: 10) {
                    VirtualBoreholeLogView(borehole: currentBorehole)
                        .frame(height: 220)
                    
                    AIAdvisorPanelView(
                        advice: SubsurfaceMockData.adviceForBorehole(currentBorehole),
                        foundationReport: SubsurfaceMockData.foundationReport,
                        hazards: SubsurfaceMockData.hazardAlerts
                    )
                }
                .frame(width: 340)
            }
            .padding(14)
        }
    }
}
