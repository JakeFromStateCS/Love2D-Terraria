--Util Shit son

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

function ScrW()
	return Terraria.Config.Resolution.X;
end;

function ScrH()
	return Terraria.Config.Resolution.Y;
end;