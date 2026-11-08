//
//  CPTModels.swift
//  CPTRecommendationPage
//
//  Geotechnical Domain Models & Synthetic Data for SchemaGAN-3D & DQN-3D
//

import SwiftUI
import Foundation

// MARK: - Point Status & Geotechnical Entities
public enum CPTPointStatus: String, CaseIterable, Identifiable {
    case completed
    case recommended
    case candidate
    case accessRestricted
    case excludedBuilding
    case excludedWater
    
    public var id: String { rawValue }
    
    public var displayLabel: String {
        switch self {
        case .completed: return "Observed (Pushed)"
        case .recommended: return "Recommended Next"
        case .candidate: return "Legal Candidate"
        case .accessRestricted: return "Access Restricted"
        case .excludedBuilding: return "Building Obstacle"
        case .excludedWater: return "Water Body"
        }
    }
}

public struct CPTPoint: Identifiable, Hashable {
    public let id: String
    public let code: String
    public var easting: Double   // meters
    public var northing: Double  // meters
    public var status: CPTPointStatus
    public var qScore: Double?             // DQN 3D output
    public var uncertaintyReduction: Double? // % reduction in SchemaGAN error
    public var nearestNeighborDistance: Double? // m
    public var depth: Double               // m investigated or projected
    public var timestamp: Date?
    
    public init(
        id: String,
        code: String,
        easting: Double,
        northing: Double,
        status: CPTPointStatus,
        qScore: Double? = nil,
        uncertaintyReduction: Double? = nil,
        nearestNeighborDistance: Double? = nil,
        depth: Double = 20.0,
        timestamp: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.easting = easting
        self.northing = northing
        self.status = status
        self.qScore = qScore
        self.uncertaintyReduction = uncertaintyReduction
        self.nearestNeighborDistance = nearestNeighborDistance
        self.depth = depth
        self.timestamp = timestamp
    }
}

// MARK: - Soil Stratigraphy (Robertson SBT 1990 & SchemaGAN Reconstruction)
public struct StratigraphyLayer: Identifiable, Hashable {
    public let id = UUID()
    public let depthStart: Double // meters
    public let depthEnd: Double   // meters
    public let sbtZone: Int       // Robertson SBT 1 to 9
    public let sbtName: String
    public let icMean: Double     // Soil Behavior Type Index
    public let icStdDev: Double   // SchemaGAN standard deviation / heterogeneity
    public let coneResistanceQc: Double // MPa estimated
    public let isAnomaly: Bool
    public let isConfirmed: Bool
    
    public var color: Color {
        switch sbtZone {
        case 1: return Color(red: 0.35, green: 0.25, blue: 0.20) // Sensitive Fine Grained
        case 2: return Color(red: 0.40, green: 0.30, blue: 0.22) // Organic Material
        case 3: return Color(red: 0.30, green: 0.50, blue: 0.70) // Clay
        case 4: return Color(red: 0.45, green: 0.65, blue: 0.65) // Silty Clay to Clay
        case 5: return Color(red: 0.75, green: 0.70, blue: 0.50) // Clayey Silt to Silty Sand
        case 6: return Color(red: 0.88, green: 0.80, blue: 0.45) // Clean Sand to Silty Sand
        case 7: return Color(red: 0.95, green: 0.85, blue: 0.35) // Gravelly Sand to Sand
        case 8: return Color(red: 0.65, green: 0.55, blue: 0.45) // Stiff Sand to Clayey Sand
        default: return Color.gray
        }
    }
}

// MARK: - Investigation Stage & Policy
public enum InvestigationPolicy: String {
    case scaledDQN = "scaled_dqn"
    case uniform = "uniform"
    
    public var title: String {
        switch self {
        case .scaledDQN: return "Smart Exploration (DQN-3D)"
        case .uniform: return "Coverage Validation (Uniform)"
        }
    }
    
    public var badgeDescription: String {
        switch self {
        case .scaledDQN: return "Focus: Stratigraphic anomalies & high-uncertainty blindspots"
        case .uniform: return "Focus: Boundary closure & geometric spatial uniformity"
        }
    }
}

// MARK: - Explainable AI (XAI) Three Pillars Model
public struct XAIReasoning {
    public let targetCPTCode: String
    public let easting: Double
    public let northing: Double
    public let projectedImpactPercent: Double
    public let qScore: Double
    
