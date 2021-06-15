--TileTypes

Terraria = Terraria or {};
Terraria.Inventory = Terraria.Inventory or {};

function Color( r, g, b, a )
	local col = {
		r = r,
		g = g,
		b = b,
		a = 255
	};
	if( a ~= nil ) then
		col.a = a;
	end;
	return col;
end;

tiles = {};

tiles.images = {};
tiles.tileTypes = {};

tiles.tileTypes["Air"] = {};
tiles.tileTypes["Air"]["type"] = "Air";

function tiles.CreateTileType( materialName, color, breakTime, minimumHeight, weight, friction, shouldCollide, shouldFall, dropFunction )
	print( materialName );
	tile = {
		type = materialName,
		color = color,
		breakTime = breakTime,
		weight = weight,
		friction = friction,
		minHeight = minimumHeight,
		shouldCollide = shouldCollide,
		shouldFall = shouldFall,
		colorMod = Color( 0, 0, 0 )
	};
	if( dropFunction ~= nil ) then
		tile.dropFunction = dropFunction;
	end;
	tiles.tileTypes[materialName] = tile;
	Terraria.Tiles =  tiles.tileTypes;
	--local image = love.graphics.newImage( "img/" .. materialName .. ".png" );
	--if( image ~= nil ) then
	--	tiles.tileTypes[materialName].image = image;
	--end;
	--Terraria.tiles = tiles.tileTypes;
end;

tiles.CreateTileType( "Dirt", Color( 150, 50, 50 ), 5, 120, 1, 0.1, true, false, function()
	print( "Dirt Dropped" );
end );

tiles.CreateTileType( "Stone", Color( 50, 50, 50 ), 10, 130, 7, 0.2, true, false, function()
	print( "Stone Dropped" );
end );

tiles.CreateTileType( "Sand", Color( 200, 200, 50 ), 3, 130, 2, 0.2, true, true, function()
	print( "Sand Dropped" );
end );

tiles.CreateTileType( "Water", Color( 50, 50, 200 ), 3, 130, 2, 0.2, true, true, function()
	print( "Water Dropped" );
end );

tiles.CreateTileType( "Grass", Color( 50, 200, 50 ), 3, 119, 2, 0.2, true, false, function()
	print( "Grass Dropped" );
end );