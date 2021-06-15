--Surface Shit son

Terraria = Terraria or {};

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

surface = {};
surface.DrawColor = Color( 255, 255, 255, 255 );

function surface.SetDrawColor( color )
	surface.DrawColor = color;
end;

function surface.DrawRect( x, y, w, h )
	love.graphics.setColor( surface.DrawColor.r, surface.DrawColor.g, surface.DrawColor.b );
	love.graphics.rectangle( "fill", x, y, w, h );
end;

function surface.DrawCircle( x, y, radius )
	love.graphics.setColor( surface.DrawColor.r, surface.DrawColor.g, surface.DrawColor.b );
	love.graphics.circle( "fill", x, y, radius );
end;

function surface.DrawTexturedRect( texture, x, y )
	love.graphics.draw( texture, x, y );
end;