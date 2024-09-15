package gobloop

import "core:fmt"
import "core:math/rand"
import "core:unicode/utf8"
import "core:math/linalg"

import glm "core:math/linalg/glsl"
import rl "vendor:raylib"

// ASSETS
ICON_PNG := #load("assets/icon.png")
TILESET_PNG := #load("assets/tileset.png")
MAIN_MENU_SCREEN_PNG := #load("assets/mainmenu.png")
WIN_SCREEN_PNG := #load("assets/winscreen.png")
GAMEOVER_SCREEN_PNG := #load("assets/gameoverscreen.png")

PIXELATED_TTF := #load("assets/font/pixelated.ttf")
//PIXELATED_CODEPOINTS: [^]rune = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

WALK_WAV := #load("assets/walk.wav")
HURT_WAV := #load("assets/hurt.wav")

// DEFINES
SHOW_DEBUG_INFO :: true

LIGHT_SKY_BLUE := rl.Color{0xdf, 0xf6, 0xf5, 0xff}
DARK_SKY_BLUE := rl.Color{0x39, 0x31, 0x4b, 0xff}
LIME_GREEN := rl.Color{0xb6, 0xd5, 0x3c, 0xff}
DARK_GREY := rl.Color{0x30, 0x2c, 0x2e, 0xff}
HURT_RED := rl.Color{0xe6, 0x48, 0x2e, 0xff}

TILE_SIZE :: 16
CHARACTER_SIZE :: 32

SPRITE_STAR_0 := rl.Rectangle{8 * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE}
SPRITE_STAR_1 := rl.Rectangle{9 * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE}
SPRITE_STAR_2 := rl.Rectangle{10 * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE}

