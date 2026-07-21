extends Node

enum REFRESH_TYPES{none, cosmetic, quest}

export var shop_title = "shop"
export (REFRESH_TYPES) var refresh_type = REFRESH_TYPES.none

export var dialogue = false
export (Array, String) var dialogue_open
export (Array, String) var dialogue_buy
export (AudioStream) var dialogue_voice
