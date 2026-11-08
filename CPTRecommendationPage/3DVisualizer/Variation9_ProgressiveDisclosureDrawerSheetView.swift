//
//  Variation9_ProgressiveDisclosureDrawerSheetView.swift
//  CPTRecommendationPage
//
//  Variation 9: Progressive Disclosure Minimalist Canvas (Executive Focus Mode)
//

import SwiftUI
import RealityKit

public struct Variation9_ProgressiveDisclosureDrawerSheetView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var showFullDossierSheet: Bool = false
    @State private var activeFilterMode: Int = 0 // 0: All, 1: Bearing Stratum, 2: Hazards, 3: Fog
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fullscreen RealityKit Canvas
            RealityKitSoilVolumeView(
                slicingState: $slicingState,
                selectedBorehole: SubsurfaceMockData.sampleBoreholeVirtual,
                onSelectCoordinate: { x, y in
                    selectedCoordinate = (x, y)
                    showFullDossierSheet = true
                }
            )
            .ignoresSafeArea()
            
            // Top Floating Dynamic Island Mode Pill
            VStack {
                HStack(spacing: 12) {
                    Label("CPT-3D Subsurface Model", systemImage: "cube.fill")
                        .font(.system(size: 11, weight: .bold))
                    
                    Divider().frame(height: 18)
                    
                    Picker("Display Mode", selection: $activeFilterMode) {
                        Text("Stratigraphy").tag(0)
                        Text("Bearing Contours").tag(1)
                        Text("Hazard Radar").tag(2)
                        Text("Confidence Fog").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 420)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
                .padding(.top, 16)
                
                Spacer()
                
                // Bottom Interactive Focus Capsule
                VStack(spacing: 8) {
                    HStack(spacing: 14) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.yellow)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Deep Foundation Recommended: Driven Piles 10.5–18.0 m")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color(.label))
                            Text("Dipping bearing stratum (−8m North → −18m South) • Soft clay lens 4–8.5m")
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        
                        Spacer()
                        
                        Button {
                            showFullDossierSheet.toggle()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Inspect Full Dossier")
                                Image(systemName: "chevron.up.circle.fill")
                            }
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: 820)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color.black.opacity(0.15), radius: 14, x: 0, y: 6)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showFullDossierSheet) {
            // Full Engineering Dossier Presentation Sheet
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("Subsurface Investigation Engineering Dossier")
                            .font(.title3.bold())
                        Spacer()
                        Button("Done") { showFullDossierSheet = false }
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("1. BEARING LAYER DEPTH MAP")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                            BearingLayerDepthMapView(selectedCoordinate: selectedCoordinate)
                                .frame(height: 220)
                            
                            VirtualBoreholeLogView(borehole: SubsurfaceMockData.sampleBoreholeVirtual)
                        }
                        .frame(maxWidth: .infinity)
                        
                        AIAdvisorPanelView(
                            advice: SubsurfaceMockData.adviceForBorehole(SubsurfaceMockData.sampleBoreholeVirtual),
                            foundationReport: SubsurfaceMockData.foundationReport,
                            hazards: SubsurfaceMockData.hazardAlerts
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
            }
        }
    }
}
