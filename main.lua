
function include( filePath )
	local loaded, chunk = pcall( love.filesystem.load, filePath );
	if( loaded == false ) then
		print( chunk );
	else
		pcall( chunk );
	end;
end;

function IncludeLibraries()
	local files = love.filesystem.enumerate( "/libraries" );
	for k,file in ipairs( files ) do
		include( "libraries/" .. file );
		if( Terraria.Config.Debug == true ) then
			print( "Terraria | Loaded Library: " .. file );
		end;
	end;
	if( Terraria.Config.Debug == true ) then
		print( "Terraria | Loaded Libraries!" );
	end;
end;

function love.load()
	Terraria = {};
	Terraria.Inventory = {};
	Terraria.MenuState = "Game";
	Terraria.OpenedMenu = "None";
	include( "config.lua" );
	love.graphics.setMode( Terraria.Config.Resolution.X, Terraria.Config.Resolution.Y );
	IncludeLibraries();
	--game.GenerateTerrain();
	game.GenerateChunk( cam.x, cam.y );
	hook.Add( "HUDPaint", "game.DrawTiles", game.DrawTiles );
	hook.Add( "Think", "game.SimulateBlocks", game.SimulateBlocks );
end;

function Reload()
	Terraria = {};
	include( "config.lua" );
	IncludeLibraries();
	game.GenerateChunk( cam.x, cam.y );
	hook.Add( "HUDPaint", "game.DrawTiles", game.DrawTiles );
	hook.Add( "Think", "game.SimulateBlocks", game.SimulateBlocks );
end;

function DrawPlayer()
	if( Terraria.MenuState == "Game" ) then
		surface.SetDrawColor( Color( 255, 255, 255 ) );
	surface.DrawRect( ScrW() / 2 - ( Terraria.Config.BlockSize * 3 / 2 ), ScrH() - Terraria.Config.BlockSize * 5 - Terraria.Config.BlockSize * 4, Terraria.Config.BlockSize * 3, Terraria.Config.BlockSize * 5 );
	end;
end;

function love.draw()
	hook.RunHooks( "HUDPaint" );
	DrawPlayer();
end;

function love.keypressed( key, unicode )
	if( key == "escape" ) then
		Reload();
	end;
end;

function BlockPressed( x, y, button )
	if( Terraria.MenuState == "Game" and Terraria.OpenedMenu == "None" ) then
		local actualX, actualY = game.CoordsToBlock( x, y );
		if( actualX ~= false and actualY ~= false ) then
			local tile = game.tiles[actualY][actualX];
			if( button == "l" ) then
				if( tile.type ~= "Air" ) then
					tile.dropFunction();
					game.SetTile( actualX, actualY, "Air" );
				end;
			else
				game.SetTile( actualX, actualY, "Water" );
			end;
		end;
	end;
end;

function love.mousepressed( x, y, button )
	BlockPressed( x, y, button );
end;

function love.update( dt )
	if( Terraria.MenuState == "Game" ) then
		if( love.keyboard.isDown( "up" ) or love.keyboard.isDown( "w" ) ) then
			cam.velocity.y = -5;
		end;
		if( love.keyboard.isDown( "down" ) or love.keyboard.isDown( "s" ) ) then
			cam.y = cam.y + 5;
		end;
		if( love.keyboard.isDown( "left" ) or love.keyboard.isDown( "a" ) ) then
			cam.x = cam.x - 5;
		end;
		if( love.keyboard.isDown( "right" ) or love.keyboard.isDown( "d" ) ) then
			cam.x = cam.x + 5;
		end;
		if( love.keyboard.isDown( "space" ) ) then
			love.load();
		end;
	end;
	hook.RunHooks( "Think" );
end;