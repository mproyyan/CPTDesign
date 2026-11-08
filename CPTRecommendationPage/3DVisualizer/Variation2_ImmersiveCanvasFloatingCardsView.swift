//
//  Variation2_ImmersiveCanvasFloatingCardsView.swift
//  CPTRecommendationPage
//
//  Variation 2: Immersive Canvas with Floating HUD Glass (Spatial-First Field Mode)
//

import SwiftUI
import RealityKit

public struct Variation2_ImmersiveCanvasFloatingCardsView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var currentBorehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual
    @State private var isDrawerExpanded: Bool = false
    @State private var isScenarioB: Bool = true
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fullscreen RealityKit Soil Volume
            RealityKitSoilVolumeView(
                slicingState: $slicingState,
                selectedBorehole: currentBorehole,
                onSelectCoordinate: { x, y in
                    selectedCoordinate = (x, y)
                    withAnimation(.spring()) {
                        isDrawerExpanded = true
                    }
                }
            )
            .ignoresSafeArea()
            
            // Top Floating HUD Elements
            VStack {
                HStack(alignment: .top, spacing: 14) {
                    // Floating Mini Bearing Layer Depth Map
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("BEARING STRATUM DIP")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("−8 to −18 m")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.orange)
                        }
                        BearingLayerDepthMapView(
                            selectedCoordinate: selectedCoordinate,
                            onSelectCoordinate: { x, y in
                                selectedCoordinate = (x, y)
                                isDrawerExpanded = true
                            }
                        )
                        .frame(width: 180, height: 110)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(radius: 8)
                    
                    Spacer()
                    
                    // Floating Hazard Indicators
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.red)
                            Text("HAZARD RADAR")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                        }
                        
                        Text("Soft Clay Lens: 4–8.5m")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.red)
                        Text("Liquefaction: NW Sector")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.orange)
                        
                        Toggle("Confidence Fog", isOn: $slicingState.showConfidenceFogOverlay)
                            .font(.system(size: 10, weight: .bold))
                            .toggleStyle(.button)
                            .tint(.green)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(radius: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Bottom Floating Drawer (Virtual Borehole & AI Advisor)
                VStack(spacing: 8) {
                    // Drawer Drag Handle & Pill
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isDrawerExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Capsule().fill(Color(.separator)).frame(width: 36, height: 4)
                            Text(isDrawerExpanded ? "Hide Subsurface Dossier" : "Expand Virtual Borehole #VB-07 & AI Advisor")
                                .font(.caption.bold())
                                .foregroundStyle(Color(.label))
                            Image(systemName: isDrawerExpanded ? "chevron.down" : "chevron.up")
                                .font(.caption.bold())
                        }
                        .padding(.vertical, 6)
                    }
                    
                    if isDrawerExpanded {
                        HStack(spacing: 14) {
                            VirtualBoreholeLogView(borehole: currentBorehole)
                                .frame(width: 380, height: 260)
                            
                            AIAdvisorPanelView(
                                advice: SubsurfaceMockData.adviceForBorehole(currentBorehole),
                                foundationReport: SubsurfaceMockData.foundationReport,
                                hazards: SubsurfaceMockData.hazardAlerts
                            )
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 6)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
    }
}
