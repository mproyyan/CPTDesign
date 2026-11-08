//
//  Subsurface3DModels.swift
//  CPTRecommendationPage
//
//  Shared Geotechnical Domain Models, Risk Rules & Synthetic Data
//  for SchemaGAN-3D Subsurface Result & Analysis Page
//

import SwiftUI
import RealityKit

// MARK: - Robertson SBT Zone (1990/2016)
public enum RobertsonSBTZone: Int, CaseIterable, Identifiable {
    case sensitiveFineGrained = 1
    case organicPeat = 2
    case clay = 3
    case siltyClayToClay = 4
    case clayeySiltToSiltySand = 5
    case cleanSandToSiltySand = 6
    case gravellySandToDenseSand = 7
    case veryStiffSandToClayeySand = 8
    case veryStiffFineGrained = 9
    
    public var id: Int { rawValue }
    
    public var name: String {
        switch self {
        case .sensitiveFineGrained: return "Sensitive Fine Grained"
        case .organicPeat: return "Organic Soil / Peat"
        case .clay: return "Clay (Low to High Plasticity)"
        case .siltyClayToClay: return "Silty Clay to Clay"
        case .clayeySiltToSiltySand: return "Clayey Silt to Silty Sand"
        case .cleanSandToSiltySand: return "Clean Sand to Silty Sand"
        case .gravellySandToDenseSand: return "Gravelly Sand to Sand"
        case .veryStiffSandToClayeySand: return "Very Stiff Sand / Weak Sandstone"
        case .veryStiffFineGrained: return "Very Stiff Fine Grained"
        }
    }
    
    public var shortLabel: String {
        switch self {
        case .sensitiveFineGrained: return "Sens. Clay"
        case .organicPeat: return "Peat / Organics"
        case .clay: return "Clay"
        case .siltyClayToClay: return "Silty Clay"
        case .clayeySiltToSiltySand: return "Clayey Silt"
        case .cleanSandToSiltySand: return "Clean Sand"
        case .gravellySandToDenseSand: return "Dense Sand/Gravel"
        case .veryStiffSandToClayeySand: return "Stiff Sand"
        case .veryStiffFineGrained: return "Stiff Clay"
        }
    }
    
    public var icRangeString: String {
        switch self {
        case .sensitiveFineGrained, .organicPeat: return "Ic > 3.60"
        case .clay: return "2.95 < Ic ≤ 3.60"
        case .siltyClayToClay: return "2.60 < Ic ≤ 2.95"
        case .clayeySiltToSiltySand: return "2.05 < Ic ≤ 2.60"
        case .cleanSandToSiltySand: return "1.31 ≤ Ic ≤ 2.05"
        case .gravellySandToDenseSand: return "Ic < 1.31"
        case .veryStiffSandToClayeySand: return "Overconsolidated"
        case .veryStiffFineGrained: return "Very Stiff"
        }
    }
    
    public var color: Color {
        switch self {
        case .sensitiveFineGrained: return Color(red: 0.35, green: 0.22, blue: 0.18)
        case .organicPeat: return Color(red: 0.25, green: 0.18, blue: 0.12)
        case .clay: return Color(red: 0.28, green: 0.48, blue: 0.68)
        case .siltyClayToClay: return Color(red: 0.40, green: 0.62, blue: 0.62)
        case .clayeySiltToSiltySand: return Color(red: 0.72, green: 0.68, blue: 0.48)
        case .cleanSandToSiltySand: return Color(red: 0.88, green: 0.78, blue: 0.42)
        case .gravellySandToDenseSand: return Color(red: 0.96, green: 0.84, blue: 0.32)
        case .veryStiffSandToClayeySand: return Color(red: 0.62, green: 0.52, blue: 0.42)
        case .veryStiffFineGrained: return Color(red: 0.48, green: 0.40, blue: 0.40)
        }
    }
    
    public var uiColor: UIColor {
        UIColor(color)
    }
    
    public var isProblematicHazard: Bool {
        self == .sensitiveFineGrained || self == .organicPeat || self == .clay
    }
    
