-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local globalObjects = {}
local detectorDistance = 1200
local psychPower = 4000
local jumpPower = 13000
local noamSpeed = 400
local flag = true

function breakableCollisionHandler( self, event )
	
	if ( event.other.name == "omskite" ) then
		print("GOAL COLLISION WITH "..event.other.name )
		self:removeSelf()
	end

end

function goalCollisionHandler( self, event )
	
	if ( event.other.name == "crate" ) then
		print("GOAL COLLISION WITH "..event.other.name )
		self:removeSelf()
		timer.performWithDelay( 200, function()
			physics.stop()
			scene:destroy()
			composer.gotoScene( "menu", "fade", 500 )	
		end )
	end

end

function noamCollisionHandler( self, event ) 

	self.angularVelocity = 0
	if ( event.other.class == "floor" ) and ( event.phase == "began" ) then
		self.grounded = true
	end

end

function buttonCollisionHandler( self, event ) 

	if ( event.other.name == "omskite" ) and ( event.phase == "began" ) then
		self.pressed = true
		event.phase = "ended"
		print("PRESSED")
	elseif (event.phase == "ended" ) then
		self.pressed = false
		print("UNPRESSED")
	end

end

function animatePlatform() 

	function goRight()
		transition.to( globalObjects[5], { time=5000, x=1700 } )
		transition.to( globalObjects[4], { time=5000, x=1900 } )
		transition.to( globalObjects[3], { time=5000, x=1700, onComplete=goLeft } )
	end

	function goLeft()
		transition.to( globalObjects[5], { time=5000, x=400 } )
		transition.to( globalObjects[4], { time=5000, x=605 } )
		transition.to( globalObjects[3], { time=5000, x=400, onComplete=goRight } )
	end

	if( flag ) then
		print("SETTING")
		flag = false
		goLeft()
	end

end

function animateEnemies() 

	function goRight()
		transition.to( globalObjects[4], { time=5000, x=1900 } )
		transition.to( globalObjects[3], { time=5000, x=1700, onComplete=goLeft } )
	end

	function goLeft()
		transition.to( globalObjects[5], { time=5000, x=400 } )
		transition.to( globalObjects[4], { time=5000, x=605 } )
		transition.to( globalObjects[3], { time=5000, x=400, onComplete=goRight } )
	end

	if( flag ) then
		print("SETTING")
		flag = false
		goLeft()
	end

end

function generateOmskite(x, y)

	local omskiteOptions =
	{
    	-- Required parameters
    	width = 80,
    	height = 80,
    	numFrames = 6,
 
    	-- Optional parameters; used for scaled content support
    	sheetContentWidth = 160,  -- width of original 1x size of entire sheet
    	sheetContentHeight = 240  -- height of original 1x size of entire sheet
	}
	local omskiteImageSheet = graphics.newImageSheet( "Sprites/omskite.png", omskiteOptions )
	local omskiteSequenceData =
	{
		{
			name="idle",
			frames= { 1, 2, 3, 4 }, -- frame indexes of animation, in image sheet
			time = 200,
			loopCount = 0        -- Optional ; default is 0
		}
	}
	local omskite = display.newSprite( omskiteImageSheet, omskiteSequenceData )
	omskite:setSequence("idle")
	omskite:play() 
	omskite.x = x
	omskite.y = y
	omskite.name = "omskite"
	physics.addBody( omskite, "dynamic", { density = 0.5, friction = 0.3 } )
	--omskite.collision = detectorCollisionHandler
	--omskite:addEventListener( "collision" )
	return omskite

end

