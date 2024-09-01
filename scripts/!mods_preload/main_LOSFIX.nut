::modLOSFIX <- {
	ID = "mod_LOSFIX",
	Name = "Line of Sight Fix",
	Version = "0.1.0",
	// GitHubURL = "https://github.com/YOURNAME/mod_MODID",
}

::modLOSFIX.HooksMod <- ::Hooks.register(::modLOSFIX.ID, ::modLOSFIX.Version, ::modLOSFIX.Name);
::modLOSFIX.HooksMod.require(["mod_msu"]);

::modLOSFIX.HooksMod.queue(">mod_msu", function() {
	::modLOSFIX.Mod <- ::MSU.Class.Mod(::modLOSFIX.ID, ::modLOSFIX.Version, ::modLOSFIX.Name);

	// Add an official mod source and turn on automatic ingame reminder about new updates
	// ::modLOSFIX.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::mod_MODID.GitHubURL);
	// ::modLOSFIX.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::include("mod_LOSFIX/load");		// Load mod adjustments and other hooks
});