    public var isLiquefiableCandidate: Bool {
        self == .cleanSandToSiltySand || self == .clayeySiltToSiltySand
    }
}

// MARK: - Vertical Stratigraphy Interval for Borehole Log
public struct SoilInterval: Identifiable, Hashable {
    public let id = UUID()
    public let depthTop: Double     // meters below ground surface
    public let depthBottom: Double  // meters
    public let zone: RobertsonSBTZone
    public let icValue: Double
    public let estimatedQcMPa: Double // MPa
    public let fsKPa: Double          // kPa
    public let isHazard: Bool
    
    public var thickness: Double { depthBottom - depthTop }
}

// MARK: - Virtual Borehole Query & State
public enum BoreholeDataSource: String {
    case measuredReal = "Measured Real CPT (Field Ground Truth)"
    case virtualPrediction = "Virtual Extracted CPT (SchemaGAN 3D Prediction)"
}

public struct VirtualBoreholeRecord: Identifiable {
    public let id = UUID()
    public let coordinateCode: String
    public let easting: Double   // meters (0–40m)
    public let northing: Double  // meters (0–40m)
    public let surfaceElevation: Double // m MSL
    public let totalDepth: Double       // m (e.g. 20m)
    public let dataSource: BoreholeDataSource
    public let marginOfErrorPercent: Double? // nil if real, e.g. ±12.4%
    public let nearestRealCPTName: String?
    public let distanceToRealCPT: Double?   // meters
    public let bearingLayerDepth: Double    // meters
    public let intervals: [SoilInterval]
}

// MARK: - Geotechnical Hazard Alert Model
public enum HazardSeverity: String {
    case critical = "CRITICAL"
    case moderate = "MODERATE"
    case low = "INFORMATIONAL"
    
    public var color: Color {
        switch self {
        case .critical: return .red
        case .moderate: return .orange
        case .low: return .blue
        }
    }
    
    public var iconName: String {
        switch self {
        case .critical: return "exclamationmark.octagon.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .low: return "info.circle.fill"
        }
    }
}

public struct GeotechnicalHazardAlert: Identifiable {
    public let id = UUID()
    public let title: String
    public let sector: String
    public let depthSpan: String
    public let description: String
    public let engineeringImpact: String
    public let severity: HazardSeverity
    public let affectedZone: RobertsonSBTZone
}

// MARK: - Foundation Feasibility Model
public struct FoundationFeasibilityReport {
    public let shallowFoundationFeasible: Bool
    public let shallowReason: String
    public let recommendedDeepFoundation: String
    public let estimatedPileLengthMin: Double // m
    public let estimatedPileLengthMax: Double // m
    public let cutAndFillSurfaceM: Double     // formation level vs natural surface
    public let cutVolumeM3: Double
    public let fillVolumeM3: Double
    public let settlementRiskRating: String   // Low, Moderate, Severe
}

// MARK: - AI Subsurface Advisor Scenario Data
public enum AdvisorScenario {
    case siteWideSummary
    case virtualBoreholeQuery(VirtualBoreholeRecord)
}

public struct AIAdvisorAdvice {
    public let scenarioTitle: String
    public let keyFinding: String
    public let geologicalInterpretation: String
    public let foundationRecommendation: String
    public let confidenceRating: String
    public let actionableNextStep: String
}

// MARK: - 3D Volume Slicing & Filter State
public struct SlicingFilterState {
    public var northingSlice: Double = 40.0   // 0 to 40 meters
    public var eastingSlice: Double = 40.0    // 0 to 40 meters
    public var depthSlice: Double = 20.0      // 0 to 20 meters
    public var showHardLayerIsoSurface: Bool = false
    public var highlightSoftClayHazard: Bool = false
    public var highlightLiquefactionZone: Bool = false
    public var showConfidenceFogOverlay: Bool = true
    public var activeFilterZone: RobertsonSBTZone? = nil
}

