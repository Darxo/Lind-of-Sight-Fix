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
	miscPage.addBooleanSetting("CustomBlockedTiles", true, "Use Custom Cover calculation", "Replace the vanilla calculation for when something is considered cover. Any tile that is 2 level higher than you now counts as cover. Any tile that is 2 levels lower than you will never count as cover, even if there is a tree or other obstacle on it.");

	// Vision Matrix Cache
	local visionMatrixSetting = miscPage.addBooleanSetting("VisionMatrixCache", false, "Vision Matrix Cache", "Enables a dynamically populated matrix that stores Line of Sight (LOS) data between hex tiles. It is filled during combat as LOS checks are made, allowing for faster lookups in subsequent checks. \nThis feature is only effective when vision-blocking elements remain static on the map. Disable this option if you expect dynamic changes, like new obstacles appearing during combat, as it may lead to inaccurate results.");
	local visionMatrixCallback = function( _oldValue )
	{
		if (this.Value)	// We use Vision Matrix now
		{
			::modLOSFIX.Logic.hasLineOfSight = ::modLOSFIX.VisionMatrixCache.hasLineOfSight;
		}
		else
		{
			::modLOSFIX.Logic.hasLineOfSight = ::modLOSFIX.Logic.__hasLineOfSight;
		}

		if (!::MSU.Utils.hasState("tactical_state")) return;

		if (this.Value)
		{
			::modLOSFIX.VisionMatrixCache.initializeMatrix();
		}
	};
	visionMatrixSetting.addAfterChangeCallback(visionMatrixCallback);
}

// Debug
{
	local debugPage = ::modLOSFIX.Mod.ModSettings.addPage("Debug");

	// Show Tile Debug Info
	debugPage.addBooleanSetting("ShowTileDebugInfo", false, "Show Tile Debug Info", "When hovering over a tile on the battlefield, display a lot additional information about it like Coordinates and Properties.");

	// Show LOS Path
	local showLOSPathSetting = debugPage.addBooleanSetting("DisplayLOSPath", false, "Show LOS Path", "When hovering over a tile on the battlefield, highlight all tiles that belong to the direct path from the active entity to that tile. Tiles which block vision for this path are marked red while all other tiles are marked white.");
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
