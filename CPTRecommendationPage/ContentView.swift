//
//  ContentView.swift
//  CPTRecommendationPage
//
//  Master Single-Page Showcase Selector for CPT-3D:
//  - Suite A: Sequential CPT Optimization Page (10 Variations)
//  - Suite B: Subsurface Result & Analysis 3D Page (10 RealityKit Variations)
//

import SwiftUI
import RealityKit

public enum AppScreenSuite: String, CaseIterable, Identifiable {
    case recommendation = "Sequential CPT Recommendation"
    case resultAnalysis3D = "Result & Analysis 3D (RealityKit)"
    
    public var id: String { rawValue }
}

public enum Result3DVariationOption: String, CaseIterable, Identifiable {
    case v1 = "1. Cockpit"
    case v2 = "2. Floating HUD"
    case v3 = "3. Dual-Twin"
    case v4 = "4. Bento"
    case v5 = "5. Section Deck"
    case v6 = "6. Hazard Command"
    case v7 = "7. Borehole Diff"
    case v8 = "8. Telemetry HUD"
    case v9 = "9. Minimal Focus"
    case v10 = "10. Polar Slicer"
    
    public var id: String { rawValue }
}

public enum DesignVariationOption: String, CaseIterable, Identifiable {
    case v1 = "1. Split HUD"
    case v2 = "2. Floating Inspector"
    case v3 = "3. Triptych Matrix"
    case v4 = "4. Geotech Bento"
    case v5 = "5. Field-Ops Drawer"
    case v6 = "6. Cross-Section"
    case v7 = "7. Analytical HUD"
    case v8 = "8. Comparator"
    case v9 = "9. Minimal Capsule"
    case v10 = "10. Radial Command"
    
    public var id: String { rawValue }
}

struct ContentView: View {
    @State private var activeSuite: AppScreenSuite = .resultAnalysis3D
    @State private var selectedRecVariation: DesignVariationOption = .v1
    @State private var selected3DVariation: Result3DVariationOption = .v1
    @State private var isDesignPickerVisible: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // In-Page Switcher for Design Review
            if isDesignPickerVisible {
                HStack(spacing: 12) {
                    Picker("Screen Suite", selection: $activeSuite) {
                        ForEach(AppScreenSuite.allCases) { suite in
                            Text(suite.rawValue).tag(suite)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 380)
                    
                    Divider().frame(height: 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            if activeSuite == .resultAnalysis3D {
                                ForEach(Result3DVariationOption.allCases) { option in
                                    Button {
                                        selected3DVariation = option
                                    } label: {
                                        Text(option.rawValue)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(selected3DVariation == option ? Color.accentColor : Color(.secondarySystemBackground))
                                            .foregroundStyle(selected3DVariation == option ? Color.white : Color(.label))
                                            .clipShape(Capsule())
                                    }
                                }
                            } else {
                                ForEach(DesignVariationOption.allCases) { option in
                                    Button {
                                        selectedRecVariation = option
                                    } label: {
                                        Text(option.rawValue)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(selectedRecVariation == option ? Color.accentColor : Color(.secondarySystemBackground))
                                            .foregroundStyle(selectedRecVariation == option ? Color.white : Color(.label))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button {
                        withAnimation {
                            isDesignPickerVisible = false
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemBackground))
                
                Divider()
            }
            
            // Render Active Suite
            Group {
                if activeSuite == .resultAnalysis3D {
                    switch selected3DVariation {
                    case .v1: Variation1_ExecutiveGeotechCockpitView()
                    case .v2: Variation2_ImmersiveCanvasFloatingCardsView()
                    case .v3: Variation3_SplitViewportDualProjectionView()
                    case .v4: Variation4_GeotechnicalBentoConsoleView()
                    case .v5: Variation5_CrossSectionCuttingDeckView()
                    case .v6: Variation6_HazardRiskCommandCenterView()
                    case .v7: Variation7_BoreholeComparisonWorkbenchView()
                    case .v8: Variation8_AnalyticalParametricHUDView()
                    case .v9: Variation9_ProgressiveDisclosureDrawerSheetView()
                    case .v10: Variation10_CircularPolarSiteOrbitView()
                    }
                } else {
                    switch selectedRecVariation {
                    case .v1: Variation1_SplitHUDDashboardView()
                    case .v2: Variation2_CanvasCentricFloatingInspectorView()
                    case .v3: Variation3_TriptychPillarView()
                    case .v4: Variation4_GeotechBentoGridView()
                    case .v5: Variation5_BottomDrawerFieldOpsView()
                    case .v6: Variation6_CrossSectionSoilStratigraphyView()
                    case .v7: Variation7_AnalyticalMetricConsoleView()
                    case .v8: Variation8_DecisionMatrixComparatorView()
                    case .v9: Variation9_DynamicIslandFloatingCapsuleView()
                    case .v10: Variation10_RadialSiteCommandWheelView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Group {
                    if !isDesignPickerVisible {
                        Button {
                            withAnimation {
                                isDesignPickerVisible = true
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.caption.bold())
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(12)
                    }
                },
                alignment: .topTrailing
            )
        }
    }
}

#Preview {
    ContentView()
}
