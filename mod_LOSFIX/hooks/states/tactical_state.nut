::modLOSFIX.HooksMod.hook("scripts/states/tactical_state", function(q) {
	q.initMap = @(__original) function()
	{
		__original();
		::TooltipEvents.m.MarkedTiles = [];		// Delete the previous array as it potentially points to invalid tiles from a past battle
		if (::modLOSFIX.Mod.ModSettings.getSetting("VisionMatrixCache").getValue())
		{
			::modLOSFIX.VisionMatrixCache.initializeMatrix();
		}
	}
});
