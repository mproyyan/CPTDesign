//
//  VirtualBoreholeLogView.swift
//  CPTRecommendationPage
//
//  Module 4: Virtual Borehole / Synthetic Log Extractor
//  Displays vertical stratigraphy column, Robertson SBT colors,
//  depth-vs-qc/Ic chart, and Real vs AI Prediction status
//

import SwiftUI

public struct VirtualBoreholeLogView: View {
    public let borehole: VirtualBoreholeRecord
    
    public init(borehole: VirtualBoreholeRecord = SubsurfaceMockData.sampleBoreholeVirtual) {
        self.borehole = borehole
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Coordinate & Ground Truth Status Badge
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(borehole.coordinateCode)
                        .font(.headline.bold())
                    Spacer()
                    Text("Refusal: −\(String(format: "%.1f", borehole.bearingLayerDepth))m")
                        .font(.caption.monospaced().bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(Color.orange)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 8) {
                    Text("E: \(String(format: "%.1f", borehole.easting))m, N: \(String(format: "%.1f", borehole.northing))m")
                        .font(.caption.monospaced())
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("•")
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("Elev: +\(String(format: "%.1f", borehole.surfaceElevation))m")
                        .font(.caption.monospaced())
                        .foregroundStyle(Color(.secondaryLabel))
                }
                
                // Status Badge: Measured vs AI Prediction
                HStack(spacing: 6) {
                    Circle()
                        .fill(borehole.dataSource == .measuredReal ? Color.green : Color.purple)
                        .frame(width: 8, height: 8)
                    Text(borehole.dataSource.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(borehole.dataSource == .measuredReal ? Color.green : Color.purple)
                    
                    if let err = borehole.marginOfErrorPercent {
                        Text("(±\(String(format: "%.1f", err))%)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(borehole.dataSource == .measuredReal ? Color.green.opacity(0.1) : Color.purple.opacity(0.1))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            
            Divider()
            
            // Stratigraphy Column + qc / Ic Curves
            HStack(spacing: 12) {
                // Stratigraphy Color Column
                VStack(spacing: 2) {
                    ForEach(borehole.intervals) { interval in
                        let heightRatio = interval.thickness / borehole.totalDepth
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", interval.depthTop))
                                .font(.system(size: 8, design: .monospaced))
                                .frame(width: 22, alignment: .trailing)
                                .foregroundStyle(Color(.secondaryLabel))
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(interval.zone.color)
                                
                                if interval.isHazard {
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(Color.red, lineWidth: 1.5)
                                }
                                
                                Text(interval.zone.shortLabel)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                    .padding(.leading, 4)
                                    .lineLimit(1)
                            }
                            .frame(height: max(20, CGFloat(heightRatio * 180)))
                        }
                    }
                }
                .frame(width: 130)
                
                // qc (MPa) & Ic Profile Bars
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("qc (MPa)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.orange)
                        Spacer()
                        Text("Ic index")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.blue)
                    }
                    
                    ForEach(borehole.intervals) { interval in
                        HStack {
                            // qc bar
                            GeometryReader { g in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.orange)
                                    .frame(width: max(4, CGFloat(interval.estimatedQcMPa / 30.0) * g.size.width))
                            }
                            .frame(height: 12)
                            
                            Text("\(String(format: "%.1f", interval.estimatedQcMPa))")
                                .font(.system(size: 8, design: .monospaced))
                                .frame(width: 24)
                            
                            Text("Ic: \(String(format: "%.2f", interval.icValue))")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(Color.blue)
                                .frame(width: 44)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
