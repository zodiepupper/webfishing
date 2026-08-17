extends Resource
class_name CosmeticResource


var resource_type = "cosmetic"

@export var name = "cos name"
@export var desc = "cos desc"
@export var title = ""
@export var icon: Texture2D
@export var mesh: Mesh
@export var species_alt_mesh = [] # (Array, Mesh)
@export var mesh_skin: Skin
@export var material: Material
@export var secondary_material: Material
@export var third_material: Material
@export var main_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var body_pattern # (Array, Texture2D)
@export var scene_replace: PackedScene

@export var mirror_face = true
@export var flip = false
@export var allow_blink = true
@export var alt_eye: Texture2D
@export var alt_blink: Texture2D

@export var category = "" # (String, "species", "primary_color", "secondary_color", "eye", "nose", "mouth", "hat", "undershirt", "overshirt", "accessory", "bobber", "pattern", "title", "tail", "legs")
@export var cos_internal_id = 0

@export var in_rotation = false
@export var chest_reward = false
@export var cost = 10
