--Game

function include( filePath )
	local loaded, chunk = pcall( love.filesystem.load, filePath );
	if( loaded == false ) then
		print( chunk );
	else
		pcall( chunk );
	end;
end;

Terraria = Terraria or {};
game = {};
game.tiles = {};
include( "tiles.lua" );
include( "camera.lua" );
include( "hook.lua" );
include( "perlin.lua" );

local tileTypes = Terraria.Tiles;
local nextGravityTime = love.timer.getTime()
game.nextBlockSimulate = love.timer.getTime();

function Color( r, g, b )
	return { r=r, g=g, b=b };
end;

function game.SetTile( x, y, blockType )
	if( Terraria.Tiles[blockType] ~= nil ) then
		if( game.tiles[y] ~= nil ) then
			game.tiles[y][x] = Terraria.Tiles[blockType];
		else
			game.tiles[y] = {};
			game.tiles[y][x] = Terraria.Tiles[blockType];
		end;
	end;
end;

function game.GetTile( x, y )
	if( game.tiles[y] ~= nil ) then
		if( game.tiles[y][x] ~= nil ) then
			return game.tiles[y][x];
		else
			return nil;
		end;
	else
		return nil;
	end;
end;

function game.GenerateSeed()
	local string = "";
	for i=1, 20 do
		local seed = math.random( 1, 10000 );
		string = string .. seed;
	end;
	game.Seed = tonumber( string );
end;

function game.GenerateTerrain()
	print( "Terraria | Starting Terrain Generation!" );
	local time = os.time();
	game.GenerateSeed();
	for y=1, Terraria.Config.WorldSize.Y do
		game.tiles[y] = {};
		for x=1, Terraria.Config.WorldSize.X do
			game.SetTile( x, y, "Air" );
			if( y > Terraria.Config.StoneHeight ) then
				local noise = SimplexNoise.Noise2D( x, y );--perlin_2d( x, y, game.Seed );
				if( noise >= 0 ) then
					game.SetTile( x, y, "Stone" );
				else
					game.SetTile( x, y, "Air" );
				end;
			elseif( y > Terraria.Config.DirtHeight ) then
				game.SetTile( x, y, "Dirt" );
			end;
		end;
	end;
	print( "Terraria | Finished Loading Terrain!" );
	print( "Terraria | " .. ( Terraria.Config.WorldSize.X * Terraria.Config.WorldSize.Y ) .. " Blocks generated in " .. ( os.time() - time ) .. " seconds." );
end;

function game.GenerateChunk( x, y )
	for blockY = y, y + Terraria.Config.ChunkSize do
		for blockX = x, x + Terraria.Config.ChunkSize do
			if( game.tiles[blockY] == nil ) then
				game.tiles[blockY] = {};
			end;
			if( game.tiles[blockY][blockX] == nil ) then
				game.SetTile( blockX, blockY, "Air" );
				if( blockY > Terraria.Config.StoneHeight ) then
					local noise = perlin_2d( blockX, blockY, math.random( 1, 99999 ) );
					if( noise > 0.15 ) then
						game.SetTile( blockX, blockY, "Stone" );
					else
						if( noise > 0 ) then
							if( math.random( 1, 5 ) == 1 ) then
								game.SetTile( blockX, blockY, "Water" );
							else
								game.SetTile( blockX, blockY, "Sand" );
							end;
						else
							game.SetTile( blockX, blockY, "Air" );
						end;
					end;
				elseif( blockY > Terraria.Config.DirtHeight ) then
					game.SetTile( blockX, blockY, "Dirt" );
				elseif( blockY == Terraria.Config.MountainHeight ) then
					local mountainHeight = math.ceil( perlin( blockX, { 1, 1, 1 } ) * 5 - 5 );
					for blockY = blockY + mountainHeight, blockY do
						game.SetTile( blockX, blockY, "Dirt" );
					end;
				end;
			end;
		end;
	end
end;

function game.CoordsToBlock( x, y )
	actualX, actualY = math.ceil( ( ( x - Terraria.Config.BlockSize ) + cam.x ) / Terraria.Config.BlockSize ), math.ceil( ( y + cam.y ) / Terraria.Config.BlockSize );
	if( actualY > Terraria.Config.WorldSize.Y ) then
		actualY = Terraria.Config.WorldSize.Y;
	end;
	if( actualX > Terraria.Config.WorldSize.X ) then
		actualX = Terraria.Config.WorldSize.X;
	end;
	if( actualX > -1 and actualY > -1 ) then
		return actualX, actualY;
	else
		return false, false;
	end;
end;

function game.ScreenBounds( x, y )
	minY, maxY = math.ceil( y / Terraria.Config.BlockSize ), math.ceil( ( y + Terraria.Config.BlockSize + Terraria.Config.Resolution.Y ) / Terraria.Config.BlockSize );
	minX, maxX = math.ceil( ( x - Terraria.Config.BlockSize ) / Terraria.Config.BlockSize ), math.ceil( ( x + Terraria.Config.Resolution.X ) / Terraria.Config.BlockSize );
	if( minX < 0 ) then
		minX = 0;
	end;
	if( minY < 0 ) then
		minY = 0;
	end;
	if( maxY > Terraria.Config.WorldSize.Y ) then
		maxY = Terraria.Config.WorldSize.Y;
	end;
	if( maxX > Terraria.Config.WorldSize.X ) then
		maxX = Terraria.Config.WorldSize.X;
	end;
	return minY, maxY, minX, maxX;
end;

