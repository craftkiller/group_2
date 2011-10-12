sprite = require "sprite"
physics = require "physics"
require "highscores"

require "menu"

--if (mainmenu.play == false) then
    --disableListeners()
--end

local function tutHandler(event)
    if event.phase == "began" then
        if event.x > 0 and event.x < 82 and event.y > 180 and event.y < 291 then
            if i > 0 then
                print(i)
                mainmenu.instructions[i].isVisible = false
                i = i - 1
                if i == 0 then
                    mainmenu.background.isVisible = true
                    mainmenu.button1.isVisible = true
                    mainmenu.playbutton.isVisible = true
                    mainmenu.highscorebutton.isVisible = true
                    mainmenu.button2.isVisible = false
                    mainmenu.button3.isVisible = false
                    Runtime:addEventListener("touch", menuTouch)
                    Runtime:removeEventListener("touch", tutHandler)
                end
            end
        elseif event.x > 878 and event.x < 960 and event.y > 180 and event.y < 291 then
            if i < 22 then
                print(i)
                i = i + 1
                mainmenu.instructions[i].isVisible = true
                if i == 22 then
                    print("..?")
                    mainmenu.play = true
                    for i,v in ipairs(mainmenu.instructions) do
                        mainmenu.instructions[i].isVisible = false
                    end
                    mainmenu.button2.isVisible = false
                    mainmenu.button3.isVisible = false
                    --hud:displayHUD(true)
                    --enableListeners()
                    Runtime:removeEventListener("touch", tutHandler)
					mainmenu:Play()
					--enableListeners()
					do_main()
					hud:displayHUD(true)
					hud:update(platform.instance.image.x, survivor_list[1].x_location, extractionPoint.x, extractionPoint.initialDistance, alert)
					hud:displayHUD(true)
					Runtime:removeEventListener("touch", menuTouch)
                end
            end
        end
    end
end

    
function menuTouch(event)
    if event.phase == "began" then
        if (event.x > 50 and event.x < 308
        and event.y > 425 and event.y < 502) then
            --[[if mainmenu.help then
                mainmenu:setHelp(false)
            else
                mainmenu:setHelp(true)
            end]]
            mainmenu:setHelp()
            Runtime:removeEventListener("touch", menuTouch)
            Runtime:addEventListener("touch", tutHandler)
            i = i+1
        elseif (event.x > 336 and event.x < 594 and event.y > 425 and event.y < 502) then
            mainmenu:Play()
            --enableListeners()
			do_main()
			hud:displayHUD(true)
			hud:update(platform.instance.image.x, survivor_list[1].x_location, extractionPoint.x, extractionPoint.initialDistance, alert)
            hud:displayHUD(true)
            Runtime:removeEventListener("touch", menuTouch)

         elseif (event.x > 600 and event.y > 425 and event.y < 502) then
            print("High scores")
            tempory_high_scores(7000)
         end
    end
end

Runtime:addEventListener("touch", menuTouch)

mainmenu = mainMenu:new()
i = 0


if mainmenu.play then
    print("!")
	
end

