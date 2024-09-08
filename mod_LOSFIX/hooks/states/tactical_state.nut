::modLOSFIX.HooksMod.hook("scripts/states/tactical_state", function(q) {
	q.initMap = @(__original) function()
	{
		__original();
		if (::modLOSFIX.Mod.ModSettings.getSetting("VisionMatrixCache").getValue())
		{
			::modLOSFIX.VisionMatrixCache.initializeMatrix();
		}
	}
});
