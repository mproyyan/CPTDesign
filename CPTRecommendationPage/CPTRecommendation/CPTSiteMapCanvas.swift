//
//  CPTSiteMapCanvas.swift
//  CPTRecommendationPage
//
//  Reusable Geotechnical Site Grid Canvas with SchemaGAN Uncertainty & DQN Heatmap Overlays
//

import SwiftUI

public enum MapOverlayLayer: String, CaseIterable, Identifiable {
    case dqnHeatmap = "Q-Score Heatmap"
    case uncertainty = "SchemaGAN Uncertainty"
    case blindspotRadius = "Blindspot Distance"
    case clean = "Base Grid"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .dqnHeatmap: return "flame.fill"
        case .uncertainty: return "waveform.path.ecg"
        case .blindspotRadius: return "circle.dashed"
        case .clean: return "square.grid.3x3.fill"
        }
    }
}

public struct CPTSiteMapCanvas: View {
    public var completedPoints: [CPTPoint]
    public var recommendedPoint: CPTPoint
    public var candidatePoints: [CPTPoint]
    public var activeOverlay: MapOverlayLayer
    public var showCrossSectionLine: Bool
    public var onSelectPoint: ((CPTPoint) -> Void)?
    
    public init(
        completedPoints: [CPTPoint] = GeotechSampleData.completedCPTs,
        recommendedPoint: CPTPoint = GeotechSampleData.recommendedPoint,
        candidatePoints: [CPTPoint] = GeotechSampleData.makeSampleSite().candidatePoints,
        activeOverlay: MapOverlayLayer = .dqnHeatmap,
        showCrossSectionLine: Bool = false,
        onSelectPoint: ((CPTPoint) -> Void)? = nil
    ) {
        self.completedPoints = completedPoints
        self.recommendedPoint = recommendedPoint
        self.candidatePoints = candidatePoints
        self.activeOverlay = activeOverlay
        self.showCrossSectionLine = showCrossSectionLine
        self.onSelectPoint = onSelectPoint
    }
    
    private let siteWidthMeters: Double = 40.0
    private let siteHeightMeters: Double = 40.0
    
    public var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let padding: CGFloat = 28
            let mapRect = CGRect(x: padding, y: padding, width: proxy.size.width - (padding * 2), height: proxy.size.height - (padding * 2))
            
            ZStack {
                // Background Terrain / Base
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                
                // Grid ticks & Coordinate frame
                CoordinateGridFrame(rect: mapRect, widthM: siteWidthMeters, heightM: siteHeightMeters)
                
                // Exclusion zones & Access Boundary
                AccessBoundaryShape(rect: mapRect)
                    .stroke(Color.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                
                BuildingObstacleShape(rect: mapRect)
                    .fill(Color(.systemGray4).opacity(0.7))
                    .overlay(
                        Text("Existing Structure")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                            .position(mapPoint(x: 32, y: 8, in: mapRect))
                    )
                
                WaterBodyShape(rect: mapRect)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        Text("Retention Basin")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.blue.opacity(0.8))
                            .position(mapPoint(x: 8, y: 34, in: mapRect))
                    )
                
                // Heatmap or Uncertainty Layer
                if activeOverlay == .dqnHeatmap {
                    DQNHeatmapOverlay(rect: mapRect)
                } else if activeOverlay == .uncertainty {
                    UncertaintyOverlay(rect: mapRect)
                } else if activeOverlay == .blindspotRadius {
                    BlindspotRadiusOverlay(rect: mapRect, recommended: recommendedPoint, completed: completedPoints)
                }
                
                // Geological Cross Section Cutting Line A-A'
                if showCrossSectionLine {
                    CrossSectionLineAA(rect: mapRect, through: recommendedPoint)
                }
                
                // Distance indicator lines from CPT-04 to nearest CPT-02
                if let cpt02 = completedPoints.first(where: { $0.code == "CPT-02" }) {
                    DistanceLineView(
                        from: mapPoint(x: recommendedPoint.easting, y: recommendedPoint.northing, in: mapRect),
                        to: mapPoint(x: cpt02.easting, y: cpt02.northing, in: mapRect),
                        distanceMeters: 14.2
                    )
                }
                