TILE_PINK_0 := rl.Rectangle{0 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_PINK_1 := rl.Rectangle{1 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_PINK_0 := rl.Rectangle{0 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_PINK_1 := rl.Rectangle{1 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_BLUE_0 := rl.Rectangle{2 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_BLUE_1 := rl.Rectangle{3 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_BLUE_0 := rl.Rectangle{2 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_BLUE_1 := rl.Rectangle{3 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_GREEN_0 := rl.Rectangle{4 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_GREEN_1 := rl.Rectangle{5 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_GREEN_0 := rl.Rectangle{4 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_GREEN_1 := rl.Rectangle{5 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_RED_0 := rl.Rectangle{6 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
TILE_RED_1 := rl.Rectangle{7 * TILE_SIZE, 0 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_RED_0 := rl.Rectangle{6 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}
BROKEN_TILE_RED_1 := rl.Rectangle{7 * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, 2 * TILE_SIZE}

COMPUTER_0 := rl.Rectangle{128, 32, TILE_SIZE, TILE_SIZE}
BUBBLE_0 := rl.Rectangle{144, 32, 80, 32}

SPIKE_0 := rl.Rectangle{128, 16, 16, 16}
SPIKE_1 := rl.Rectangle{144, 16, 16, 16}

CHAR_IDLE_0 := rl.Rectangle{0 * CHARACTER_SIZE, 2 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_IDLE_1 := rl.Rectangle{1 * CHARACTER_SIZE, 2 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_MOVE_0 := rl.Rectangle{0 * CHARACTER_SIZE, 3 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_MOVE_1 := rl.Rectangle{1 * CHARACTER_SIZE, 3 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_MOVE_2 := rl.Rectangle{2 * CHARACTER_SIZE, 3 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_MOVE_3 := rl.Rectangle{3 * CHARACTER_SIZE, 3 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_MOVE_4 := rl.Rectangle{4 * CHARACTER_SIZE, 3 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}
CHAR_MOVE_5 := rl.Rectangle{5 * CHARACTER_SIZE, 3 * CHARACTER_SIZE, CHARACTER_SIZE, CHARACTER_SIZE}

OFFSET_FROM_TOP :: 72.0

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

AnimatedSprite :: struct {
	currentIndex: int,
	frameTime: f32,
	time: f32,
	frames: int,
}

Spike :: struct {
	position: rl.Vector2,
	spikeAnim: AnimatedSprite,
}

Fireball :: struct {
	position: rl.Vector2,
	fireAnim: AnimatedSprite,
	start: rl.Vector2,
	end: rl.Vector2,
	backAndForthTime: f32,
}

Level :: struct {
	width: int,
	height: int,
	spikes: [dynamic]Spike,
	fireballs: [dynamic]Fireball,
}

GOBLIN_SPEED :: 96.0

GoblinState :: enum {
	IDLE,
	MOVE,
	HURT,
}

Goblin :: struct {
	size: f32,
	position: rl.Vector2,
	velocity: rl.Vector2,
	state: GoblinState,
	facingRight: bool,
	idleAnim: AnimatedSprite,
	moveAnim: AnimatedSprite,
	hurtTimer: f32,
}

GameData :: struct {
	seed: u64,
	currentScene: Scene,
	camera: rl.Camera2D,
	stars: [32]AnimatedSprite,
	fireAnim: AnimatedSprite,
	currentLevel: int,
	level: Level,
	health: int,
	goblin: Goblin,
}

Assets :: struct {
	tileset: rl.Texture,
	mainMenu: rl.Texture,
	winScreen: rl.Texture,
	gameoverScreen: rl.Texture,
	font: rl.Font,
	texts: map[string]rl.Texture,
	sounds: map[string]rl.Sound,
}

// GLOBAL GAME DATA
window := Window{
	width = 1280,
	height = 720,
	name = "Gobloop",
	flags = {},
	targetFps = 60,
}

game := GameData{
	currentScene = Scene.MAIN_MENU,
	camera = rl.Camera2D{
		offset = rl.Vector2{},
		target = rl.Vector2{},
		zoom = 4.0,
	},
	currentLevel = 0,
	level = {
		width = 22,
		height = 7,
	},
	health = 11,
}

assets := Assets{}

// UTIL FUNCTIONS
load_assets :: proc() {
	// set global seed
	game.seed = rand.uint64()

	// failing to load fonts
	assets.font = rl.LoadFont("res/font/pixelated.ttf");
	//fmt.println("font:")
	//fmt.println("\tbasesize:", assets.font.baseSize)
	//fmt.println("\tglyphCount:", assets.font.glyphCount)
	//fmt.println("\tglyphPadding:", assets.font.glyphPadding)
	//fmt.println("\tglyphPadding:", assets.font.glyphPadding)
	//fmt.printf("\tglyphs: ")
	//for i in 0..<assets.font.glyphCount {
	//	g := assets.font.glyphs[i]
	//	fmt.printf("%c", g.value)
	//}
	//fmt.printf("\n")
	//codepoints: [^]rune = utf8.string_to_runes("!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
	//assets.font = rl.LoadFontFromMemory(".ttf", raw_data(PIXELATED_TTF), i32(len(PIXELATED_TTF)), 10, PIXELATED_CODEPOINTS, 224)

	{
		icon := rl.LoadImageFromMemory(".png", raw_data(ICON_PNG), i32(len(ICON_PNG)))
		rl.SetWindowIcon(icon)
	}

	load_texture :: proc(bytes: []u8) -> rl.Texture {
		image := rl.LoadImageFromMemory(".png", raw_data(bytes), i32(len(bytes)))
		return rl.LoadTextureFromImage(image)
	}

	assets.tileset = load_texture(TILESET_PNG)
	assets.mainMenu = load_texture(MAIN_MENU_SCREEN_PNG)
	assets.winScreen = load_texture(WIN_SCREEN_PNG)
	assets.gameoverScreen = load_texture(GAMEOVER_SCREEN_PNG)

	{
		fontSize: f32 = 10
		mainMenuPlay := rl.ImageText("press [space] to play", i32(fontSize), rl.WHITE)
		assets.texts["main_menu_start"] = rl.LoadTextureFromImage(mainMenuPlay)
		mainMenuExit := rl.ImageText("press [escape] to quit", i32(fontSize), rl.WHITE)
		assets.texts["main_menu_quit"] = rl.LoadTextureFromImage(mainMenuExit)

		backToMenu := rl.ImageText("press [escape] return to main menu", i32(fontSize), rl.WHITE)
		assets.texts["back_to_menu"] = rl.LoadTextureFromImage(backToMenu)

		gameover := rl.ImageText("You could not escape this strange place...", i32(fontSize), rl.WHITE)
		assets.texts["gameover"] = rl.LoadTextureFromImage(gameover)
		win := rl.ImageText("You escaped, well done !", i32(fontSize), rl.WHITE)
		assets.texts["win"] = rl.LoadTextureFromImage(win)
	}

	for i in 0..<len(game.stars) {
		game.stars[i] = AnimatedSprite{
			currentIndex = int(rand.int31() % 3),
			frameTime = 0.250,
			time = rand.float32(),
			frames = 3,
		}
	}

	{
		walkWave := rl.LoadWaveFromMemory(".wav", raw_data(WALK_WAV), i32(len(WALK_WAV)))
		assets.sounds["walk"] = rl.LoadSoundFromWave(walkWave)
		hurtWave := rl.LoadWaveFromMemory(".wav", raw_data(HURT_WAV), i32(len(HURT_WAV)))
		assets.sounds["hurt"] = rl.LoadSoundFromWave(hurtWave)
	}
}

grid_to_world_pos :: proc(x, y: int) -> rl.Vector2 {
	gridSize := rl.Vector2{ f32(TILE_SIZE), f32(TILE_SIZE / 2)}
	out := rl.Vector2{f32(x), f32(y)}
	out = out * gridSize
	offset := rl.Vector2{0, f32(TILE_SIZE / 4)}
	return out + offset
}

// LEVELS
unload_level :: proc() {
	level := &game.level
	clear(&level.spikes)
	clear(&level.fireballs)
}

load_level_1 :: proc() {
	fmt.println("loading level 1")
	level := &game.level
	for x in 4..<12 {
		append(&level.spikes, Spike{ position = grid_to_world_pos(x, 0) })
	}
}

load_level_2 :: proc() {
	fmt.println("loading level 2")
	level := &game.level 
}

// GAME FUNCTIONS
draw_sprite :: proc(sprite: rl.Rectangle, pos: rl.Vector2, tint: rl.Color = rl.WHITE) {
	offset := rl.Vector2{ sprite.width / 2.0, sprite.height / 2.0 }
	rl.DrawTextureRec(assets.tileset, sprite, pos - offset, tint)
}

update_animated_sprite :: proc(anim: ^AnimatedSprite, dt: f32) -> int {
	dt := rl.GetFrameTime()
	anim.time += dt

	if anim.time > anim.frameTime {
		anim.time -= anim.frameTime
		anim.currentIndex += 1
	}

	if anim.currentIndex >= anim.frames {
		anim.currentIndex = 0
	}

	return anim.currentIndex
}

draw_background_stars :: proc(dt: f32) {
	rand.reset(game.seed)
	width: f32 = f32(window.width) / game.camera.zoom
	height: f32 = f32(window.height) / game.camera.zoom
	for &star in game.stars {
		x: f32 = linalg.floor(rand.float32() * width)
		y: f32 = linalg.floor(rand.float32() * height)
		pos := rl.Vector2{x, y}
		i := update_animated_sprite(&star, dt)
		switch i {
			case 0: draw_sprite(SPRITE_STAR_0, pos)
			case 1: draw_sprite(SPRITE_STAR_1, pos)
			case 2: draw_sprite(SPRITE_STAR_2, pos)
			case: draw_sprite(SPRITE_STAR_0, pos)
		}
	}
}

init_game :: proc() {
	game.currentLevel = 0
	game.health = 11
	game.goblin = Goblin {
		size = 5.0,
		position = grid_to_world_pos(3, 3),
		state = GoblinState.IDLE,
		facingRight = true,
		idleAnim = AnimatedSprite{
			currentIndex = 0,
			frameTime = 0.250,
			frames = 2,
		},
		moveAnim = AnimatedSprite{
			currentIndex = 0,
			frameTime = 0.100,
			frames = 6,
		},
		hurtTimer = 0.0,
	}
	unload_level()
}

next_level :: proc() {
	game.currentLevel += 1
	unload_level()
	switch game.currentLevel {
		case 1: load_level_1()
		case: load_level_2()
	}
}

reset_animation :: proc(anim: ^AnimatedSprite) {
	anim.currentIndex = 0
	anim.time = 0
}

goblin_is_touched :: proc(goblin: ^Goblin) -> (bool, rl.Vector2) {
	level := game.level
	for spike in level.spikes {
		distance := linalg.distance(goblin.position, spike.position)
		if distance < goblin.size {
			return true, goblin.position - spike.position
		}
	}
	return false, rl.Vector2{}
}

goblin_hurt :: proc(goblin: ^Goblin, direction: rl.Vector2) {
	goblin.state = .HURT
	hurtSound := assets.sounds["hurt"]
	rl.PlaySound(hurtSound)
	goblin.position += 2 * direction
	game.health -= 1
}

goblin_input :: proc(dt: f32, goblin: ^Goblin) {
	dir := rl.Vector2{}

	if rl.IsKeyDown(rl.KeyboardKey.W) { dir.y -= 1 }
	if rl.IsKeyDown(rl.KeyboardKey.S) { dir.y += 1 }
	if rl.IsKeyDown(rl.KeyboardKey.A) { dir.x -= 1 }
	if rl.IsKeyDown(rl.KeyboardKey.D) { dir.x += 1 }

	if dir.x != 0 || dir.y != 0 {
		dir = linalg.normalize(dir)
	}

	// TODO: keep ?
	speed := GOBLIN_SPEED + f32(game.currentLevel) * 8
	goblin.velocity = dir * speed * dt

	goblin.position += goblin.velocity
}

do_goblin_idle :: proc(dt: f32, goblin: ^Goblin) {
	goblin_input(dt, goblin)

	isTouched, dir := goblin_is_touched(goblin)
	if isTouched {
		goblin_hurt(goblin, dir)
		return
	}

	if goblin.velocity.x != 0 || goblin.velocity.y != 0 {
		reset_animation(&goblin.moveAnim)
		reset_animation(&goblin.idleAnim)
		goblin.state = .MOVE
	}
}

do_goblin_move :: proc(dt: f32, goblin: ^Goblin) {
	goblin_input(dt, goblin)

	walkSound := assets.sounds["walk"]
	isTouched, dir := goblin_is_touched(goblin)
	if isTouched {
		if rl.IsSoundPlaying(walkSound) {
			rl.StopSound(walkSound)
		}
		goblin_hurt(goblin, dir)
		return
	}

	if !rl.IsSoundPlaying(walkSound) {
		rl.PlaySound(walkSound)
	}

	if goblin.velocity.x == 0 && goblin.velocity.y == 0 {
		reset_animation(&goblin.moveAnim)
		reset_animation(&goblin.idleAnim)
		if rl.IsSoundPlaying(walkSound) {
			rl.StopSound(walkSound)
		}
		goblin.state = .IDLE
	}
}

do_goblin_hurt :: proc(dt: f32, goblin: ^Goblin) {
	if goblin.hurtTimer > 0.3 {
		goblin.hurtTimer = 0
		goblin.state = .IDLE
	} else {
		goblin.hurtTimer += dt
	}
}

update_goblin :: proc(dt: f32) {
	goblin := &game.goblin

	// position constraint
	rightMost := f32(window.width / 4.0)
	if goblin.position.x + goblin.size > rightMost {
		goblin.position.x -= rightMost
		next_level()
	} else if goblin.position.x < 0 {
		goblin.position.x = 0
	}

	bottomMost := f32(game.level.height * TILE_SIZE) / 2.0 - goblin.size
	if goblin.position.y < goblin.size {
		goblin.position.y = goblin.size
	} else if goblin.position.y > bottomMost {
		goblin.position.y = bottomMost
	}	

	// facing direction
	if goblin.velocity.x > 0 {
		goblin.facingRight = true
	} else if goblin.velocity.x < 0 {
		goblin.facingRight = false
	}

	// state specific stuff
	switch goblin.state {
		case .IDLE: do_goblin_idle(dt, goblin)
		case .MOVE: do_goblin_move(dt, goblin)
		case .HURT: do_goblin_hurt(dt, goblin)
	}
}

draw_goblin :: proc(dt: f32, goblin: ^Goblin) {
	pos := goblin.position
	pos += rl.Vector2{ 0, OFFSET_FROM_TOP }
	offset := rl.Vector2{-1, -TILE_SIZE + 2}
	
	sprite := SPRITE_STAR_0
	tint := rl.WHITE

	if goblin.state == .IDLE {
		i := update_animated_sprite(&goblin.idleAnim, dt)
		switch i {
			case 0: sprite = CHAR_IDLE_0
			case 1: sprite = CHAR_IDLE_1
			case: sprite = SPRITE_STAR_0
		}
	} else if goblin.state == .MOVE {
		i := update_animated_sprite(&goblin.moveAnim, dt)
		switch i {
			case 0: sprite = CHAR_MOVE_0
			case 1: sprite = CHAR_MOVE_1
			case 2: sprite = CHAR_MOVE_2
			case 3: sprite = CHAR_MOVE_3
			case 4: sprite = CHAR_MOVE_4
			case 5: sprite = CHAR_MOVE_5
			case: sprite = SPRITE_STAR_0
		}
	} else if goblin.state == .HURT {
		sprite = CHAR_MOVE_3
		tint = rl.RED
	}

	if !goblin.facingRight {
		sprite.width = -sprite.width
		offset.x += sprite.width + 2
	}

	draw_sprite(sprite, pos + offset, tint)
	dopplergangerOffset := rl.Vector2{ f32(window.width) / game.camera.zoom, 0}
	draw_sprite(sprite, pos + offset - dopplergangerOffset, tint)
	draw_sprite(sprite, pos + offset + dopplergangerOffset, tint)
	if SHOW_DEBUG_INFO {
		rl.DrawPixel(i32(pos.x), i32(pos.y), rl.RED)
		rl.DrawPixel(i32(pos.x - goblin.size), i32(pos.y), rl.ORANGE)
		rl.DrawPixel(i32(pos.x + goblin.size), i32(pos.y), rl.ORANGE)
		rl.DrawPixel(i32(pos.x), i32(pos.y - goblin.size), rl.ORANGE)
		rl.DrawPixel(i32(pos.x), i32(pos.y + goblin.size), rl.ORANGE)
	}
}

draw_computer :: proc(pos: rl.Vector2) {
	draw_sprite(COMPUTER_0 , pos)
	rl.DrawText(fmt.caprintf("%i", game.currentLevel), 142, 59, 0, rl.WHITE)
	bubbleOffset := rl.Vector2{20, -20}
	draw_sprite(BUBBLE_0 , pos + bubbleOffset)
	textPos := pos + rl.Vector2{-10, -28}
	rl.DrawText("overflow me", i32(textPos.x), i32(textPos.y), 0, LIGHT_SKY_BLUE)
	rl.DrawText("overflow me", i32(textPos.x + 1), i32(textPos.y + 1), 0, DARK_SKY_BLUE)
}

// SCENES FUNCTIONS
do_main_menu :: proc(dt: f32) {
	rl.SetExitKey(rl.KeyboardKey.ESCAPE)

	rl.BeginDrawing()
	rl.ClearBackground(DARK_SKY_BLUE)

	rl.BeginMode2D(game.camera)
	// stars
	draw_background_stars(dt)

	// background
	rl.DrawTexture(assets.mainMenu, 0, 0, rl.WHITE)

	// text
	offset: i32 = 32
	spacing: i32 = 12
	{
		textTexture := assets.texts["main_menu_start"]
		x := i32(f32(window.width) / (2.0 * game.camera.zoom) - f32(textTexture.width) / 2.0)
		y := i32(f32(window.height) / (2.0 * game.camera.zoom) - f32(textTexture.height) / 2.0)
		rl.DrawTexture(textTexture, x + 1, y + offset + 1, DARK_GREY)
		rl.DrawTexture(textTexture, x, y + offset, LIME_GREEN)
		offset += spacing
	}
	{
		textTexture := assets.texts["main_menu_quit"]
		x := i32(f32(window.width) / (2.0 * game.camera.zoom) - f32(textTexture.width) / 2.0)
		y := i32(f32(window.height) / (2.0 * game.camera.zoom) - f32(textTexture.height) / 2.0)
		rl.DrawTexture(textTexture, x + 1, y + offset + 1, DARK_GREY)
		rl.DrawTexture(textTexture, x, y + offset, LIME_GREEN)
		offset += spacing
	}

	rl.EndMode2D()

	rl.EndDrawing()

	spaceOrEnter := rl.IsKeyPressed(rl.KeyboardKey.SPACE) || rl.IsKeyPressed(rl.KeyboardKey.ENTER)
	if spaceOrEnter {
		game.currentScene = .GAME
		init_game()
	}
}

do_game_scene :: proc(dt: f32) {
	rl.SetExitKey(nil)

	rl.BeginDrawing()
	rl.ClearBackground(DARK_SKY_BLUE)

	rl.BeginMode2D(game.camera)
	// stars
	draw_background_stars(dt)

	for x in 0..<game.level.width {
		for y in 0..<game.level.height {
			halfHeight: f32 = TILE_SIZE / 2.0
			pos := rl.Vector2{f32(x * TILE_SIZE), f32(y) * halfHeight}
			pos.y += halfHeight
			pos.y += OFFSET_FROM_TOP

			i := int(x + y * game.level.height) % 8
			broken := int(x + y * game.level.width) / 14 >= game.health

			sprite := SPRITE_STAR_0
			if (i + y) % 2 == 0 {
				switch i {
					case 1: sprite = broken ? BROKEN_TILE_PINK_0 : TILE_PINK_0
					case 0: sprite = broken ? BROKEN_TILE_PINK_1 : TILE_PINK_1
					case 3: sprite = broken ? BROKEN_TILE_BLUE_0 : TILE_BLUE_0
					case 2: sprite = broken ? BROKEN_TILE_BLUE_1 : TILE_BLUE_1
					case 5: sprite = broken ? BROKEN_TILE_GREEN_0 : TILE_GREEN_0
					case 4: sprite = broken ? BROKEN_TILE_GREEN_1 : TILE_GREEN_1
					case 7: sprite = broken ? BROKEN_TILE_RED_0 : TILE_RED_0
					case 6: sprite = broken ? BROKEN_TILE_RED_1 : TILE_RED_1
					case: sprite = SPRITE_STAR_0
				}
			} else {
				switch i {
					case 0: sprite = broken ? BROKEN_TILE_PINK_0 : TILE_PINK_0
					case 1: sprite = broken ? BROKEN_TILE_PINK_1 : TILE_PINK_1
					case 2: sprite = broken ? BROKEN_TILE_BLUE_0 : TILE_BLUE_0
					case 3: sprite = broken ? BROKEN_TILE_BLUE_1 : TILE_BLUE_1
					case 4: sprite = broken ? BROKEN_TILE_GREEN_0 : TILE_GREEN_0
					case 5: sprite = broken ? BROKEN_TILE_GREEN_1 : TILE_GREEN_1
					case 6: sprite = broken ? BROKEN_TILE_RED_0 : TILE_RED_0
					case 7: sprite = broken ? BROKEN_TILE_RED_1 : TILE_RED_1
					case: sprite = SPRITE_STAR_0
				}
			}
			draw_sprite(sprite, pos)
		}	
	}

	// "computer"
	draw_computer(rl.Vector2{145, 64})

	// "entities" drawing
	{
		level := game.level
		for spike in level.spikes {
			pos := spike.position
			pos += rl.Vector2{ 0, OFFSET_FROM_TOP }
			offset := rl.Vector2{ 0, -4 }
			draw_sprite(SPIKE_0, pos + offset)
			rl.DrawPixel(i32(pos.x), i32(pos.y), rl.RED)
		}

		draw_goblin(dt, &game.goblin)
	}

	if SHOW_DEBUG_INFO {
		rl.DrawText(fmt.caprintf("current health: %i", game.health), 8, 0, 0, rl.LIME)
		rl.DrawText(fmt.caprintf("current level: %i", game.currentLevel), 8, 8, 0, rl.LIME)
		rl.DrawText(fmt.caprintf("position: %f:%f", game.goblin.position.x, game.goblin.position.y), 8, 16, 0, rl.LIME)
		rl.DrawText(fmt.caprintf("spikes: %i", len(game.level.spikes)), 8, 24, 0, rl.LIME)
	}

	rl.EndMode2D()

	rl.EndDrawing()

	if SHOW_DEBUG_INFO {
		if rl.IsKeyPressed(rl.KeyboardKey.J) || rl.IsKeyPressedRepeat(rl.KeyboardKey.J) { game.health -= 1 }
		if rl.IsKeyPressed(rl.KeyboardKey.K) || rl.IsKeyPressedRepeat(rl.KeyboardKey.K) { game.health += 1 }
		if rl.IsKeyPressed(rl.KeyboardKey.U) || rl.IsKeyPressedRepeat(rl.KeyboardKey.U) { game.currentLevel -= 1 }
		if rl.IsKeyPressed(rl.KeyboardKey.I) || rl.IsKeyPressedRepeat(rl.KeyboardKey.I) { game.currentLevel += 1 }
	}

	// goblin update
	update_goblin(dt)

	if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
		game.currentScene = .MAIN_MENU
	}

	// check for win / lose conditions
	if game.health < 0 {
		game.currentScene = .GAMEOVER
	} else if game.currentLevel > 9 {
		game.currentScene = .WIN
	}
}

do_gameover_scene :: proc(dt: f32) {
	rl.BeginDrawing()
	rl.ClearBackground(DARK_SKY_BLUE)

	rl.BeginMode2D(game.camera)

	// background
	rl.DrawTexture(assets.gameoverScreen, 0, 0, rl.WHITE)

	// text
	offset: i32 = -50
	spacing: i32 = 12
	{
		textTexture := assets.texts["gameover"]
		x := i32(f32(window.width) / (2.0 * game.camera.zoom) - f32(textTexture.width) / 2.0)
		y := i32(f32(window.height) / (2.0 * game.camera.zoom) - f32(textTexture.height) / 2.0)
		rl.DrawTexture(textTexture, x + 1, y + offset + 1, DARK_GREY)
		rl.DrawTexture(textTexture, x, y + offset, LIME_GREEN)
		offset += spacing
	}
	{
		textTexture := assets.texts["back_to_menu"]
		x := i32(f32(window.width) / (2.0 * game.camera.zoom) - f32(textTexture.width) / 2.0)
		y := i32(f32(window.height) / (2.0 * game.camera.zoom) - f32(textTexture.height) / 2.0)
		rl.DrawTexture(textTexture, x + 1, y + offset + 1, DARK_GREY)
		rl.DrawTexture(textTexture, x, y + offset, LIME_GREEN)
		offset += spacing
	}
	rl.EndMode2D()

	rl.EndDrawing()

	if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
		game.currentScene = .MAIN_MENU
	}
}

do_win_scene :: proc(dt: f32) {
	rl.BeginDrawing()
	rl.ClearBackground(LIGHT_SKY_BLUE)

	rl.BeginMode2D(game.camera)

	// background
	rl.DrawTexture(assets.winScreen, 0, 0, rl.WHITE)

	// text
	offset: i32 = 50
	spacing: i32 = 12
	{
		textTexture := assets.texts["win"]
		x := i32(f32(window.width) / (2.0 * game.camera.zoom) - f32(textTexture.width) / 2.0)
		y := i32(f32(window.height) / (2.0 * game.camera.zoom) - f32(textTexture.height) / 2.0)
		rl.DrawTexture(textTexture, x + 1, y + offset + 1, DARK_GREY)
		rl.DrawTexture(textTexture, x, y + offset, LIME_GREEN)
		offset += spacing
	}
	{
		textTexture := assets.texts["back_to_menu"]
		x := i32(f32(window.width) / (2.0 * game.camera.zoom) - f32(textTexture.width) / 2.0)
		y := i32(f32(window.height) / (2.0 * game.camera.zoom) - f32(textTexture.height) / 2.0)
		rl.DrawTexture(textTexture, x + 1, y + offset + 1, DARK_GREY)
		rl.DrawTexture(textTexture, x, y + offset, LIME_GREEN)
		offset += spacing
	}
	rl.EndMode2D()

	rl.EndDrawing()

	if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
		game.currentScene = .MAIN_MENU
	}
}

main :: proc() {
	rl.SetTraceLogLevel(rl.TraceLogLevel.ERROR)

	rl.InitWindow(window.width, window.height, window.name)
	defer rl.CloseWindow()
	rl.SetWindowState(window.flags)
	rl.SetTargetFPS(window.targetFps)

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	load_assets()

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		switch game.currentScene {
			case .MAIN_MENU: do_main_menu(dt)
			case .GAME: do_game_scene(dt)
			case .GAMEOVER: do_gameover_scene(dt)
			case .WIN: do_win_scene(dt)
		}
	}
}