// MARK: - Mock Geotechnical Dataset Provider
public enum SubsurfaceMockData {
    public static let sampleBoreholeReal = VirtualBoreholeRecord(
        coordinateCode: "CPT-02 (Observed)",
        easting: 10.0,
        northing: 22.0,
        surfaceElevation: 12.4,
        totalDepth: 20.0,
        dataSource: .measuredReal,
        marginOfErrorPercent: nil,
        nearestRealCPTName: nil,
        distanceToRealCPT: 0.0,
        bearingLayerDepth: 14.5,
        intervals: [
            SoilInterval(depthTop: 0.0, depthBottom: 2.2, zone: .cleanSandToSiltySand, icValue: 1.85, estimatedQcMPa: 11.2, fsKPa: 45, isHazard: false),
            SoilInterval(depthTop: 2.2, depthBottom: 4.0, zone: .clayeySiltToSiltySand, icValue: 2.30, estimatedQcMPa: 6.5, fsKPa: 52, isHazard: false),
            SoilInterval(depthTop: 4.0, depthBottom: 7.8, zone: .clay, icValue: 3.15, estimatedQcMPa: 1.3, fsKPa: 22, isHazard: true),
            SoilInterval(depthTop: 7.8, depthBottom: 14.5, zone: .siltyClayToClay, icValue: 2.70, estimatedQcMPa: 4.8, fsKPa: 80, isHazard: false),
            SoilInterval(depthTop: 14.5, depthBottom: 20.0, zone: .gravellySandToDenseSand, icValue: 1.25, estimatedQcMPa: 26.5, fsKPa: 190, isHazard: false)
        ]
    )
    
    public static let sampleBoreholeVirtual = VirtualBoreholeRecord(
        coordinateCode: "Virtual Log #VB-07",
        easting: 24.5,
        northing: 16.0,
        surfaceElevation: 11.8,
        totalDepth: 20.0,
        dataSource: .virtualPrediction,
        marginOfErrorPercent: 9.8,
        nearestRealCPTName: "CPT-02",
        distanceToRealCPT: 14.2,
        bearingLayerDepth: 16.2,
        intervals: [
            SoilInterval(depthTop: 0.0, depthBottom: 2.0, zone: .cleanSandToSiltySand, icValue: 1.80, estimatedQcMPa: 12.0, fsKPa: 48, isHazard: false),
            SoilInterval(depthTop: 2.0, depthBottom: 4.2, zone: .clayeySiltToSiltySand, icValue: 2.25, estimatedQcMPa: 6.8, fsKPa: 55, isHazard: false),
            SoilInterval(depthTop: 4.2, depthBottom: 8.5, zone: .clay, icValue: 3.22, estimatedQcMPa: 1.1, fsKPa: 19, isHazard: true),
            SoilInterval(depthTop: 8.5, depthBottom: 16.2, zone: .siltyClayToClay, icValue: 2.68, estimatedQcMPa: 5.1, fsKPa: 84, isHazard: false),
            SoilInterval(depthTop: 16.2, depthBottom: 20.0, zone: .gravellySandToDenseSand, icValue: 1.22, estimatedQcMPa: 28.0, fsKPa: 210, isHazard: false)
        ]
    )
    
    public static let hazardAlerts: [GeotechnicalHazardAlert] = [
        GeotechnicalHazardAlert(
            title: "Soft Sensitive Clay Lens (Consolidation Settlement)",
            sector: "Northeast & Central Sector (E: 18–32m, N: 12–26m)",
            depthSpan: "4.0 m to 8.5 m (thickness 4.5 m)",
            description: "High plasticity clay with Robertson Ic > 3.15 and cone resistance qc < 1.5 MPa. Susceptible to excessive long-term settlement under structural surcharge.",
            engineeringImpact: "Precludes shallow raft foundations without ground improvement or deep pile transfer.",
            severity: .critical,
            affectedZone: .clay
        ),
        GeotechnicalHazardAlert(
            title: "Loose Saturated Sand (Liquefaction Susceptibility)",
            sector: "Northwest Quadrant (E: 4–12m, N: 28–36m)",
            depthSpan: "0.5 m to 2.8 m",
            description: "Loose alluvial sand (Ic: 1.65–1.95) below the seasonal water table (GWT -1.2m). Cyclic Stress Ratio exceeds CRR for 0.25g PGA seismic event.",
            engineeringImpact: "Requires dynamic compaction or vibro-stone columns if supporting ground-bearing slabs.",
            severity: .moderate,
            affectedZone: .cleanSandToSiltySand
        ),
        GeotechnicalHazardAlert(
            title: "Dipping Hard Stratum / Non-Uniform Pile Refusal",
            sector: "Site-Wide Southward Dip (Dip Angle ~14°)",
            depthSpan: "North: −8.2 m → South: −17.8 m",
            description: "Bedrock/dense gravel bearing stratum slopes steeply southward. Ordering uniform length precast piles will cause cut-off waste or pile splicing delays.",
            engineeringImpact: "Requires stepped pile schedule divided into Zone North (10m) and Zone South (18m).",
            severity: .moderate,
            affectedZone: .gravellySandToDenseSand
        )
    ]
    