                // Completed CPT Markers
                ForEach(completedPoints) { pt in
                    let pos = mapPoint(x: pt.easting, y: pt.northing, in: mapRect)
                    CompletedCPTMarker(point: pt)
                        .position(pos)
                        .onTapGesture {
                            onSelectPoint?(pt)
                        }
                }
                
                // Candidate Points
                ForEach(candidatePoints) { cand in
                    let pos = mapPoint(x: cand.easting, y: cand.northing, in: mapRect)
                    CandidateCPTMarker(point: cand)
                        .position(pos)
                        .onTapGesture {
                            onSelectPoint?(cand)
                        }
                }
                
                // Recommended CPT Marker (Prominent beacon)
                let recPos = mapPoint(x: recommendedPoint.easting, y: recommendedPoint.northing, in: mapRect)
                RecommendedCPTMarker(point: recommendedPoint)
                    .position(recPos)
                    .onTapGesture {
                        onSelectPoint?(recommendedPoint)
                    }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            )
        }
    }
    
    private func mapPoint(x: Double, y: Double, in rect: CGRect) -> CGPoint {
        let px = rect.minX + (CGFloat(x / siteWidthMeters) * rect.width)
        // Invert Y so North is Up
        let py = rect.maxY - (CGFloat(y / siteHeightMeters) * rect.height)
        return CGPoint(x: px, y: py)
    }
}

// MARK: - Subcomponents & Overlays

private struct CoordinateGridFrame: View {
    let rect: CGRect
    let widthM: Double
    let heightM: Double
    
    var body: some View {
        Canvas { context, size in
            let cols = 8
            let rows = 8
            
            // Draw grid lines
            for i in 0...cols {
                let x = rect.minX + (rect.width / CGFloat(cols)) * CGFloat(i)
                var path = Path()
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
                context.stroke(path, with: .color(Color(.separator).opacity(0.35)), lineWidth: 0.5)
            }
            
            for j in 0...rows {
                let y = rect.minY + (rect.height / CGFloat(rows)) * CGFloat(j)
                var path = Path()
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: rect.maxX, y: y))
                context.stroke(path, with: .color(Color(.separator).opacity(0.35)), lineWidth: 0.5)
            }
        }
        .overlay(
            VStack {
                HStack {
                    Text("North ↑ (0–40m)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                    Spacer()
                    Text("Easting → (0–40m)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(8)
                Spacer()
            }
        )
    }
}

private struct AccessBoundaryShape: Shape {
    let rect: CGRect
    func path(in rectBounds: CGRect) -> Path {
        var path = Path()
        // Property perimeter polygon
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.10))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.95, y: rect.minY + rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.90, y: rect.minY + rect.height * 0.90))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.95))
        path.closeSubpath()
        return path
    }
}

private struct BuildingObstacleShape: Shape {
    let rect: CGRect
    func path(in rectBounds: CGRect) -> Path {
        let origin = CGPoint(x: rect.minX + rect.width * 0.70, y: rect.maxY - rect.height * 0.30)
        let size = CGSize(width: rect.width * 0.22, height: rect.height * 0.22)
        return Path(roundedRect: CGRect(origin: origin, size: size), cornerRadius: 6)
    }
}

private struct WaterBodyShape: Shape {
    let rect: CGRect
    func path(in rectBounds: CGRect) -> Path {
        let origin = CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.08)
        let size = CGSize(width: rect.width * 0.20, height: rect.height * 0.20)
        return Path(ellipseIn: CGRect(origin: origin, size: size))
    }
}

private struct DQNHeatmapOverlay: View {
    let rect: CGRect
    var body: some View {
        Canvas { context, size in
            // High Q-score gradient around CPT-04 (E:24, N:16) -> normalized (0.6, 0.4)
            let center = CGPoint(x: rect.minX + rect.width * 0.60, y: rect.maxY - rect.height * 0.40)
            let radialGrad = Gradient(colors: [
                Color.orange.opacity(0.45),
                Color.yellow.opacity(0.30),
                Color.cyan.opacity(0.12),
                Color.clear
            ])
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 120, y: center.y - 120, width: 240, height: 240)),
                with: .radialGradient(radialGrad, center: center, startRadius: 10, endRadius: 120)
            )
        }
    }
}

