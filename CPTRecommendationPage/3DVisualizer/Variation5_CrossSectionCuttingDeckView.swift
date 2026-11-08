//
//  Variation5_CrossSectionCuttingDeckView.swift
//  CPTRecommendationPage
//
//  Variation 5: Cross-Sectional Cutting Deck (Vertical Geological Profile-First)
//

import SwiftUI
import RealityKit

public struct Variation5_CrossSectionCuttingDeckView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var currentBorehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D CROSS-SECTIONAL CUTTING DECK")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("3D Volume & Geological Section Profile A-A'")
                        .font(.headline.bold())
                }
                Spacer()
                HStack(spacing: 12) {
                    Text("Active Cut Plane: Northing \(String(format: "%.1f", slicingState.northingSlice)) m")
                        .font(.caption.monospaced().bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(Color.red)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // Top 48%: RealityKit 3D Slicing Viewport
            VStack(spacing: 6) {
                HStack {
                    Text("REALITYKIT 3D VOLUME WITH CUTTING PLANE A-A'")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Slide Cut A-A':")
                            .font(.caption2.bold())
                        Slider(value: $slicingState.northingSlice, in: 0...40)
                            .frame(width: 140)
                            .tint(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                
                RealityKitSoilVolumeView(
                    slicingState: $slicingState,
                    selectedBorehole: currentBorehole,
                    onSelectCoordinate: { x, y in
                        selectedCoordinate = (x, y)
                    }
                )
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: .infinity)
            
            Divider()
                .padding(.vertical, 4)
            
            // Bottom 52%: 2D Cross-Sectional Profile & Virtual Borehole / AI Advisor
            HStack(spacing: 14) {
                // Left 55%: 2D Profile Slice Canvas
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("CROSS-SECTION A-A' STRATIGRAPHY (0–20m DEPTH)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("Easting (0 to 40 m)")
                            .font(.caption2.monospaced())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    // Cross-Section Graphical Block
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            // Layer Stack representation along profile
                            VStack(spacing: 2) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobertsonSBTZone.cleanSandToSiltySand.color)
                                    .frame(height: geo.size.height * 0.12)
                                    .overlay(Text("Clean Sand (0–2.2m)").font(.system(size: 8, weight: .bold)), alignment: .leading)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobertsonSBTZone.clayeySiltToSiltySand.color)
                                    .frame(height: geo.size.height * 0.10)
                                    .overlay(Text("Silty Sand (2.2–4.0m)").font(.system(size: 8, weight: .bold)), alignment: .leading)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobertsonSBTZone.clay.color)
                                    .frame(height: geo.size.height * 0.25)
                                    .overlay(
                                        HStack {
                                            Text("⚠ SOFT CLAY LENS (4.0–8.5m) - CRITICAL HAZARD")
                                                .font(.system(size: 9, weight: .heavy))
                                                .foregroundStyle(.white)
                                                .padding(4)
                                                .background(Color.red)
                                                .clipShape(Capsule())
                                            Spacer()
                                        }
                                        .padding(.leading, 6)
                                    )
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobertsonSBTZone.siltyClayToClay.color)
                                    .frame(height: geo.size.height * 0.30)
                                    .overlay(Text("Silty Clay (8.5–16.2m)").font(.system(size: 8, weight: .bold)), alignment: .leading)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobertsonSBTZone.gravellySandToDenseSand.color)
                                    .frame(height: geo.size.height * 0.20)
                                    .overlay(Text("Dense Gravelly Sand Bearing Stratum (16.2–20m)").font(.system(size: 8, weight: .bold)), alignment: .leading)
                            }
                            
                            // Virtual Borehole Penetration Needle
                            let needleX = CGFloat(selectedCoordinate.0 / 40.0) * geo.size.width
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 2)
                                .position(x: needleX, y: geo.size.height / 2)
                                .overlay(
                                    Text("VB #VB-07")
                                        .font(.system(size: 8, weight: .black))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.red)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                        .position(x: needleX, y: 12)
                                )
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity)
                
                // Right 45%: Virtual Borehole & AI Advisor
                VStack(spacing: 8) {
                    VirtualBoreholeLogView(borehole: currentBorehole)
                        .frame(height: 140)
                    
                    AIAdvisorPanelView(
                        advice: SubsurfaceMockData.adviceForBorehole(currentBorehole),
                        foundationReport: SubsurfaceMockData.foundationReport,
                        hazards: SubsurfaceMockData.hazardAlerts
                    )
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(width: 380)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .frame(height: 290)
        }
    }
}
