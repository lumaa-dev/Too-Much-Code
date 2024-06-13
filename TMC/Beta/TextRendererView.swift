//Made by Lumaa

import SwiftUI

struct TextRendererView: View {
    @State private var isVisible: Bool = true
    
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            VStack {
                GroupBox {
                    Toggle("Visible", isOn: $isVisible.animation())
                }
                
                Spacer()
                
                if isVisible {
                    let rendered = Text("Lumaa")
                        .customAttribute(CustomTextAttribute())
                        .foregroundStyle(Color.blue.gradient)
                        .font(.title2.bold())
                    
                    Text("Hello, \(rendered)!")
                        .font(.title2)
                        .transition(TextTransition())
                }
                
                Spacer()
            }
        } else {
            Text("Unavailable!")
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
struct CustomTextAttribute: TextAttribute {}

@available(iOS 18.0, macOS 15.0, *)
struct CustomTextRenderer: TextRenderer, Animatable {
    
    var elapsedTime: TimeInterval
    var elementDuration: TimeInterval
    var totalDuration: TimeInterval
    var spring: Spring {
        .snappy(duration: elementDuration - 0.05, extraBounce: 0.4)
    }
    
    init(elapsedTime: TimeInterval, elementDuration: Double = 0.4, totalDuration: TimeInterval) {
        self.elapsedTime = min(elapsedTime, totalDuration)
        self.elementDuration = min(elementDuration, totalDuration)
        self.totalDuration = totalDuration
    }
    
    var animatableData: Double {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for run in layout.flattenedRuns {
            if run[CustomTextAttribute.self] != nil {
                let delay = elementDelay(count: run.count)
                
                for (index, slice) in run.enumerated() {
                    // The time that the current element starts animating,
                    // relative to the start of the animation.
                    let timeOffset = TimeInterval(index) * delay
                    
                    // The amount of time that passes for the current element.
                    let elementTime = max(0, min(elapsedTime - timeOffset, elementDuration))
                    
                    // Make a copy of the context so that individual slices
                    // don't affect each other.
                    var copy = context
                    draw(slice, at: elementTime, in: &copy)
                }
            } else {
                // Make a copy of the context so that individual slices
                // don't affect each other.
                var copy = context
                // Runs that don't have a tag of `EmphasisAttribute` quickly
                // fade in.
                copy.opacity = UnitCurve.easeIn.value(at: elapsedTime / 0.2)
                copy.draw(run)
            }
        }
    }
    
    func draw(_ slice: Text.Layout.RunSlice, at time: TimeInterval, in context: inout GraphicsContext) {
        let progress = time / elementDuration
        
        let opacity = UnitCurve.easeIn.value(at: 1.4 * progress)
        
        let blurRadius =
        slice.typographicBounds.rect.height / 16 *
        UnitCurve.easeIn.value(at: 1 - progress)
        
        // The y-translation derives from a spring, which requires a
        // time in seconds.
        let translationY = spring.value(fromValue: -slice.typographicBounds.descent, toValue: 0, initialVelocity: 0, time: time)
        
        context.translateBy(x: 0, y: translationY)
        context.addFilter(.blur(radius: blurRadius))
        context.opacity = opacity
        context.draw(slice, options: .disablesSubpixelQuantization)
    }
    
    func elementDelay(count: Int) -> TimeInterval {
        let count = TimeInterval(count)
        let remainingTime = totalDuration - count * elementDuration
        
        return max(remainingTime / (count + 1), (totalDuration - elementDuration) / count)
    }
}

extension Text.Layout {
    /// A helper function for easier access to all runs in a layout.
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        self.flatMap { line in
            line
        }
    }
    
    /// A helper function for easier access to all run slices in a layout.
    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }
}

@available(iOS 18.0, macOS 15.0, *)
struct TextTransition: Transition {
    static var properties: TransitionProperties {
        TransitionProperties(hasMotion: true)
    }
    
    func body(content: Content, phase: TransitionPhase) -> some View {
        let duration = 0.9
        let elapsedTime = phase.isIdentity ? duration : 0
        let renderer = CustomTextRenderer(
            elapsedTime: elapsedTime,
            totalDuration: duration
        )
        
        content.transaction { transaction in
            // Force the animation of `elapsedTime` to pace linearly and
            // drive per-glyph springs based on its value.
            if !transaction.disablesAnimations {
                transaction.animation = .linear(duration: duration)
            }
        } body: { view in
            view.textRenderer(renderer)
        }
    }
}

#Preview {
    TextRendererView()
}