function generateEnemy(x, y)

	local function robotCollisionHandler(self, event)

		if ( event.other.name == "fire" ) and ( self.dead == false ) then
			print("GOAL COLLISION WITH "..event.other.name )
			self.dead = true
			self:setSequence("die")
			self:play()
			timer.performWithDelay( 700, function()
				self:removeSelf()
			end )
		end

	end

	local enemyOptions =
	{
    	-- Required parameters
    	width = 90,
    	height = 87,
    	numFrames = 15,
 
    	-- Optional parameters; used for scaled content support
    	sheetContentWidth = 270,  -- width of original 1x size of entire sheet
    	sheetContentHeight = 435  -- height of original 1x size of entire sheet
	}
	local enemyImageSheet = graphics.newImageSheet( "Sprites/robot.png", enemyOptions )
	local enemySequenceData =
	{
		{
			name="right",
			frames= { 1, 2, 3, 4 }, -- frame indexes of animation, in image sheet
			time = 500,
			loopCount = 0        -- Optional ; default is 0
		},
		{
			name="left",
			frames= { 6, 7, 8, 9 }, -- frame indexes of animation, in image sheet
			time = 500,
			loopCount = 0        -- Optional ; default is 0
		},
		{
			name="die",
			frames= { 10, 10, 11, 11, 12, 12, 12, 13 }, -- frame indexes of animation, in image sheet
			time = 500,
			loopCount = 1       -- Optional ; default is 0
		}
	}
	local enemy = display.newSprite( enemyImageSheet, enemySequenceData )
	enemy:setSequence("right")
	enemy:play() 
	enemy.x = x
	enemy.y = y
	enemy.name = "enemyOmskite"
	enemy.collision = robotCollisionHandler
	enemy.dead = false
	enemy:addEventListener( "collision" )
	physics.addBody( enemy, "dynamic", { density = 0.5, friction = 0.3 } )
	--enemy.collision = detectorCollisionHandler
	--enemy:addEventListener( "collision" )
	return enemy

end

function generateFire(x, y)
	
	local fireOptions =
	{
    	-- Required parameters
    	width = 130,
    	height = 131,
    	numFrames = 64,
 
    	-- Optional parameters; used for scaled content support
    	sheetContentWidth = 1040,  -- width of original 1x size of entire sheet
    	sheetContentHeight = 1048  -- height of original 1x size of entire sheet
	}
	local fireImageSheet = graphics.newImageSheet( "Sprites/fire.png", fireOptions )
	local fireSequenceData =
	{
		{
			name="idle",
			frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58 }, -- frame indexes of animation, in image sheet
			time = 800,
			loopCount = 0        -- Optional ; default is 0
		}
	}
	local fire = display.newSprite( fireImageSheet, fireSequenceData )
	fire.x, fire.y = x, y
	fire:scale(1,1.25)
	fire.isFixedRotation = true
	fire.name = "fire"
	fire:setSequence("idle")
	fire:play()
	physics.addBody( fire, "static", { density=1.0, friction=0.3, bounce=0 } )

	return fire
end

