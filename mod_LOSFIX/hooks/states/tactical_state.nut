::modLOSFIX.HooksMod.hook("scripts/states/tactical_state", function(q) {
	q.initMap = @(__original) function()
	{
		__original();
		::modLOSFIX.PrecalculatedMatrix.initializeMatrix();
	}
});
