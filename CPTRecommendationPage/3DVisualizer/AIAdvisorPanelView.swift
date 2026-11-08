//
//  AIAdvisorPanelView.swift
//  CPTRecommendationPage
//
//  AI Subsurface Advisor ("Subsurface Decision Engine")
//  Supports Scenario A (Site-Wide Summary) & Scenario B (Virtual Borehole Query)
//  Includes Module 2 (Hazards) & Module 5 (Foundation Feasibility)
//

import SwiftUI

public struct AIAdvisorPanelView: View {
    public let advice: AIAdvisorAdvice
    public let foundationReport: FoundationFeasibilityReport
    public let hazards: [GeotechnicalHazardAlert]
    public var onToggleHazardFilter: ((RobertsonSBTZone) -> Void)?
    
    public init(
        advice: AIAdvisorAdvice = SubsurfaceMockData.siteWideAdvice,
        foundationReport: FoundationFeasibilityReport = SubsurfaceMockData.foundationReport,
        hazards: [GeotechnicalHazardAlert] = SubsurfaceMockData.hazardAlerts,
        onToggleHazardFilter: ((RobertsonSBTZone) -> Void)? = nil
    ) {
        self.advice = advice
        self.foundationReport = foundationReport
        self.hazards = hazards
        self.onToggleHazardFilter = onToggleHazardFilter
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                // Scenario Header & AI Pill
                HStack {
                    Label("AI SUBSURFACE ADVISOR", systemImage: "sparkles")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color.accentColor)
                    Spacer()
                    Text(advice.confidenceRating)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(Color.green)
                        .clipShape(Capsule())
                }
                
                // Key Finding Card
                VStack(alignment: .leading, spacing: 6) {
                    Text(advice.scenarioTitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(.secondaryLabel))
                    Text(advice.keyFinding)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(.label))
                    Text(advice.geologicalInterpretation)
                        .font(.caption)
                        .lineSpacing(2)
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Module 5: Foundation Feasibility Indicator
                VStack(alignment: .leading, spacing: 8) {
                    Text("FOUNDATION FEASIBILITY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    HStack(spacing: 8) {
                        // Shallow Footing
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Shallow Raft/Footing")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                            Text(foundationReport.shallowFoundationFeasible ? "FEASIBLE" : "NOT FEASIBLE")
                                .font(.caption.bold())
                                .foregroundStyle(foundationReport.shallowFoundationFeasible ? Color.green : Color.red)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(foundationReport.shallowFoundationFeasible ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Deep Pile
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Deep Foundation")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                            Text("RECOMMENDED")
                                .font(.caption.bold())
                                .foregroundStyle(Color.green)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Pile Length & Cut/Fill
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Estimated Pile Length:")
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Text("\(String(format: "%.1f", foundationReport.estimatedPileLengthMin))–\(String(format: "%.1f", foundationReport.estimatedPileLengthMax)) m")
                                .font(.caption.bold().monospaced())
                                .foregroundStyle(Color.orange)
                        }
                        HStack {
                            Text("Cut / Fill Balance:")
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                            Spacer()
                            Text("Cut \(Int(foundationReport.cutVolumeM3)) m³ • Fill \(Int(foundationReport.fillVolumeM3)) m³")
                                .font(.caption.monospaced())
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Module 2: Geotechnical Risk & Hazard Radar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("GEOTECHNICAL HAZARD ALERTS")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.red)
                        Spacer()
                        Text("\(hazards.count) ACTIVE")
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(Color.red)
                            .clipShape(Capsule())
                    }
                    
                    ForEach(hazards) { hazard in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Image(systemName: hazard.severity.iconName)
                                    .foregroundStyle(hazard.severity.color)
                                Text(hazard.title)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color(.label))
                                Spacer()
                                Button {
                                    onToggleHazardFilter?(hazard.affectedZone)
                                } label: {
                                    Text("Isolate 3D")
                                        .font(.system(size: 8, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(hazard.severity.color.opacity(0.15))
                                        .foregroundStyle(hazard.severity.color)
                                        .clipShape(Capsule())
                                }
                            }
                            Text("\(hazard.sector) • Depth: \(hazard.depthSpan)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(Color(.secondaryLabel))
                            Text(hazard.engineeringImpact)
                                .font(.system(size: 10))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                // Actionable Recommendation Callout
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("ENGINEERING SIGN-OFF RECOMMENDATION")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Color.accentColor)
                    }
                    Text(advice.actionableNextStep)
                        .font(.caption.bold())
                        .foregroundStyle(Color(.label))
                }
                .padding(10)
                .background(Color.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
    }
}