-- Controller Function
function onKeyEvent( event )
 
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
	--print( message )
	if ( event.keyName == "x" ) and ( event.phase == "up" ) then
		print("Raycasting")
		--print( velocity )
		local detectorX = physics.rayCast( globalObjects[1].x-detectorDistance, globalObjects[1].y, globalObjects[1].x+detectorDistance, globalObjects[1].y, "sorted" )
		local detectorY = physics.rayCast( globalObjects[1].x, globalObjects[1].y-detectorDistance, globalObjects[1].x, globalObjects[1].y+detectorDistance, "sorted" )
		--local pos = "X: '" .. globalObjects[1].x .. "' Y: " .. globalObjects[1].y
		--print( pos )
		if ( detectorX ) then
			for i,v in ipairs( detectorX ) do
				print( "Hit: ", i, " Name: ", v.object.name )
				if ( v.object.name == "omskite" ) or ( v.object.name == "enemyOmskite" ) then
					if (v.object.x > globalObjects[1].x ) then
						v.object:applyForce( -1*psychPower, 0, v.object.x, v.object.y )
					else
						v.object:applyForce( psychPower, 0, v.object.x, v.object.y )
					end
				end
			end
		else
			print("No hits in X")
		end
		if ( detectorY ) then
			for i,v in ipairs( detectorY ) do
				print( "Hit: ", i, " Name: ", v.object.name )
				if ( v.object.name == "omskite" ) or ( v.object.name == "enemyOmskite" ) then
					if (v.object.y > globalObjects[1].y ) then
						v.object:applyForce( 0, -1*psychPower, v.object.x, v.object.y )
					else
						v.object:applyForce( 0, psychPower, v.object.x, v.object.y )
					end
				end
			end
		else
			print("No hits in Y")
		end
	elseif ( event.keyName == "z" ) and ( event.phase == "up" ) then
		print("Raycasting")
		local detectorX = physics.rayCast( globalObjects[1].x-detectorDistance, globalObjects[1].y, globalObjects[1].x+detectorDistance, globalObjects[1].y, "sorted" )
		local detectorY = physics.rayCast( globalObjects[1].x, globalObjects[1].y-detectorDistance, globalObjects[1].x, globalObjects[1].y+detectorDistance, "sorted" )
		
		if ( detectorX ) then
			for i,v in ipairs( detectorX ) do
				print( "Hit: ", i, " Name: ", v.object.name )
				if ( v.object.name == "omskite" ) or ( v.object.name == "enemyOmskite" ) then
					if (v.object.x > globalObjects[1].x ) then
						v.object:applyForce( psychPower, 0, v.object.x, v.object.y )
					else
						v.object:applyForce( -1*psychPower, 0, v.object.x, v.object.y )
					end
				end
			end
		else
			print("No hits in X")
		end
		if ( detectorY ) then
			for i,v in ipairs( detectorY ) do
				print( "Hit: ", i, " Name: ", v.object.name )
				if ( v.object.name == "omskite" ) or ( v.object.name == "enemyOmskite" )then
					if (v.object.y > globalObjects[1].y ) then
						v.object:applyForce( 0, psychPower, v.object.x, v.object.y )
					else
						v.object:applyForce( 0, -1*psychPower, v.object.x, v.object.y )
					end
				end
			end
		else
			print("No hits in Y")
		end
	elseif ( event.keyName == "up" ) and ( event.phase == "down" ) then
		if ( globalObjects[1].grounded == true ) then
			globalObjects[1].grounded = false 
			globalObjects[1]:applyForce( 0, -1*jumpPower, globalObjects[1].x, globalObjects[1].y )
		end
	elseif ( event.keyName == "right" ) and ( event.phase == "down" ) then
		local vx, vy = globalObjects[1]:getLinearVelocity()
		globalObjects[1]:setSequence("walkingRight")
		globalObjects[1]:play()
		if( vx < noamSpeed) then
			globalObjects[1]:setLinearVelocity( noamSpeed, vy )
		end
		 
	elseif ( event.keyName == "left" ) and ( event.phase == "down" ) then
		local vx, vy = globalObjects[1]:getLinearVelocity()
		globalObjects[1]:setSequence("walkingLeft")
		globalObjects[1]:play()
		if( vx < noamSpeed) then
			globalObjects[1]:setLinearVelocity( -1*noamSpeed, vy )
		end 
	elseif ( event.phase == "up" ) then
		if not( globalObjects[1] == nil ) then
			print( globalObjects[1] )
			local vx, vy = globalObjects[1]:getLinearVelocity()
			if( vx > 100 ) then
				globalObjects[1]:setLinearVelocity(100, vy)
			elseif ( vx < -100 ) then
				globalObjects[1]:setLinearVelocity(-100, vy)
			end 
			if ( event.keyName == "left" ) then
				globalObjects[1]:setSequence("standingLeft")
				globalObjects[1]:play()
			end
			if ( event.keyName == "right" ) then
				globalObjects[1]:setSequence("standingRight")
				globalObjects[1]:play()
			end
		end
	end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()

	local background = display.newImageRect( "Images/Backgrounds/Mountain01.png", screenW, screenH )
	background.x, background.y = screenW/2, screenH/2
	
	-- make a crate (off-screen), position it, and rotate slightly
	local crateOptions =
	{
    	-- Required parameters
    	width = 94,
    	height = 96,
    	numFrames = 6,
 
    	-- Optional parameters; used for scaled content support
    	sheetContentWidth = 282,  -- width of original 1x size of entire sheet
    	sheetContentHeight = 192  -- height of original 1x size of entire sheet
	}
	local crateImageSheet = graphics.newImageSheet( "Sprites/noam.png", crateOptions )
	local crateSequenceData =
	{
		{
			name="standingRight",
			frames= { 4, 4, 4 }, -- frame indexes of animation, in image sheet
			time = 200,
			loopCount = 0        -- Optional ; default is 0
		},
		{
			name="standingLeft",
			frames= { 1, 1, 1 }, -- frame indexes of animation, in image sheet
			time = 200,
			loopCount = 0        -- Optional ; default is 0
		},
		{
			name="walkingRight",
			frames= { 4, 5, 6 }, -- frame indexes of animation, in image sheet
			time = 200,
			loopCount = 0        -- Optional ; default is 0
		},
		{
			name="walkingLeft",
			frames= { 1, 2, 3 }, -- frame indexes of animation, in image sheet
			time = 200,
			loopCount = 0        -- Optional ; default is 0
		},
	}

	local crate = display.newSprite( crateImageSheet, crateSequenceData )
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	crate.x, crate.y = 300, 100
	crate.isFixedRotation = true
	crate.name = "crate"
	crate.grounded = false
	crate.collision = noamCollisionHandler
	crate:addEventListener( "collision" )
	physics.addBody( crate, { density=1.0, friction=0.3, bounce=0 } )

	local fire1 = generateFire( 910, 1060 )
	local fire2 = generateFire( 1025, 1060 )
	local fire3 = generateFire( 1135, 1060 )
	local fire4 = generateFire( 1250, 1060 )

	--[[local goal = display.newImageRect( "Sprites/arrow.png", 100, 80 )
	goal.anchorX = 0
	goal.anchorY = 1
	goal.name = "goal"
	goal.class = "goal"
	goal.x, goal.y = 1800, 1150
	goal.collision = goalCollisionHandler
	goal.scene = sceneGroup
	goal:addEventListener( "collision" )
	physics.addBody( goal, "static", { friction=0.3 } )]]--

	local floor1 = display.newImageRect( "Images/tile320.png", 420, 620 )
	floor1.anchorX = 0
	floor1.anchorY = 1
	floor1.name = "floor1"
	floor1.class = "floor"
	floor1.x, floor1.y = 0, 1320
	physics.addBody( floor1, "static", { friction=0.3 } )

	local floor2 = display.newImageRect( "Images/tile320.png", 420, 620 )
	floor2.anchorX = 0
	floor2.anchorY = 1
	floor2.name = "floor2"
	floor2.class = "floor"
	floor2.x, floor2.y = 420, 1320
	physics.addBody( floor2, "static", { friction=0.3 } )

	local floor3 = display.newImageRect( "Images/tile320.png", 420, 620 )
	floor3.anchorX = 0
	floor3.anchorY = 1
	floor3.name = "floor3"
	floor3.class = "floor"
	floor3.x, floor3.y = 1340, 1320
	physics.addBody( floor3, "static", { friction=0.3 } )

	local floor4 = display.newImageRect( "Images/tile320.png", 420, 620 )
	floor4.anchorX = 0
	floor4.anchorY = 1
	floor4.name = "floor4"
	floor4.class = "floor"
	floor4.x, floor4.y = 1740, 1320
	physics.addBody( floor4, "static", { friction=0.3 } )

	local floor5 = display.newImageRect( "Images/tile320.png", 180, 620 )
	floor5.anchorX = 0
	floor5.anchorY = 1
	floor5.name = "floor5"
	floor5.class = "floor"
	floor5.x, floor5.y = 1960, 1320
	physics.addBody( floor5, "static", { friction=0.3 } )

	local bottom = display.newImageRect( "Images/tile320.png", screenW, 80 )
	bottom.anchorX = 0
	bottom.anchorY = 1
	bottom.name = "bottom"
	bottom.class = "floor"
	bottom.x, bottom.y = 0, 1220
	physics.addBody( bottom, "static", { friction=0.3 } )

	-- Position the omskites
	--local omskite1 = generateOmskite( 350, 100)
	--local omskite2 = generateOmskite( 650, 100)
	--local omskite3 = generateOmskite( 950, 100)
	--local omskite4 = generateOmskite( 1250, 100)

	-- Generate enemy
	local enemy1 = generateEnemy( 350, 50)

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( floor1 )
	sceneGroup:insert( floor2 )
	sceneGroup:insert( floor3 )
	sceneGroup:insert( floor4 )
	sceneGroup:insert( floor5 )
	--sceneGroup:insert( omskite1 )
	--sceneGroup:insert( goal )
	sceneGroup:insert( crate )
	
	table.insert( globalObjects, crate )
	table.insert( globalObjects, enemy1 )

	-- Runtime Setup
	Runtime:addEventListener( "key", onKeyEvent )
	Runtime:addEventListener( "enterFrame", animatePlatform )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
		physics.setGravity( 0, 30 )

	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	Runtime:removeEventListener( "key", onKeyEvent )
	Runtime:removeEventListener( "enterFrame", animatePlatform )
	scene:removeEventListener( "create", scene )
	scene:removeEventListener( "show", scene )
	scene:removeEventListener( "hide", scene )
	scene:removeEventListener( "destroy", scene )

	physics.stop()

	package.loaded[physics] = nil
	physics = nil
	globalObjects = nil

	composer.removeScene("level3")

end

---------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene