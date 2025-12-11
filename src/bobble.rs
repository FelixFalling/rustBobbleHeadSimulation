// Physics constants
const SPRING_CONSTANT: f64 = 0.3;
const DAMPING: f64 = 0.92;
const GRAVITY: f64 = 0.2;

/// Represents a single bobble head entity with physics properties.
#[derive(Clone, Debug)]
pub struct BobbleHead {
    /// The resting X position (anchor point).
    pub rest_x: f64,
    /// The resting Y position (anchor point).
    pub rest_y: f64,
    /// Current X position.
    pub x: f64,
    /// Current Y position.
    pub y: f64,
    /// Velocity in X direction.
    pub velocity_x: f64,
    /// Velocity in Y direction.
    pub velocity_y: f64,
    /// Current rotation angle.
    pub rotation: f64,
    /// Angular velocity.
    pub rotation_velocity: f64,
    /// Radius of the head (for collision/rendering).
    pub head_radius: f64,
    /// Color of the bobble head (hex string).
    pub color: String,
    /// Type of bobble head ("ferris", "cat", "player").
    pub bobble_type: String,
}

impl BobbleHead {
    /// Creates a new BobbleHead instance.
    ///
    /// # Arguments
    /// * `x` - Initial X position.
    /// * `y` - Initial Y position.
    /// * `radius` - Radius of the head.
    /// * `color` - Color string.
    /// * `bobble_type` - Type identifier.
    pub fn new(x: f64, y: f64, radius: f64, color: &str, bobble_type: &str) -> Self {
        Self {
            rest_x: x,
            rest_y: y,
            x,
            y,
            velocity_x: 0.0,
            velocity_y: 0.0,
            rotation: 0.0,
            rotation_velocity: 0.0,
            head_radius: radius,
            color: color.to_string(),
            bobble_type: bobble_type.to_string(),
        }
    }

    /// Updates the physics state of the bobble head.
    ///
    /// Applies gravity, spring forces, damping, and collision detection.
    ///
    /// # Arguments
    /// * `delta_time` - Time elapsed since last update in seconds.
    pub fn update(&mut self, delta_time: f64) {
        // Apply gravity
        self.velocity_y += GRAVITY;

        // Apply spring force to return to center
        let dx = self.rest_x - self.x;
        let dy = self.rest_y - self.y;
        self.velocity_x += dx * SPRING_CONSTANT;
        self.velocity_y += dy * SPRING_CONSTANT;

        // Apply damping
        self.velocity_x *= DAMPING;
        self.velocity_y *= DAMPING;
        self.rotation_velocity *= DAMPING * 0.95;

        // Update position
        self.x += self.velocity_x * delta_time * 60.0;
        self.y += self.velocity_y * delta_time * 60.0;

        // Coupled rotation: displacement induces rotation
        // If head moves right (positive x), it tilts left (negative rotation)
        let displacement_x = self.x - self.rest_x;
        self.rotation_velocity -= displacement_x * 0.005;

        // Apply restoring torque to return rotation to 0 (upright)
        self.rotation_velocity += (0.0 - self.rotation) * 0.05;

        self.rotation += self.rotation_velocity * delta_time * 60.0;

        // Platform collision (simple hardcoded floor for now, matching QML default roughly)
        // Platform at ~550 (600 - 30 - 20)
        let platform_y = 550.0;
        if self.y + self.head_radius > platform_y {
            self.y = platform_y - self.head_radius;
            self.velocity_y *= -0.5;
        }
    }

    /// Applies an external force to the bobble head.
    ///
    /// # Arguments
    /// * `force_x` - Force component in X direction.
    /// * `force_y` - Force component in Y direction.
    pub fn apply_force(&mut self, force_x: f64, force_y: f64) {
        self.velocity_x += force_x * 0.5;
        self.velocity_y += force_y * 0.5;
        // Stronger initial rotation kick
        self.rotation_velocity = (force_x * 0.1).clamp(-1.0, 1.0);
    }
}