    // Pillar 1: Spatial Blindspot
    public let nearestCPTCode: String
    public let nearestCPTDistance: Double // meters
    public let localDensity4m: Double     // CPTs within 4m
    public let spatialSector: String      // e.g. "Northeast Sector"
    public let spatialReason: String
    
    // Pillar 2: Geological Complexity (SchemaGAN 3D)
    public let reconstructedIcStdZ: Double // Vertical heterogeneity
    public let depthAnomalyStart: Double
    public let depthAnomalyEnd: Double
    public let suspectedFeature: String
    public let complexityReason: String
    
    // Pillar 3: Efficiency & Budget (DQN Policy)
    public let policyUsed: InvestigationPolicy
    public let currentCPTNumber: Int
    public let totalBudgetCPTs: Int
    public let remainingBudgetUSD: Double
    public let costThisPushUSD: Double
    public let efficiencyReason: String
    
    // Synthesized Template Sentence
    public var formattedConclusion: String {
        "\(targetCPTCode) is recommended at (E: \(String(format: "%.1f", easting)) m, N: \(String(format: "%.1f", northing)) m)."
    }
    
    public var formattedFullNarrative: String {
        """
        \(formattedConclusion)
        Key reasons:
        1. Spatial blindspot: \(spatialReason)
        2. High layer uncertainty: \(complexityReason)
        3. Estimated impact: Testing here is projected to reduce subsurface volume uncertainty error by \(Int(projectedImpactPercent))%.
        """
    }
}

// MARK: - Candidate Alternative
public struct CandidateAlternative: Identifiable {
    public let id = UUID()
    public let code: String
    public let rank: Int
    public let easting: Double
    public let northing: Double
    public let qScore: Double
    public let uncertaintyGainPercent: Double
    public let blindspotDistance: Double
    public let primaryPillar: String
}

// MARK: - Site Grid & Map Metadata
public struct SiteGridSnapshot {
    public let widthMeters: Double = 40.0
    public let heightMeters: Double = 40.0
    public let gridResolutionMeters: Double = 2.0
    
    // Known Points
    public var completedPoints: [CPTPoint]
    public var recommendedPoint: CPTPoint
    public var candidatePoints: [CPTPoint]
    public var alternatives: [CandidateAlternative]
    public var projectedLayers: [StratigraphyLayer]
    public var reasoning: XAIReasoning
}

// MARK: - Geotechnical Mock Data Provider
public enum GeotechSampleData {
    public static let sampleReasoningExploration = XAIReasoning(
        targetCPTCode: "CPT-04",
        easting: 24.0,
        northing: 16.0,
        projectedImpactPercent: 28.0,
        qScore: 0.914,
        nearestCPTCode: "CPT-02",
        nearestCPTDistance: 14.2,
        localDensity4m: 0.0,
        spatialSector: "Northeast Sector",
        spatialReason: "The largest empty area in the northeast sector (14.2 m from CPT-02, zero data within 4 m).",
        reconstructedIcStdZ: 0.86,
        depthAnomalyStart: 4.0,
        depthAnomalyEnd: 8.0,
        suspectedFeature: "Suspected soft clay lens (Ic > 2.95) with sharp transition",
        complexityReason: "SchemaGAN reconstruction detects possible sharp stratigraphic variation at 4–8 m depth that is not yet confirmed by physical penetration.",
        policyUsed: .scaledDQN,
        currentCPTNumber: 4,
        totalBudgetCPTs: 12,
        remainingBudgetUSD: 9600.0,
        costThisPushUSD: 1200.0,
        efficiencyReason: "Smart Exploration stage: DQN prioritizes geological variance over pure distance to maximize early model certainty."
    )
    
    public static let sampleReasoningValidation = XAIReasoning(
        targetCPTCode: "CPT-09",
        easting: 8.0,
        northing: 28.0,
        projectedImpactPercent: 14.0,
        qScore: 0.682,
        nearestCPTCode: "CPT-07",
        nearestCPTDistance: 11.5,
        localDensity4m: 0.0,
        spatialSector: "Southwest Boundary",
        spatialReason: "Boundary closure gap on the southwest perimeter before site commissioning.",
        reconstructedIcStdZ: 0.28,
        depthAnomalyStart: 0.0,
        depthAnomalyEnd: 20.0,
        suspectedFeature: "Uniform alluvial sand with gradual silt transition",
        complexityReason: "Stratigraphy is largely consistent; verification is required to constrain outer volume boundary.",
        policyUsed: .uniform,
        currentCPTNumber: 9,
        totalBudgetCPTs: 12,
        remainingBudgetUSD: 3600.0,
        costThisPushUSD: 1200.0,
        efficiencyReason: "Coverage Validation stage: Hybrid policy switched to uniform geometric dispersion to eliminate perimeter boundary errors."
    )
    
