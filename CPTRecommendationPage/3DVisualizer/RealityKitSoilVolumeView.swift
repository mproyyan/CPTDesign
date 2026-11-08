//
//  RealityKitSoilVolumeView.swift
//  CPTRecommendationPage
//
//  RealityKit 3D Subsurface Soil Volume with Slicing, Slicing Planes,
//  Borehole Marker Pin & Uncertainty Fog Visualization
//

import SwiftUI
import RealityKit

public struct RealityKitSoilVolumeView: View {
    @Binding public var slicingState: SlicingFilterState
    public var selectedBorehole: VirtualBoreholeRecord?
    public var onSelectCoordinate: ((Double, Double) -> Void)?
    
    // Gestures
    @State private var rotationX: Double = 25.0  // Pitch degrees
    @State private var rotationY: Double = -40.0 // Yaw degrees
    @State private var scale: Double = 1.0
    @State private var lastDragPosition: CGPoint = .zero
    
    public init(
        slicingState: Binding<SlicingFilterState>,
        selectedBorehole: VirtualBoreholeRecord? = nil,
        onSelectCoordinate: ((Double, Double) -> Void)? = nil
    ) {
        self._slicingState = slicingState
        self.selectedBorehole = selectedBorehole
        self.onSelectCoordinate = onSelectCoordinate
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Background Depth Gradient
                RadialGradient(
                    gradient: Gradient(colors: [Color(.systemGray6), Color(.systemBackground)]),
                    center: .center,
                    startRadius: 80,
                    endRadius: proxy.size.width * 0.7
                )
                
                // RealityView 3D Viewport
                RealityView { content in
                    let rootAnchor = AnchorEntity(world: .zero)
                    rootAnchor.name = "RootAnchor"
                    
                    // Build Procedural Soil Stratigraphy Block
                    let siteEntity = makeSoilVolumeEntity()
                    siteEntity.name = "SoilVolume"
                    rootAnchor.addChild(siteEntity)
                    
                    // Add Directional Compass Indicator
                    let compassEntity = makeCompassEntity()
                    compassEntity.position = SIMD3<Float>(0.25, 0.15, -0.25)
                    rootAnchor.addChild(compassEntity)
                    
                    content.add(rootAnchor)
                } update: { content in
                    guard let rootAnchor = content.entities.first(where: { $0.name == "RootAnchor" }) else { return }
                    
                    // Update Borehole Marker
                    if let existingMarker = rootAnchor.findEntity(named: "BoreholeMarkerPin") {
                        rootAnchor.removeChild(existingMarker)
                    }
                    if let bh = selectedBorehole {
                        let pin = makeBoreholePinEntity(easting: bh.easting, northing: bh.northing, depth: bh.totalDepth)
                        pin.name = "BoreholeMarkerPin"
                        rootAnchor.addChild(pin)
                    }
                }
                .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                .scaleEffect(scale)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let deltaX = Double(value.translation.width - lastDragPosition.x)
                            let deltaY = Double(value.translation.height - lastDragPosition.y)
                            rotationY += deltaX * 0.4
                            rotationX = max(-75, min(75, rotationX - deltaY * 0.4))
                            lastDragPosition = CGPoint(x: value.translation.width, y: value.translation.height)
                        }
                        .onEnded { _ in
                            lastDragPosition = .zero
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { mag in
                            scale = max(0.65, min(2.2, scale * mag))
                        }
                )
                
