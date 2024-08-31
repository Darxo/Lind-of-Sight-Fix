::modLOSFIX.HooksMod.hook("scripts/entity/tactical/actor", function(q) {
	q.onPlacedOnMap = @(__original) function()
	{
		__original();
		if (!this.m.Registered)
		{
			::Tactical.State.m.AllEntities.push(::MSU.asWeakTableRef(this));
			this.m.Registered = true;
		}
	}
});
