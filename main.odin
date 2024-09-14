package gobloop

import "core:fmt"

import glm "core:math/linalg/glsl"
import rl "vendor:raylib"

// ASSETS
TILESET_PNG := #load("assets/tileset.png")
MAIN_MENU_SCREEN_PNG := #load("assets/mainmenu.png")
WIN_SCREEN_PNG := #load("assets/winscreen.png")
GAMEOVER_SCREEN_PNG := #load("assets/gameoverscreen.png")

// DEFINES
LIGHT_SKY_BLUE := rl.Color{0xdf, 0xf6, 0xf5, 0xff}
DARK_SKY_BLUE := rl.Color{0x39, 0x31, 0x4b, 0xff}

Scene :: enum {
	MAIN_MENU,
	GAME,
	GAMEOVER,
	WIN,
}

// STRUCTS
Window :: struct {
	width:     i32,
	height:    i32,
	name:      cstring,
	flags:     rl.ConfigFlags,
	targetFps: i32,
}

GameData :: struct {
	currentScene: Scene,
	camera: rl.Camera2D,
	level: int,
}

// GLOBAL GAME DATA
window := Window {
	width = 1280,
	height = 720,
	name = "Gobloop",
	flags = {},
	targetFps = 60,
}

game := GameData {
	currentScene = Scene.MAIN_MENU,
	camera = rl.Camera2D{
		offset = rl.Vector2{},
		target = rl.Vector2{},
		zoom = 3.0,
	},
}

// UTIL FUNCTIONS
load_assets :: proc() {}

// GAME FUNCTIONS

// SCENES FUNCTIONS
do_main_menu :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(game.camera)
	rl.EndMode2D()

	rl.EndDrawing()
}

do_game_scene :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(DARK_SKY_BLUE)

	rl.BeginMode2D(game.camera)
	rl.EndMode2D()

	rl.EndDrawing()
}

do_gameover_scene :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(game.camera)
	rl.EndMode2D()

	rl.EndDrawing()
}

do_win_scene :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(game.camera)
	rl.EndMode2D()

	rl.EndDrawing()
}

main :: proc() {
	rl.SetTraceLogLevel(rl.TraceLogLevel.ERROR)

	rl.InitWindow(window.width, window.height, window.name)
	rl.SetWindowState(window.flags)
	rl.SetTargetFPS(window.targetFps)

	load_assets()

	for !rl.WindowShouldClose() {
		switch game.currentScene {
			case .MAIN_MENU: do_main_menu()
			case .GAME: do_game_scene()
			case .GAMEOVER: do_gameover_scene()
			case .WIN: do_win_scene()
		}
	}
}