function do_main()

	require "sounds"

	-- Quick hackish method to force the background to be drawn first
	local background = display.newImage("img/background.png", true)
	local background_ground0 = display.newImage("img/ground_destroyed.png", true)
	local background_ground1 = display.newImage("img/ground_destroyed.png", true)
	local background_mountains_back0 = display.newImage("img/mountains_back.png", true)
	local background_mountains_back1 = display.newImage("img/mountains_back.png", true)
	local background_mountains0 = display.newImage("img/mountains.png", true)
	local background_mountains1 = display.newImage("img/mountains.png", true)
	background_ground0.x = 960/2
	background_ground0.y = 450 + 45
	background_ground1.x = 960*3/2
	background_ground1.y = 450 + 45
	background_mountains_back0.x = 1743/2
	background_mountains_back0.y = 450 - 140/2
	background_mountains_back1.x = 1743*3/2
	background_mountains_back1.y = 450 - 140/2
	background_mountains0.x = 1954/2
	background_mountains0.y = 450 - 195/2
	background_mountains1.x = 1954*3/2
	background_mountains1.y = 450 - 195/2

	--start the physical simulation
	physics.start()
	--physics.setDrawMode("hybrid")

	shield_h = require "shield"
	meteor_h = require "meteor"
	meteor_generator_h = require "meteor_generator"
	platform_h = require "platform"
	platform:new(960/2, 64)
	ground_h = require "ground"
	resource_h = require "resource"
	survivor_h = require "survivor"
	highscores_h = require "highscores"
	require "HUD"
	require "extraction"

	shield_generators = {}
	--[[
	table.insert( shield_generators, shield:new(50, 300 ,200,50,50) )
	table.insert( shield_generators, shield:new(350, 300 ,150,50,50) )
	table.insert( shield_generators, shield:new(550, 300 ,70,50,50) )
	table.insert( shield_generators, shield:new(750, 300 ,90,50,50) )
	table.insert( shield_generators, shield:new(950, 300 ,100,50,50) )
	--]]
	table.insert(survivor_list, survivor:new(500,450) )

	ground.partitions[-1] = {ground:new(-960, 450)}
	ground.partitions[0] = {ground:new(0, 450)}
	ground.partitions[1] = {ground:new(960, 450)}

	extractionPoint = extractPoint:new(950, 450, 100, 5)
	extraction_points = {}
	table.insert( extraction_points, extractionPoint)
	naked_exPoints = {}
	table.insert( naked_exPoints, extractionPoint)

	alert = 0

	--[[Corona automatically translates between the screen units and the
	internal metric units of the physical simulation
	Default ration is 30 pixels == 1 meter. Change with physics.setScale()

	To remain consistent with the rest of the SDK, all angular values
	are expressed in degrees, +y is down, shape definitions must
	declare their points in clockwise order]]

	local function onCollide(event)
	   if event.phase ~= "began" then
		  return
	   end

	   local collide_shield = {}
	   local found_shield = 0
	   for i,v in ipairs(shield_generators) do
		  if event.object1 == v.image or event.object2 == v.image then
			 collide_shield = v
			 found_shield = i
		  end
	   end
	   
	   local found_platform = 0
	   if platform.instance then
		  if event.object1 == platform.instance.image or event.object2 == platform.instance.image then
			 found_platform = 1
		  end
	   end

	   local collide_meteor = {}
	   local found_meteor = 0
	   for i,v in ipairs(meteor_list) do
		  if event.object1 == v.image or event.object2 == v.image then
			 collide_meteor = v
			 found_meteor = i
		  end
	   end

	   local collide_survivor = {}
	   local found_survivor = 0
	   for i,v in ipairs(survivor_list) do
		  if event.object1 == v.image or event.object2 == v.image then
			 hud:addKill()
			 media.playEventSound(sound.survivor_die)
			 collide_survivor = v
			 found_survivor = i
		  end
	   end
	   
	   local collide_extraction = {}
	   local found_extractor = 0
	   for i,v in ipairs(extraction_points) do
		   if (event.object1 == v.shield or event.object2 == v.shield) then
			   collide_extraction = v
			   found_extractor = i
		   end
	   end
	   
	   local collide_shieldless_extraction = {}
	   local found_shieldless_extractor = 0
	   for i,v in ipairs(extraction_points) do
		   if (event.object1 == v.noShield or event.object2 == v.noShield) then
			   collide_shieldless_extraction = v
			   found_shieldless_extractor = i
		   end
	   end

		
	   if found_shieldless_extractor ~= 0 and found_meteor ~= 0 then
		  collide_shieldless_extraction:blow_up()
	   end    
	   if found_extractor ~= 0 and found_meteor ~= 0 then
		  collide_extraction:takedamage(5)
		  if hud then
			   hud:setDistanceBar(collide_extraction.health/collide_extraction.maxHealth)
		  end
		  
	   end   
	   if found_shield ~= 0 and found_meteor ~= 0 then
		  collide_shield:take_damage(5)
		  local temp = cull_shields(shield_generators)
		  if temp ~= 0 then
			  alert = temp
		  end
	   end
	   if found_meteor ~= 0 then
			-- play sounds only when on screen
			
			if collide_meteor.image.x > viewx and collide_meteor.image.x < viewx + 960 then
				if found_shield == 0 and found_extractor == 0 and found_shieldless_extractor == 0 and found_survivor == 0 and found_platform == 0 then
					if math.random() < 0.25 then
						if math.random() < 0.5 then
							media.playEventSound(sound.meteor_ground0)
						else
							media.playEventSound(sound.meteor_ground1)
						end
					end
				end
				if found_shieldless_extractor ~= 0 then
					media.playEventSound(sound.meteor_extractor)
				end
				if found_shield ~= 0 or found_extractor ~= 0 then
					if math.random() < 0.25 then
						-- Hardcoding, ho!
						if math.random() < 0.25 then
							media.playEventSound(sound.meteor_shield0)
						elseif math.random() < 0.33 then
							media.playEventSound(sound.meteor_shield1)
						elseif math.random() < 0.5 then
							media.playEventSound(sound.meteor_shield2)
						else 
							media.playEventSound(sound.meteor_shield3)
						end
					end
				end
			end
			meteor_disperse(found_meteor, meteor_list)
	   end
	   if found_survivor ~= 0 and survivor_list[found_survivor].safe ~= true then
		  kill_survivor(found_survivor, survivor_list)
		  --[[
		  if hud then
			  hud.lives = hud.lives - 1
		  end
		  --]]
	   end
	end

	local test_goright = true

	function onFrame(event)
		if platform.instance then
			platform.instance:update(event.time)
			if platform.instance.laser then
				platform.instance.laser:update(event.time)
			end
			local boundx = math.max(math.min(viewx, platform.instance.image.x - 400), platform.instance.image.x - 960 + 400)
			if boundx ~= viewx then
				move_screen(boundx - viewx)
			end
		end
		
		background.x = viewx + 960/2
		--print('viewx: ' .. viewx .. ' 0: ' .. math.floor(viewx / 960) * 960)
		background_ground0.x = math.floor(viewx / 960) * 960
		background_ground1.x = (math.floor(viewx / 960) + 1) * 960
		background_ground0.x = math.floor(viewx / 960) * 960
		background_ground1.x = (math.floor(viewx / 960) + 1) * 960
		
		background_mountains_back0.x = math.floor(viewx / 1743) * 1743
		background_mountains_back1.x = (math.floor(viewx / 1743) + 1) * 1743
		background_mountains_back0.x = math.floor(viewx / 1743) * 1743
		background_mountains_back1.x = (math.floor(viewx / 1743) + 1) * 1743
		
		background_mountains0.x = math.floor(viewx / 1954) * 1954
		background_mountains1.x = (math.floor(viewx / 1954) + 1) * 1954
		background_mountains0.x = math.floor(viewx / 1954) * 1954
		background_mountains1.x = (math.floor(viewx / 1954) + 1) * 1954
		
		if platform.instance then
			hud:setFuel(platform.instance.resources)
			if #survivor_list > 0 then
				hud:update(platform.instance.image.x, survivor_list[1].x_location, extractionPoint.x, extractionPoint.initialDistance, alert)
			else
				hud:update(platform.instance.image.x, nil, extractionPoint.x, extractionPoint.initialDistance, alert)
			end
		end
		
		hud.group.x = viewx
	end

	--add event listeners for other functions
	Runtime:addEventListener("collision", onCollide)
	Runtime:addEventListener("enterFrame", onFrame)


	--table.insert(survivor_list, survivor:new(500,500) )



	hud = HUD:new()
	hud:displayHUD(false)

	surv_location = survivor_list[1].x_location
	ext_location = extractionPoint.x
	initialDistance = extractionPoint.initialDistance



	local function HUDUpdate(event)
		if event.phase == "began" then
			hud:update(platform.instance.image.x, surv_location, ext_location, initialDistance, alert)
			if event.y < display.contentHeight/20 and event.x > display.contentWidth/10 and event.x < display.contentWidth*9/10 then
				--hud:deFuel()
			end
		end
	end

	local function disableListeners()
		Runtime:removeEventListener('accelerometer', platform.onAccelerometer)
		Runtime:removeEventListener('touch', platform.onTouch)
		Runtime:removeEventListener("collision", onCollide)
	end

	local function enableListeners()
		Runtime:addEventListener('accelerometer', platform.onAccelerometer)
		Runtime:addEventListener('touch', platform.onTouch)
		Runtime:addEventListener("collision", onCollide)
	end



	local function extractPointTouch(event)
		if event.phase == "began" then
			if event.x < extractionPoint.x+25 and event.x > extractionPoint.x-25 and event.y > extractionPoint.y-25 and event.y < extractionPoint.y+25 and 
			platform.instance.image.x > extractionPoint.x-25 and platform.instance.image.x < extractionPoint.x+25 then
				print("extracting...")
				extractionPoint:extract()
			end
		end
	end


	Runtime:addEventListener("touch", extractPointTouch)
	Runtime:addEventListener("touch", HUDUpdate)

	--timer.performWithDelay(100, HUDUpdate, 0)

	viewx = 0

	function move_screen_right(amount)
	   the_stage = display.getCurrentStage()
	   the_stage:translate(-amount, 0)
	   local i = the_stage.numChildren
	   --[[
	   while i > 0 do
		  --the_stage[i].x = the_stage[i].x-amount
		  the_stage[i]:translate(-amount, 0)
		  i = i - 1
	   end
	   --]]
	   -- create, load, and unload ground as needed
	   ground.scroll(viewx + amount, viewx)
	   viewx = viewx + amount
	end

	function move_screen_left(amount)
	   the_stage = display.getCurrentStage()
	   the_stage:translate(amount, 0)
	   local i = the_stage.numChildren
	   --[[
	   while i > 0 do
		  --the_stage[i].x = the_stage[i].x+amount
		  the_stage[i]:translate(amount, 0)
		  i = i - 1
	   end
	   --]]
	   -- create, load, and unload ground as needed
	   ground.scroll(viewx - amount, viewx)
	   viewx = viewx - amount
	end

	function move_screen(amount)
		local stage = display.getCurrentStage()
		stage:translate(-amount, 0)
		
		--[[
		for i = 0, stage.numChildren do
			if stage[i] then
				--stage[i]:translate(amount, 0)
			end
		end
		--]]
		
		ground.scroll(viewx + amount, viewx)
		viewx = viewx + amount
	 end
	--high_scores:show_overlay()
	--high_scores:display_name_box()
	for i,current in ipairs(survivor_list) do
	   current.image:toFront()
	end
	table.insert(survivor_list, survivor:new(50,450) )

	--high_scores:display_name_box()
end
