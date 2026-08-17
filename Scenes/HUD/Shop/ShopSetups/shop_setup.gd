extends Node

enum REFRESH_TYPES{none, cosmetic, quest}

@export var shop_title = "shop"
@export var refresh_type: REFRESH_TYPES = REFRESH_TYPES.none

@export var dialogue = false
@export var dialogue_open # (Array, String)
@export var dialogue_buy # (Array, String)
@export var dialogue_voice: AudioStream
