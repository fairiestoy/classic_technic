-- Minetest 0.4.5 mod: framedglass

minetest.register_craft({
	output = 'framedglass:wooden_framed_glass 4',
	recipe = {
		{'default:glass', 'default:glass', 'default:stick'},
		{'default:glass', 'default:glass', 'default:stick'},
		{'default:stick', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'framedglass:steel_framed_glass 4',
	recipe = {
		{'default:glass', 'default:glass', 'default:steel_ingot'},
		{'default:glass', 'default:glass', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
	}
})

minetest.register_craft({
	output = 'framedglass:wooden_framed_obsidian_glass 4',
	recipe = {
		{'default:obsidian_glass', 'default:obsidian_glass', 'default:stick'},
		{'default:obsidian_glass', 'default:obsidian_glass', 'default:stick'},
		{'default:stick', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'framedglass:steel_framed_obsidian_glass 4',
	recipe = {
		{'default:obsidian_glass', 'default:obsidian_glass', 'default:steel_ingot'},
		{'default:obsidian_glass', 'default:obsidian_glass', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
	}
})

minetest.register_node("framedglass:wooden_framed_glass", {
	description = "Wooden-framed Glass",
	drawtype = "glasslike_framed",
	tiles = {"framedglass_wooden_frame.png","framedglass_glass_face_streaks.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("framedglass:steel_framed_glass", {
	description = "Steel-framed Glass",
	drawtype = "glasslike_framed",
	tiles = {"framedglass_steel_frame.png","framedglass_glass_face_streaks.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("framedglass:wooden_framed_obsidian_glass", {
	description = "Wooden-framed Obsidian Glass",
	drawtype = "glasslike_framed",
	tiles = {"framedglass_wooden_frame.png","framedglass_glass_face_clean.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("framedglass:steel_framed_obsidian_glass", {
	description = "Steel-framed Obsidian Glass",
	drawtype = "glasslike_framed",
	tiles = {"framedglass_steel_frame.png","framedglass_glass_face_clean.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

function add_coloured_framedglass(name, desc, dye, texture)
	minetest.register_node( "framedglass:steel_framed_obsidian_glass"..name, {
		description = "Steel-framed "..desc.." Obsidian Glass",
		tiles = {"framedglass_steel_frame.png",texture},
		drawtype = "glasslike_framed",
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = true,
		use_texture_alpha = true,
		groups = {cracky=3},
		sounds = default.node_sound_glass_defaults(),
	})

	minetest.register_craft({
		type = "shapeless",
		output = "framedglass:steel_framed_obsidian_glass"..name,
		recipe = {
			"framedglass:steel_framed_glass",
			dye
		}
	})

end
add_coloured_framedglass ("red","Red","dye:red","framedglass_redglass.png")
add_coloured_framedglass ("green","Green","dye:green","framedglass_greenglass.png")
add_coloured_framedglass ("blue","Blue","dye:blue","framedglass_blueglass.png")
add_coloured_framedglass ("cyan","Cyan","dye:cyan","framedglass_cyanglass.png")
add_coloured_framedglass ("darkgreen","Dark Green","dye:dark_green","framedglass_darkgreenglass.png")
add_coloured_framedglass ("violet","Violet","dye:violet","framedglass_violetglass.png")
add_coloured_framedglass ("pink","Pink","dye:pink","framedglass_pinkglass.png")
add_coloured_framedglass ("yellow","Yellow","dye:yellow","framedglass_yellowglass.png")
add_coloured_framedglass ("orange","Orange","dye:orange","framedglass_orangeglass.png")
add_coloured_framedglass ("brown","Brown","dye:brown","framedglass_brownglass.png")
add_coloured_framedglass ("white","White","dye:white","framedglass_whiteglass.png")
add_coloured_framedglass ("grey","Grey","dye:grey","framedglass_greyglass.png")
add_coloured_framedglass ("darkgrey","Dark Grey","dye:dark_grey","framedglass_darkgreyglass.png")
add_coloured_framedglass ("black","Black","dye:black","framedglass_blackglass.png")
