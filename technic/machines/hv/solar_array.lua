-- The high voltage solar array is an assembly of medium voltage arrays.
-- The assembly can deliver high voltage levels and is a 20% less efficient
-- compared to 5 individual medium voltage arrays due to losses in the transformer.
-- However high voltage is supplied.
-- Solar arrays are not able to store large amounts of energy.
minetest.register_node("technic:solar_array_hv", {
	tiles = {"technic_hv_solar_array_top.png", "technic_hv_solar_array_bottom.png", "technic_hv_solar_array_side.png",
		 "technic_hv_solar_array_side.png", "technic_hv_solar_array_side.png", "technic_hv_solar_array_side.png"},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
    	description="HV Solar Array",
	active = false,
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = true,	
	node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_float("technic_hv_power_machine", 1)
		meta:set_int("HV_EU_supply", 0)
		meta:set_string("infotext", "HV Solar Array")
	end,
})

minetest.register_craft(
   {output = 'technic:solar_array_hv 1',
    recipe = {
       {'technic:solar_array_mv', 'technic:solar_array_mv','technic:solar_array_mv'},
       {'technic:solar_array_mv', 'technic:hv_transformer','technic:solar_array_mv'},
       {'default:steel_ingot',    'technic:hv_cable',      'default:steel_ingot'},
    }
 })

minetest.register_abm(
   {nodenames = {"technic:solar_array_hv"},
    interval   = 1,
    chance     = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
		-- The action here is to make the solar array produce power
		-- Power is dependent on the light level and the height above ground
		-- 130m and above is optimal as it would be above cloud level.
                -- Height gives 1/4 of the effect, light 3/4. Max. effect is 2880EU for the array.
                -- There are many ways to cheat by using other light sources like lamps.
                -- As there is no way to determine if light is sunlight that is just a shame.
                -- To take care of some of it solar panels do not work outside daylight hours or if
                -- built below -10m
		local pos1={}
		pos1.y=pos.y+1
		pos1.x=pos.x
		pos1.z=pos.z
		local light = minetest.env:get_node_light(pos1, nil)
		local time_of_day = minetest.env:get_timeofday()
		local meta = minetest.env:get_meta(pos)
		if light == nil then light = 0 end
		-- turn on array only during day time and if sufficient light
                -- I know this is counter intuitive when cheating by using other light sources.
		if light >= 12 and time_of_day>=0.24 and time_of_day<=0.76 and pos.y > -10 then
		   local charge_to_give          = math.floor(light*(light*9.6+pos1.y/130*48))
		   if charge_to_give<0   then charge_to_give=0 end
		   if charge_to_give>2880 then charge_to_give=2880 end
		   meta:set_string("infotext", "Solar Array is active ("..charge_to_give.."EU)")
		   meta:set_int("HV_EU_supply", charge_to_give)
		else
		   meta:set_string("infotext", "Solar Array is inactive");
		   meta:set_int("HV_EU_supply", 0)
		end
	     end,
 }) 

technic.register_HV_machine ("technic:solar_array_hv","PR")

