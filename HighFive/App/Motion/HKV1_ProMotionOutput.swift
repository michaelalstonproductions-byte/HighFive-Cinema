import CoreGraphics

struct HKV1_ProMotionOutput {
    let tiltDx: CGFloat
    let tiltDy: CGFloat
    let peekDx: CGFloat
    let peekDy: CGFloat
    let dx: CGFloat
    let dy: CGFloat
    let maxDx: CGFloat
    let maxDy: CGFloat
    let stability: CGFloat

    init(
        tiltDx: CGFloat,
        tiltDy: CGFloat,
        peekDx: CGFloat,
        peekDy: CGFloat,
        maxDx: CGFloat,
        maxDy: CGFloat,
        stability: CGFloat = 1.0
    ) {
        self.tiltDx = tiltDx
        self.tiltDy = tiltDy
        self.peekDx = peekDx
        self.peekDy = peekDy
        self.dx = tiltDx + peekDx
        self.dy = tiltDy + peekDy
        self.maxDx = maxDx
        self.maxDy = maxDy
        self.stability = stability
    }
}