    public static let foundationReport = FoundationFeasibilityReport(
        shallowFoundationFeasible: false,
        shallowReason: "Infeasible: Presence of 4.5m thick compressible clay layer (qc < 1.5 MPa) within top 8m induces 145mm differential settlement.",
        recommendedDeepFoundation: "Driven Precast Spun Piles (Ø450mm) or Bored Piles",
        estimatedPileLengthMin: 10.5,
        estimatedPileLengthMax: 18.0,
        cutAndFillSurfaceM: +0.45,
        cutVolumeM3: 420.0,
        fillVolumeM3: 1150.0,
        settlementRiskRating: "High (Without Piling)"
    )
    
    public static let siteWideAdvice = AIAdvisorAdvice(
        scenarioTitle: "Site-Wide Subsurface Synthesis (Scenario A)",
        keyFinding: "Steep southward stratigraphic dip with a persistent soft clay paleochannel at 4–8m depth.",
        geologicalInterpretation: "SchemaGAN reconstruction indicates an alluvial depositional environment. The bearing gravel stratum rises to −8.2m at the north boundary but dips sharply to −17.8m at the south boundary.",
        foundationRecommendation: "Adopt deep pile foundations founded into the Zone 7 gravelly sand. Zone pile lengths into North Sector (10–12m) and South Sector (17–19m) to optimize procurement costs.",
        confidenceRating: "Model Reliability: 91.4% (Highest in NW/SE CPT corridors; caution advised along southern perimeter).",
        actionableNextStep: "Sign off foundation concept for piling; execute one confirmatory rotary SPT borehole at South perimeter before driving."
    )
    
    public static func adviceForBorehole(_ vb: VirtualBoreholeRecord) -> AIAdvisorAdvice {
        let isReal = vb.dataSource == .measuredReal
        let errStr = isReal ? "Ground Truth Measured (±0% error)" : "Extracted Virtual Log (SchemaGAN prediction ±\(String(format: "%.1f", vb.marginOfErrorPercent ?? 10.0))%)"
        
        return AIAdvisorAdvice(
            scenarioTitle: "Virtual Borehole \(vb.coordinateCode) (Scenario B)",
            keyFinding: "Bearing stratum reached at −\(String(format: "%.1f", vb.bearingLayerDepth))m depth with 4.3m soft clay surcharge.",
            geologicalInterpretation: "At coordinates (E: \(String(format: "%.1f", vb.easting))m, N: \(String(format: "%.1f", vb.northing))m), the upper 2m sand crust is underlain by soft clay (Ic \(String(format: "%.2f", vb.intervals.first(where: { $0.zone == .clay })?.icValue ?? 3.2))).",
            foundationRecommendation: "Design single pile working load = 680 kN with tip embedded at least 1.5m into dense bearing sand (−\(String(format: "%.1f", vb.bearingLayerDepth + 1.5))m).",
            confidenceRating: errStr,
            actionableNextStep: isReal ? "Data verified by physical cone thrust. Safe for structural calculations." : "Within 14.2m of CPT-02. Verified safe for preliminary pile design; no additional sounding required."
        )
    }
}