private struct UncertaintyOverlay: View {
    let rect: CGRect
    var body: some View {
        Canvas { context, size in
            // SchemaGAN high uncertainty plume in Northeast quadrant
            let center = CGPoint(x: rect.minX + rect.width * 0.62, y: rect.maxY - rect.height * 0.45)
            let grad = Gradient(colors: [
                Color.purple.opacity(0.40),
                Color.purple.opacity(0.20),
                Color.clear
            ])
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 140, y: center.y - 140, width: 280, height: 280)),
                with: .radialGradient(grad, center: center, startRadius: 15, endRadius: 140)
            )
        }
    }
}

private struct BlindspotRadiusOverlay: View {
    let rect: CGRect
    let recommended: CPTPoint
    let completed: [CPTPoint]
    
    var body: some View {
        ZStack {
            ForEach(completed) { pt in
                let px = rect.minX + (CGFloat(pt.easting / 40.0) * rect.width)
                let py = rect.maxY - (CGFloat(pt.northing / 40.0) * rect.height)
                Circle()
                    .strokeBorder(Color.blue.opacity(0.35), lineWidth: 1)
                    .frame(width: 80, height: 80)
                    .position(x: px, y: py)
            }
        }
    }
}

private struct CrossSectionLineAA: View {
    let rect: CGRect
    let through: CPTPoint
    
    var body: some View {
        let y = rect.maxY - (CGFloat(through.northing / 40.0) * rect.height)
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        .stroke(Color.red, style: StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
        .overlay(
            HStack {
                Text("A")
                    .font(.caption2.bold())
                    .padding(4)
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                Spacer()
                Text("A'")
                    .font(.caption2.bold())
                    .padding(4)
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .position(x: rect.midX, y: y)
        )
    }
}

private struct DistanceLineView: View {
    let from: CGPoint
    let to: CGPoint
    let distanceMeters: Double
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(Color.secondary.opacity(0.6), style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
        .overlay(
            Text(String(format: "Δ %.1f m", distanceMeters))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Material.ultraThinMaterial)
                .clipShape(Capsule())
                .position(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2 - 8)
        )
    }
}

private struct CompletedCPTMarker: View {
    let point: CPTPoint
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 22, height: 22)
                Circle()
                    .strokeBorder(Color(.label), lineWidth: 2)
                    .frame(width: 22, height: 22)
                Circle()
                    .fill(Color(.label))
                    .frame(width: 8, height: 8)
            }
            Text(point.code)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(.label))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color(.systemBackground).opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }
}

private struct CandidateCPTMarker: View {
    let point: CPTPoint
    var body: some View {
        VStack(spacing: 1) {
            Circle()
                .strokeBorder(Color.orange.opacity(0.8), lineWidth: 1.5)
                .background(Circle().fill(Color.orange.opacity(0.2)))
                .frame(width: 14, height: 14)
            if let q = point.qScore {
                Text(String(format: "Q:%.2f", q))
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.orange)
            }
        }
    }
}

private struct RecommendedCPTMarker: View {
    let point: CPTPoint
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(pulse ? 0.35 : 0.15))
                    .frame(width: 38, height: 38)
                    .scaleEffect(pulse ? 1.25 : 0.95)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24)
                    .shadow(color: Color.accentColor.opacity(0.5), radius: 6, x: 0, y: 3)
                
                Image(systemName: "arrow.down.to.line.compact")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 1) {
                Text(point.code)
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
                Text("NEXT PUSH")
                    .font(.system(size: 7, weight: .black))
                    .foregroundStyle(Color.yellow)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.85))
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(Color.yellow, lineWidth: 1)
            )
        }
        .onAppear {
            pulse = true
        }
    }
}
