-- default GUI page
stargate.default_page = "main"
stargate_network["players"]={}
stargate.current_page={}

stargate.save_data = function(table_pointer)
	local data = minetest.serialize( stargate_network[table_pointer] )
	local path = minetest.get_worldpath().."/stargate_"..table_pointer..".data"
	local file = io.open( path, "w" )
	if( file ) then
		file:write( data )
		file:close()
		return true
	else return nil
	end
end

stargate.restore_data = function(table_pointer)
	local path = minetest.get_worldpath().."/stargate_"..table_pointer..".data"
	local file = io.open( path, "r" )
	if( file ) then
		local data = file:read("*all")
		stargate_network[table_pointer] = minetest.deserialize( data )
		file:close()
	return true
	else return nil
	end
end

-- load Stargates network data
if stargate.restore_data("registered_players") ~= nil then
	for __,tab in ipairs(stargate_network["registered_players"]) do
		if stargate.restore_data(tab["player_name"]) == nil  then
			print ("[stargate] Error loading data!")
		end
	end
else
	print ("[stargate] Error loading data! Creating new file.")
	stargate_network["registered_players"]={}
	stargate.save_data("registered_players")
end

-- register_on_joinplayer
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local registered=nil
	for __,tab in ipairs(stargate_network["registered_players"]) do
		if tab["player_name"] ==  player_name then registered = true break end
	end
	if registered == nil then
		local new={}
		new["player_name"]=player_name
		table.insert(stargate_network["registered_players"],new)
		stargate.save_data("registered_players")
		stargate.save_data(player_name)
	end
	stargate_network["players"][player_name]={}
	stargate_network["players"][player_name]["formspec"]=""
	stargate_network["players"][player_name]["current_page"]=stargate.default_page
	stargate_network["players"][player_name]["own_gates"]={}
	stargate_network["players"][player_name]["own_gates_count"]=0
	stargate_network["players"][player_name]["public_gates"]={}
	stargate_network["players"][player_name]["public_gates_count"]=0
	stargate_network["players"][player_name]["current_index"]=0
end)

stargate.registerGate = function(player_name,pos)
	if stargate_network[player_name]==nil then
		stargate_network[player_name]={}
	end
	local new_gate ={}
	new_gate["pos"]=pos
	new_gate["type"]="private"
	new_gate["description"]=""
	table.insert(stargate_network[player_name],new_gate)
	if stargate.save_data(player_name)==nil then
		print ("[stargate] Couldnt update network file!")
	end
end

stargate.unregisterGate = function(player_name,pos)
	for __,gates in ipairs(stargate_network[player_name]) do
		if gates["pos"].x==pos.x and gates["pos"].y==pos.y and gates["pos"].z==pos.z then
			table.remove(stargate_network[player_name], __)
			break
		end
	end
	if stargate.save_data(player_name)==nil then
		print ("[stargate] Couldnt update network file!")
	end
end

--show formspec to player
stargate.gateFormspecHandler = function(pos, node, clicker, itemstack)
	local player_name = clicker:get_player_name()
	local meta = minetest.env:get_meta(pos)
	local owner=meta:get_string("owner")
	if player_name~=owner then return end
	local current_gate=nil
	stargate_network["players"][player_name]["own_gates"]={}
	stargate_network["players"][player_name]["public_gates"]={}
	local own_gates_count=0
	for __,gates in ipairs(stargate_network[player_name]) do
		if gates["pos"].x==pos.x and gates["pos"].y==pos.y and gates["pos"].z==pos.z then
			current_gate=gates
		else
		own_gates_count=own_gates_count+1
		table.insert(stargate_network["players"][player_name]["own_gates"],gates)
		end
	end
	stargate_network["players"][player_name]["own_gates_count"]=own_gates_count
	if current_gate==nil then 
		print ("Gate not registered in network! Please remove it and place once again.")
		return nil
	end
	stargate_network["players"][player_name]["current_index"]=0
	stargate_network["players"][player_name]["current_gate"]=current_gate
	stargate_network["players"][player_name]["dest_type"]="own"
	local formspec=stargate.get_formspec(player_name,"main")
	stargate_network["players"][player_name]["formspec"]=formspec
	if formspec ~=nil then minetest.show_formspec(player_name, "stargate_main", formspec) end
end

