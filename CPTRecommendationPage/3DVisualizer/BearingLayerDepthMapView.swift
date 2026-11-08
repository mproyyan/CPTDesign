//
//  BearingLayerDepthMapView.swift
//  CPTRecommendationPage
//
//  Module 1: 2D Contour Heatmap of Bearing Layer / Hard Stratum Depth
//  Displays southward dipping stratum (-8m to -18m) and pile refusal depth
//
 
import SwiftUI

public struct BearingLayerDepthMapView: View {
    public var selectedCoordinate: (Double, Double)?
    public var onSelectCoordinate: ((Double, Double) -> Void)?
    
    public init(
        selectedCoordinate: (Double, Double)? = nil,
        onSelectCoordinate: ((Double, Double) -> Void)? = nil
    ) {
        self.selectedCoordinate = selectedCoordinate
        self.onSelectCoordinate = onSelectCoordinate
    }
    
    public var body: some View {
        GeometryReader { geo in
            let padding: CGFloat = 16
            let mapRect = CGRect(x: padding, y: padding, width: geo.size.width - (padding * 2), height: geo.size.height - (padding * 2))
            
            ZStack {
                // Dipping Hard Layer Contour Gradient (North -8.2m to South -17.8m)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.75, blue: 0.25), // Shallow North (-8m)
                        Color(red: 0.85, green: 0.55, blue: 0.20), // Mid (-12m)
                        Color(red: 0.65, green: 0.35, blue: 0.15), // Deep South (-16m)
                        Color(red: 0.40, green: 0.20, blue: 0.10)  // Deepest (-18m)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Contour Iso-Lines (Overlay lines showing -8m, -10m, -12m, -14m, -16m, -18m)
                Canvas { context, size in
                    let contours: [(yFraction: CGFloat, label: String)] = [
                        (0.15, "−8.0 m"),
                        (0.32, "−10.0 m"),
                        (0.50, "−12.0 m"),
                        (0.68, "−14.0 m"),
                        (0.85, "−16.0 m"),
                        (0.95, "−18.0 m")
                    ]
                    
                    for contour in contours {
                        let y = mapRect.minY + (mapRect.height * contour.yFraction)
                        var path = Path()
                        path.move(to: CGPoint(x: mapRect.minX, y: y))
                        // Add slight geological waviness
                        path.addQuadCurve(
                            to: CGPoint(x: mapRect.maxX, y: y + 8),
                            control: CGPoint(x: mapRect.midX, y: y - 10)
                        )
                        context.stroke(path, with: .color(Color.white.opacity(0.4)), lineWidth: 1)
                    }
                }
                
                // Contour Labels Overlay
                VStack {
                    HStack {
                        Text("North: −8.2 m (Shallow Refusal)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(8)
                    
                    Spacer()
                    
                    HStack {
                        Text("South: −17.8 m (Deep Refusal)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(8)
                }
                
                // Selected Probe Indicator
                if let coord = selectedCoordinate {
                    let px = mapRect.minX + (CGFloat(coord.0 / 40.0) * mapRect.width)
                    let py = mapRect.maxY - (CGFloat(coord.1 / 40.0) * mapRect.height)
                    
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .background(Circle().fill(Color.red))
                        .frame(width: 14, height: 14)
                        .position(x: px, y: py)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { loc in
                let normX = max(2.0, min(38.0, (Double(loc.x - padding) / Double(mapRect.width)) * 40.0))
                let normY = max(2.0, min(38.0, (1.0 - (Double(loc.y - padding) / Double(mapRect.height))) * 40.0))
                onSelectCoordinate?(normX, normY)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            )
        }
    }
}
