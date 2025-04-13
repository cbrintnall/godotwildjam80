extends Node
class_name Springs

static func spring(pos, target, velocity, delta: float, stiffness: float, damping: float) -> Dictionary:
    var displacement = pos - target  # Calculate displacement from equilibrium
    var acceleration = (-stiffness * displacement) - (damping * velocity)  # Hooke's Law + damping
    var new_velocity = velocity + acceleration * delta  # Integrate acceleration
    var new_position = pos + new_velocity * delta  # Integrate velocity

    return { "position": new_position, "velocity": new_velocity }