-- get_formspec
stargate.get_formspec = function(player_name,page)
	if player_name==nil then return nil end
	stargate_network["players"][player_name]["current_page"]=page
	local current_gate=stargate_network["players"][player_name]["current_gate"]
	local formspec = "size[14,10]"
	--background
	formspec = formspec .."background[-0.19,-0.2,;14.38,10.55;ui_form_bg.png]"
	formspec = formspec.."label[0,0.0;Stargate]"
	formspec = formspec.."label[0,.5;Position: ("..current_gate["pos"].x..","..current_gate["pos"].y..","..current_gate["pos"].z..")]"
	formspec = formspec.."image_button[3.5,.6;.6,.6;toggle_icon.png;toggle_type;]"
	formspec = formspec.."label[4,.5;Type: "..current_gate["type"].."]"
	formspec = formspec.."image_button[6.5,.6;.6,.6;pencil_icon.png;edit_desc;]"
	formspec = formspec.."label[0,1.1;Destination: ]"
	formspec = formspec.."label[0,1.7;Aviable destinations:]"
	formspec = formspec.."image_button[3.5,1.8;.6,.6;toggle_icon.png;toggle_dest_type;]"
	formspec = formspec.."label[4,1.7;Filter: "..stargate_network["players"][player_name]["dest_type"].."]"

	if page=="main" then
	formspec = formspec.."image_button[6.5,.6;.6,.6;pencil_icon.png;edit_desc;]"
	formspec = formspec.."label[7,.5;Description: "..current_gate["description"].."]"
	end
	if page=="edit_desc" then
	formspec = formspec.."image_button[6.5,.6;.6,.6;ok_icon.png;save_desc;]"
	formspec = formspec.."field[7.3,.7;5,1;desc_box;Edit gate description:;"..current_gate["description"].."]"
	end
	
	local list_index=stargate_network["players"][player_name]["current_index"]
	local page=math.floor(list_index / 24 + 1)
	local pagemax = math.floor((stargate_network["players"][player_name]["own_gates_count"] / 24) + 1)
	local x,y
	for y=0,7,1 do
	for x=0,2,1 do
		local gate_temp=stargate_network["players"][player_name]["own_gates"][list_index+1]
		if gate_temp then
			formspec = formspec.."image_button["..(x*4.5)..","..(2.5+y*.9)..";.6,.6;stargate_icon.png;list_button"..list_index..";]"
			formspec = formspec.."label["..(x*4.5+.5)..","..(2.3+y*.9)..";("..gate_temp["pos"].x..","..gate_temp["pos"].y..","..gate_temp["pos"].z..") "..gate_temp["type"].."]"
			formspec = formspec.."label["..(x*4.5+.5)..","..(2.7+y*.9)..";"..gate_temp["description"].."]"
		end
		print(dump(list_index))
		list_index=list_index+1
	end
	end
	formspec = formspec.."image_button[6.5,1.8;.6,.6;left_icon.png;page_left;]"
	formspec = formspec.."image_button[6.9,1.8;.6,.6;right_icon.png;page_right;]"
	formspec=formspec.."label[7.5,1.7;Page: "..page.." of "..pagemax.."]"
	return formspec
end

-- register_on_player_receive_fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname == "stargate_main" then return "" end
	local player_name = player:get_player_name()
	local current_gate=stargate_network["players"][player_name]["current_gate"]
	local formspec

	if fields.toggle_type then
		if current_gate["type"] == "private" then 
			current_gate["type"] = "public"
		else current_gate["type"] = "private" end
		formspec= stargate.get_formspec(player_name,"main")
		stargate_network["players"][player_name]["formspec"] = formspec
		minetest.show_formspec(player_name, "stargate_main", formspec)
		minetest.sound_play("click", {to_player=player_name, gain = 0.5})
		return
	end
	if fields.toggle_dest_type then
		if stargate_network["players"][player_name]["dest_type"] == "all own" then 
			stargate_network["players"][player_name]["dest_type"] = "all public"
		else stargate_network["players"][player_name]["dest_type"] = "all own" end
		stargate_network["players"][player_name]["current_index"] = 0
		formspec = stargate.get_formspec(player_name,"main")
		stargate_network["players"][player_name]["formspec"] = formspec
		minetest.show_formspec(player_name, "stargate_main", formspec)
		minetest.sound_play("click", {to_player=player_name, gain = 0.5})
		return
	end
	if fields.edit_desc then
		formspec= stargate.get_formspec(player_name,"edit_desc")
		stargate_network["players"][player_name]["formspec"]=formspec
		minetest.show_formspec(player_name, "stargate_main", formspec)
		minetest.sound_play("click", {to_player=player_name, gain = 0.5})
		return
	end

	if fields.save_desc then
		current_gate["description"]=fields.desc_box
		formspec= stargate.get_formspec(player_name,"main")
		stargate_network["players"][player_name]["formspec"]=formspec
		minetest.show_formspec(player_name, "stargate_main", formspec)
		minetest.sound_play("click", {to_player=player_name, gain = 0.5})
		return
	end
	
	-- page controls
	local start=math.floor(stargate_network["players"][player_name]["current_index"]/24 +1 )
	local start_i=start
	local pagemax = math.floor(((stargate_network["players"][player_name]["own_gates_count"]-1) / 24) + 1)
	
	if fields.page_left then
		minetest.sound_play("paperflip2", {to_player=player_name, gain = 1.0})
		start_i = start_i - 1
		if start_i < 1 then	start_i = 1	end
		if not (start_i	== start) then
			stargate_network["players"][player_name]["current_index"] = (start_i-1)*24
			formspec = stargate.get_formspec(player_name,"main")
			stargate_network["players"][player_name]["formspec"] = formspec
			minetest.show_formspec(player_name, "stargate_main", formspec)
		end
	end
	if fields.page_right then
		minetest.sound_play("paperflip2", {to_player=player_name, gain = 1.0})
		start_i = start_i + 1 
		if start_i > pagemax then start_i =  pagemax end
		if not (start_i	== start) then
			stargate_network["players"][player_name]["current_index"] = (start_i-1)*24
			formspec = stargate.get_formspec(player_name,"main")
			stargate_network["players"][player_name]["formspec"] = formspec
			minetest.show_formspec(player_name, "stargate_main", formspec)
		end
	end
	local list_index=stargate_network["players"][player_name]["current_index"]
	local i
	for i=0,23,1 do
	local button="list_button"..i+list_index
	if fields[button] then 
		local gate=stargate_network["players"][player_name]["current_gate"]
		local dest_gate=stargate_network["players"][player_name]["own_gates"][list_index+i+1]
		gate["destination"]={}
		gate["destination"].x=dest_gate["pos"].x
		gate["destination"].y=dest_gate["pos"].y
		gate["destination"].z=dest_gate["pos"].z
		activateGate (player,gate["pos"])
	end
	end
end)