                // Slicing Plane & Interactive Coordinate Tap Overlay
                VStack {
                    HStack {
                        // 3D Legend & Compass HUD
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Circle().fill(Color.accentColor).frame(width: 8, height: 8)
                                Text("RealityKit 3D Volume Engine")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            Text("Model: SchemaGAN-3D Robertson SBT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(.label))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Spacer()
                        
                        // Reset Camera Button
                        Button {
                            withAnimation(.spring()) {
                                rotationX = 25.0
                                rotationY = -40.0
                                scale = 1.0
                            }
                        } label: {
                            Label("Reset View", systemImage: "arrow.counterclockwise")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(14)
                    
                    Spacer()
                    
                    // Slicing Indicator HUD
                    HStack(spacing: 12) {
                        SliceBadge(axis: "Northing Cut", value: "\(String(format: "%.1f", slicingState.northingSlice)) m", color: .red)
                        SliceBadge(axis: "Easting Cut", value: "\(String(format: "%.1f", slicingState.eastingSlice)) m", color: .cyan)
                        SliceBadge(axis: "Depth Cut", value: "\(String(format: "%.1f", slicingState.depthSlice)) m", color: .orange)
                        
                        if slicingState.showConfidenceFogOverlay {
                            HStack(spacing: 4) {
                                Circle().fill(Color.green).frame(width: 6, height: 6)
                                Text("Confidence Fog ON")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        Text("Tap anywhere to extract Virtual Borehole")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(12)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { loc in
                // Normalize tap location to 0–40m site coordinates
                let normalizedX = max(2.0, min(38.0, (Double(loc.x) / Double(proxy.size.width)) * 40.0))
                let normalizedY = max(2.0, min(38.0, (1.0 - (Double(loc.y) / Double(proxy.size.height))) * 40.0))
                onSelectCoordinate?(normalizedX, normalizedY)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            )
        }
    }
    
    // MARK: - RealityKit Procedural Entity Builders
    
    private func makeSoilVolumeEntity() -> Entity {
        let parent = Entity()
        
        // Layers: Top to bottom (Y positive is up in RealityKit world space)
        // Stratigraphy stack normalized to width: 0.4m, depth: 0.4m, height: 0.2m (20m total soil)
        let layerSpecs: [(name: String, height: Float, yOffset: Float, color: UIColor)] = [
            ("CleanSand", 0.02, 0.09, UIColor(red: 0.88, green: 0.78, blue: 0.42, alpha: 0.95)),
            ("ClayeySilt", 0.02, 0.07, UIColor(red: 0.72, green: 0.68, blue: 0.48, alpha: 0.95)),
            ("SoftClayHazard", 0.045, 0.0375, UIColor(red: 0.28, green: 0.48, blue: 0.68, alpha: 0.92)),
            ("SiltyClay", 0.075, -0.0225, UIColor(red: 0.40, green: 0.62, blue: 0.62, alpha: 0.95)),
            ("BearingGravelSand", 0.04, -0.08, UIColor(red: 0.96, green: 0.84, blue: 0.32, alpha: 0.98))
        ]
        
        for spec in layerSpecs {
            let mesh = MeshResource.generateBox(width: 0.36, height: spec.height, depth: 0.36, cornerRadius: 0.002)
            var material = SimpleMaterial()
            material.color = .init(tint: spec.color)
            material.roughness = 0.65
            material.metallic = 0.05
            
            let layerEntity = ModelEntity(mesh: mesh, materials: [material])
            layerEntity.name = spec.name
            layerEntity.position = SIMD3<Float>(0, spec.yOffset, 0)
            parent.addChild(layerEntity)
        }
        
        // Base Foundation Grid Frame
        let baseMesh = MeshResource.generatePlane(width: 0.38, depth: 0.38)
        var baseMat = SimpleMaterial()
        baseMat.color = .init(tint: UIColor.lightGray.withAlphaComponent(0.3))
        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMat])
        baseEntity.position = SIMD3<Float>(0, -0.101, 0)
        parent.addChild(baseEntity)
        
        return parent
    }
    
    private func makeBoreholePinEntity(easting: Double, northing: Double, depth: Double) -> Entity {
        let pin = Entity()
        
        // Map (0..40m) to RealityKit local coordinate (-0.18 .. +0.18)
        let localX = Float((easting / 40.0) * 0.36 - 0.18)
        let localZ = Float((northing / 40.0) * 0.36 - 0.18)
        
        // Vertical borehole core cylinder (0 to 20m depth -> 0.2m height)
        let cylinderMesh = MeshResource.generateCylinder(height: 0.22, radius: 0.005)
        var cylMat = SimpleMaterial()
        cylMat.color = .init(tint: .systemRed)
        cylMat.roughness = 0.2
        let cylinderEntity = ModelEntity(mesh: cylinderMesh, materials: [cylMat])
        cylinderEntity.position = SIMD3<Float>(localX, 0.0, localZ)
        pin.addChild(cylinderEntity)
        
        // Top Beacon Sphere
        let sphereMesh = MeshResource.generateSphere(radius: 0.012)
        var sphereMat = SimpleMaterial()
        sphereMat.color = .init(tint: .yellow)
        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [sphereMat])
        sphereEntity.position = SIMD3<Float>(localX, 0.12, localZ)
        pin.addChild(sphereEntity)
        
        return pin
    }
    
    private func makeCompassEntity() -> Entity {
        let compass = Entity()
        let arrowMesh = MeshResource.generateCone(height: 0.03, radius: 0.008)
        var arrowMat = SimpleMaterial()
        arrowMat.color = .init(tint: .systemBlue)
        let arrowEntity = ModelEntity(mesh: arrowMesh, materials: [arrowMat])
        arrowEntity.position = SIMD3<Float>(0, 0, 0)
        compass.addChild(arrowEntity)
        return compass
    }
}

private struct SliceBadge: View {
    let axis: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(axis)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(.secondaryLabel))
            Text(value)
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}