function game.DrawTiles()
	if( Terraria.MenuState == "Game" ) then
		minY, maxY, minX, maxX = game.ScreenBounds( cam.x, cam.y );
		for y=minY, maxY do
			tiles = game.tiles[y];
			for x=minX, maxX do
				if( tiles ~= nil ) then
					tile = tiles[x];
					if( tile ~= nil ) then
						if( tile.type ~= nil ) then
							if( tile.type ~= "Air" ) then
								renderX, renderY = x * Terraria.Config.BlockSize - cam.x, ( y - 1 ) * Terraria.Config.BlockSize - cam.y;
								if( Terraria.Tiles[tile.type].image ~= nil ) then
									surface.DrawTexturedRect( Terraria.Tiles[tile.type].image, renderX, renderY );
								else
									--local r, g, b = math.Clamp( tile.color.r + tile.colorMod.r, 0, 255 ), math.Clamp( tile.color.g + tile.colorMod.g, 0, 255 ), math.Clamp( tile.color.b + tile.colorMod.b, 0, 255 );
									local r, g, b = tile.color.r, tile.color.g, tile.color.b;
									local tileColor = Color( r, g, b );
									surface.SetDrawColor( tileColor );
									surface.DrawRect( renderX, renderY, Terraria.Config.BlockSize, Terraria.Config.BlockSize );
								end;
							else
								renderX, renderY = x * Terraria.Config.BlockSize - cam.x, ( y - 1 ) * Terraria.Config.BlockSize - cam.y;
								surface.SetDrawColor( Color( 50, 50, 50 ) );
								surface.DrawRect( renderX, renderY, Terraria.Config.BlockSize, Terraria.Config.BlockSize );
								surface.SetDrawColor( Color( 0, 0, 0 ) );
								surface.DrawRect( renderX + 1, renderY + 1, Terraria.Config.BlockSize - 2, Terraria.Config.BlockSize - 2 );
							end;
						end;
					else
						local chunkX, chunkY = game.CoordsToBlock( cam.x, cam.y );
						game.GenerateChunk( x, y );
					end;
				else
					game.GenerateChunk( x, y );
				end;
			end;
		end;
	end;
end;

function game.SimulateBlocks()
	if( Terraria.MenuState == "Game" ) then
		if( love.timer.getTime() > game.nextBlockSimulate ) then
			minY, maxY, minX, maxX = game.ScreenBounds( cam.x, cam.y );
			for y=minY, maxY + 5 do
				tiles = game.tiles[y];
				if( tiles ~= nil ) then
					for x=minX, maxX + 5 do
						tile = tiles[x];
						if( tile ~= nil ) then
							if( tile.shouldFall ) then
								local rowBelow = game.tiles[y+1];
								if( rowBelow ~= nil ) then
									local tileBelow = rowBelow[x];
									if( tileBelow ~= nil ) then
										if( tileBelow.type == "Air" or tileBelow.type == nil ) then
											game.SetTile( x, y, "Air" );
											game.SetTile( x, y + 1, tile.type );
										elseif( tileBelow.type == "Water" or tileBelow.liquid == true ) then
											if( tile.type ~= "Water" or tile.liquid == true ) then
												game.SetTile( x, y, tileBelow.type );
												game.SetTile( x, y + 1, tile.type );
											else
												local randomTest = math.random( 1, 2 );
												if( randomTest == 1 ) then
													local rightTile = tiles[x+1];
													if( rightTile ~= nil ) then
														if( rightTile.type == "Air" or rightTile.type == "Air" ) then
															game.SetTile( x, y, "Air" );
															game.SetTile( x+1, y, tile.type );
														end;
													end;
												else
													local leftTile = tiles[x-1];
													if( leftTile ~= nil ) then
														if( leftTile.type == "Air" or leftTile.type == "Air" ) then
															game.SetTile( x, y, "Air" );
															game.SetTile( x-1, y, tile.type );
														end;
													end;
												end;
											end;
										else
											if( tile.type == "Water" or tile.liquid == true ) then
												local randomTest = math.random( 1, 2 );
												if( randomTest == 1 ) then
													local leftTile = tiles[x-1];
													if( leftTile ~= nil ) then
														if( leftTile.type == "Air" or leftTile.type == "Air" ) then
															game.SetTile( x, y, "Air" );
															game.SetTile( x-1, y, tile.type );
														end;
													end;
												else
													local rightTile = tiles[x+1];
													if( rightTile ~= nil ) then
														if( rightTile.type == "Air" or rightTile.type == "Air" ) then
															game.SetTile( x, y, "Air" );
															game.SetTile( x+1, y, tile.type );
														end;
													end;
												end;
											end;
										end;
									end;
								end;
							end;
						end;
					end;
				end;
			end;
			game.nextBlockSimulate = love.timer.getTime() + 0.1;
		end;
		game.SimulateGravity();
	end;
end;

function game.CheckCollisionBottom()
	for i=0, 2 do
		local checkX, checkY = ScrW() / 2 - ( Terraria.Config.BlockSize * 3 / 2 ), ScrH();
		local actualX, actualY = game.CoordsToBlock( checkX, checkY );
		local block = game.GetTile( actualX + i, actualY );
		if( block ~= nil ) then
			if( block.type ~= "Air" ) then
				return true;
			end;
		end;
	end;
	return false;
end;

function game.SimulateGravity()
	local checkX, checkY = ScrW() / 2 - ( Terraria.Config.BlockSize * 3 / 2 ), ScrH() - Terraria.Config.BlockSize * 4;
	local actualX, actualY = game.CoordsToBlock( checkX, checkY );
	local onGround = game.CheckCollisionBottom();
	if( onGround == false ) then
		cam.y = cam.y + cam.velocity.y;
		cam.velocity.y = ( cam.velocity.y + Terraria.Config.GravityRate / 10 );
	end;
	if( cam.velocity.y < 0 ) then
		cam.y = cam.y + cam.velocity.y;
	end;
end;