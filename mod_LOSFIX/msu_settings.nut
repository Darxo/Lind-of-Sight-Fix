// Misc Page
{
	local miscPage = ::modLOSFIX.Mod.ModSettings.addPage("Misc");

	local modToggleLOS = miscPage.addBooleanSetting("CustomLOSActive", true , "Use Custom Line of Sight", "Replace the vanilla LOS calculation with a custom one. It's now easier to look uphill and around obstacles. You can even look over obstacles if you are high enough up. However hills between you and your target block the vision better.");
	local modToggleCallback = function( _oldValue )
	{
		if (!::MSU.Utils.hasState("tactical_state")) return;
		if (this.Value == _oldValue) return;	// Value didn't change. We don't need an update

		local entity = ::Tactical.TurnSequenceBar.getActiveEntity();
		if (entity != null)
		{
			entity.updateVisibilityForFaction();
		}
	};
	modToggleLOS.addAfterChangeCallback(modToggleCallback);

	// Use Custom Cover calculation
	miscPage.addBooleanSetting("CustomBlockedTiles", true, "Use Custom Cover calculation", "Replace the vanilla calculation something is considered cover. Any tile that is 2 level higher than you now counts as cover. Any tile that is 2 levels lower than you will never count as cover, even if there is a tree or other obstacle on it.");
}

// Debug
{
	local debugPage = ::modLOSFIX.Mod.ModSettings.addPage("Debug");

	// Show LOS Path
	local showLOSPathSetting = debugPage.addBooleanSetting("DisplayLOSPath", false, "Show LOS Path", "When hovering over a tile on the battlefield, highlight all tiles that belong to the direct path from the active entity to that tile, except those tiles which block vision for this path.");
	local showLOSPathCallback = function( _oldValue )
	{
		if (!::MSU.Utils.hasState("tactical_state")) return;
		if (this.Value == _oldValue) return;	// Value didn't change. We don't need an update

		if (this.Value == false)
		{
			::TooltipEvents.markTiles([], []);	// Reset the current path
		}
	};
	showLOSPathSetting.addAfterChangeCallback(showLOSPathCallback);
}
