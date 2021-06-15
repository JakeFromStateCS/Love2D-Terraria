--Hook Library

hook = {};
hook.Hooks = {};

function hook.Add( hookType, hookName, func )
	if( hook.Hooks[hookType] ~= nil ) then
		hook.Hooks[hookType][hookName] = func;
	else
		hook.Hooks[hookType] = {};
		hook.Hooks[hookType][hookName] = func;
	end;
end;

function hook.Remove( hookType, hookName )
	if( hook.Hooks[hookType] ~= nil ) then
		hook.Hooks[hookType][hookName] = nil;
	end;
end;

function hook.RunHooks( hookType, args )
	if( hook.Hooks[hookType] ~= nil ) then
		for hookName,func in pairs( hook.Hooks[hookType] ) do
			if( args ~= nil ) then
				func( args );
			else
				func();
			end;
		end;
	end;
end;