::modLOSFIX.HooksMod.hook("scripts/entity/tactical/entity", function(q) {
	q.m.OldBlockingSight <- false;

// New Functions
	q.isBlockSight <- function()	// Is used by my custom algorithm
	{
		return this.m.OldBlockingSight;
	}
});

::modLOSFIX.HooksMod.hookTree("scripts/entity/tactical/entity", function(q) {
	// Private
	q.m.Registered <- false;

	q.onAfterInit = @(__original) function()
	{
		__original();

		if (this.isBlockingSight())
		{
			this.m.OldBlockingSight = true;
		}
		this.setBlockSight(false);

		/*
		if (!this.m.Registered)
		{
			if (::MSU.Utils.hasState("tactical_state"))
			{
				::Tactical.State.m.AllEntities.push(::MSU.asWeakTableRef(this));
				this.m.Registered = true;
			}
		}*/
	}
});
