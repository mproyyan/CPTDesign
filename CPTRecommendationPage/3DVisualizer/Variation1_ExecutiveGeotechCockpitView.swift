//
//  Variation1_ExecutiveGeotechCockpitView.swift
//  CPTRecommendationPage
//
//  Variation 1: The Executive Geotech Cockpit (3-Column Mission Control)
//

import SwiftUI
import RealityKit

public struct Variation1_ExecutiveGeotechCockpitView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var currentBorehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual
    @State private var isScenarioB: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D EXECUTIVE COCKPIT")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Subsurface Geotechnical Synthesis & Foundation Advisor")
                        .font(.headline.bold())
                }
                Spacer()
                
                // Scenario Toggle (Scenario A: Site-Wide vs Scenario B: Virtual Borehole)
                Picker("Advisor Scenario", selection: $isScenarioB) {
                    Text("Scenario A: Site Summary").tag(false)
                    Text("Scenario B: Virtual Borehole").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 380)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // 3-Column Cockpit
            HStack(spacing: 14) {
                // MARK: - Left 25%: Module 1 (Bearing Map) & Module 5 (Foundation)
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. BEARING LAYER DEPTH MAP")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    BearingLayerDepthMapView(
                        selectedCoordinate: selectedCoordinate,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                            isScenarioB = true
                        }
                    )
                    .frame(height: 220)
                    
                    Text("5. FOUNDATION FEASIBILITY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    // Foundation Feasibility Card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Shallow Footing:")
                                .font(.caption)
                            Spacer()
                            Text("NOT FEASIBLE")
                                .font(.caption.bold())
                                .foregroundStyle(Color.red)
                        }
                        HStack {
                            Text("Deep Piles:")
                                .font(.caption)
                            Spacer()
                            Text("10.5–18.0 m")
                                .font(.caption.bold().monospaced())
                                .foregroundStyle(Color.orange)
                        }
                        HStack {
                            Text("Cut / Fill:")
                                .font(.caption)
                            Spacer()
                            Text("Net +730 m³ Fill")
                                .font(.caption.monospaced())
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                }
                .frame(width: 280)
                
                Divider()
                
                // MARK: - Center 45%: RealityKit 3D Subsurface Viewport
                VStack(spacing: 10) {
                    // Slicing Sliders Deck
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Text("Northing Cut:")
                                .font(.system(size: 10, weight: .bold))
                            Slider(value: $slicingState.northingSlice, in: 0...40)
                                .tint(.red)
                        }
                        HStack(spacing: 6) {
                            Text("Easting Cut:")
                                .font(.system(size: 10, weight: .bold))
                            Slider(value: $slicingState.eastingSlice, in: 0...40)
                                .tint(.cyan)
                        }
                        Toggle("Fog", isOn: $slicingState.showConfidenceFogOverlay)
                            .toggleStyle(.button)
                            .font(.caption.bold())
                            .tint(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // RealityKit Soil Volume
                    RealityKitSoilVolumeView(
                        slicingState: $slicingState,
                        selectedBorehole: isScenarioB ? currentBorehole : nil,
                        onSelectCoordinate: { x, y in
                            selectedCoordinate = (x, y)
                            isScenarioB = true
                        }
                    )
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right 30%: Module 4 (Virtual Log) & AI Advisor Panel
                VStack(spacing: 12) {
                    if isScenarioB {
                        VirtualBoreholeLogView(borehole: currentBorehole)
                            .frame(height: 240)
                    }
                    
                    AIAdvisorPanelView(
                        advice: isScenarioB ? SubsurfaceMockData.adviceForBorehole(currentBorehole) : SubsurfaceMockData.siteWideAdvice,
                        foundationReport: SubsurfaceMockData.foundationReport,
                        hazards: SubsurfaceMockData.hazardAlerts,
                        onToggleHazardFilter: { zone in
                            slicingState.activeFilterZone = zone
                        }
                    )
                }
                .frame(width: 360)
            }
            .padding(14)
        }
    }
}
