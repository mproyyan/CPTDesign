//
//  Variation10_CircularPolarSiteOrbitView.swift
//  CPTRecommendationPage
//
//  Variation 10: Circular Polar Site Orbit & Strike/Dip Console
//

import SwiftUI
import RealityKit

public struct Variation10_CircularPolarSiteOrbitView: View {
    @State private var slicingState = SlicingFilterState()
    @State private var selectedCoordinate: (Double, Double) = (24.5, 16.0)
    @State private var azimuthAngle: Double = 135.0 // Degrees (Dip azimuth)
    @State private var dipAngle: Double = 14.0 // Degrees
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CPT-3D POLAR AZIMUTH & DIP CONSOLE")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Structural Stratigraphy & Azimuth Slicing")
                        .font(.headline.bold())
                }
                Spacer()
                HStack(spacing: 8) {
                    Text("Strike: 045° (NE-SW)")
                        .font(.caption.monospaced().bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    Text("Dip: 14° towards 180° (South)")
                        .font(.caption.monospaced().bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(Color.orange)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            HStack(spacing: 14) {
                // MARK: - Left Rail: Bearing Map with Strike/Dip Vector & Hazard Radar
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. BEARING STRATUM & DIP VECTOR")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    ZStack(alignment: .center) {
                        BearingLayerDepthMapView(
                            selectedCoordinate: selectedCoordinate,
                            onSelectCoordinate: { x, y in
                                selectedCoordinate = (x, y)
                            }
                        )
                        
                        // Compass Needle Overlay
                        Image(systemName: "arrow.down")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(Color.white.opacity(0.85))
                            .shadow(color: .black, radius: 4)
                    }
                    .frame(height: 180)
                    
                    Text("2. GEOTECHNICAL HAZARD ALERTS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.red)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Soft Clay: 4.0–8.5 m lens")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.red)
                        Text("• Liquefiable sand: NW quadrant")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.orange)
                        Text("• Dipping Bedrock: 14° Southward")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.blue)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                }
                .frame(width: 260)
                
                Divider()
                
                // MARK: - Center: Circular Polar RealityKit 3D Portal
                VStack(spacing: 8) {
                    HStack {
                        Text("CIRCULAR POLAR SUBSURFACE PORTAL")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(.secondaryLabel))
                        Spacer()
                        Text("Azimuth Slicer: \(Int(azimuthAngle))°")
                            .font(.caption2.monospaced().bold())
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    ZStack {
                        RealityKitSoilVolumeView(
                            slicingState: $slicingState,
                            selectedBorehole: SubsurfaceMockData.sampleBoreholeVirtual,
                            onSelectCoordinate: { x, y in
                                selectedCoordinate = (x, y)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    // Azimuth Rotating Dial Slider
                    HStack(spacing: 12) {
                        Text("Azimuth Dial (0°–360°):")
                            .font(.caption2.bold())
                        Slider(value: $azimuthAngle, in: 0...360)
                            .tint(.accentColor)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // MARK: - Right Rail: Virtual Borehole & Structural Foundation Advisor
                VStack(spacing: 10) {
                    VirtualBoreholeLogView(borehole: SubsurfaceMockData.sampleBoreholeVirtual)
                        .frame(height: 200)
                    
                    AIAdvisorPanelView(
                        advice: SubsurfaceMockData.adviceForBorehole(SubsurfaceMockData.sampleBoreholeVirtual),
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