    public static let completedCPTs: [CPTPoint] = [
        CPTPoint(id: "1", code: "CPT-01", easting: 6.0, northing: 8.0, status: .completed, depth: 18.5, timestamp: Date().addingTimeInterval(-86400 * 2)),
        CPTPoint(id: "2", code: "CPT-02", easting: 10.0, northing: 22.0, status: .completed, depth: 20.0, timestamp: Date().addingTimeInterval(-86400)),
        CPTPoint(id: "3", code: "CPT-03", easting: 32.0, northing: 30.0, status: .completed, depth: 21.2, timestamp: Date().addingTimeInterval(-3600 * 4))
    ]
    
    public static let recommendedPoint = CPTPoint(
        id: "4",
        code: "CPT-04",
        easting: 24.0,
        northing: 16.0,
        status: .recommended,
        qScore: 0.914,
        uncertaintyReduction: 28.0,
        nearestNeighborDistance: 14.2,
        depth: 20.0
    )
    
    public static let candidateAlternatives: [CandidateAlternative] = [
        CandidateAlternative(code: "CPT-04 (Selected)", rank: 1, easting: 24.0, northing: 16.0, qScore: 0.914, uncertaintyGainPercent: 28.0, blindspotDistance: 14.2, primaryPillar: "Anomaly + Blindspot"),
        CandidateAlternative(code: "Candidate B", rank: 2, easting: 18.0, northing: 34.0, qScore: 0.785, uncertaintyGainPercent: 19.5, blindspotDistance: 12.8, primaryPillar: "Blindspot Only"),
        CandidateAlternative(code: "Candidate C", rank: 3, easting: 30.0, northing: 10.0, qScore: 0.710, uncertaintyGainPercent: 15.2, blindspotDistance: 10.4, primaryPillar: "Edge Boundary")
    ]
    
    public static let projectedStratigraphy: [StratigraphyLayer] = [
        StratigraphyLayer(depthStart: 0.0, depthEnd: 2.5, sbtZone: 6, sbtName: "Clean Sand to Silty Sand", icMean: 1.82, icStdDev: 0.12, coneResistanceQc: 12.5, isAnomaly: false, isConfirmed: true),
        StratigraphyLayer(depthStart: 2.5, depthEnd: 4.0, sbtZone: 5, sbtName: "Clayey Silt to Silty Sand", icMean: 2.25, icStdDev: 0.22, coneResistanceQc: 6.8, isAnomaly: false, isConfirmed: true),
        StratigraphyLayer(depthStart: 4.0, depthEnd: 8.0, sbtZone: 3, sbtName: "Soft Clay Lens (Suspected Anomaly)", icMean: 3.10, icStdDev: 0.86, coneResistanceQc: 1.2, isAnomaly: true, isConfirmed: false),
        StratigraphyLayer(depthStart: 8.0, depthEnd: 14.0, sbtZone: 4, sbtName: "Silty Clay to Stiff Clay", icMean: 2.65, icStdDev: 0.35, coneResistanceQc: 4.5, isAnomaly: false, isConfirmed: false),
        StratigraphyLayer(depthStart: 14.0, depthEnd: 20.0, sbtZone: 7, sbtName: "Dense Sand & Gravel Bearing", icMean: 1.45, icStdDev: 0.18, coneResistanceQc: 24.0, isAnomaly: false, isConfirmed: false)
    ]
    
    public static func makeSampleSite() -> SiteGridSnapshot {
        SiteGridSnapshot(
            completedPoints: completedCPTs,
            recommendedPoint: recommendedPoint,
            candidatePoints: [
                CPTPoint(id: "c1", code: "C-01", easting: 18.0, northing: 34.0, status: .candidate, qScore: 0.785),
                CPTPoint(id: "c2", code: "C-02", easting: 30.0, northing: 10.0, status: .candidate, qScore: 0.710),
                CPTPoint(id: "c3", code: "C-03", easting: 14.0, northing: 14.0, status: .candidate, qScore: 0.620)
            ],
            alternatives: candidateAlternatives,
            projectedLayers: projectedStratigraphy,
            reasoning: sampleReasoningExploration
        )
    }
}
