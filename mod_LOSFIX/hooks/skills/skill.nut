::modLOSFIX.HooksMod.hook("scripts/skills/skill", function(q) {
	q.m.ModernVisibilityNeeded <- true;
	q.m.MarkedTiles <- [];

	// Complete overwrite to replace the visibility check with our own.
	// Also slightly improve the performance for this check
	q.isUsableOn = @() function(_targetTile, _userTile = null)
	{
		::logWarning("custom isUsableOn");
		if (!this.isAffordable() || !this.isUsable())
		{
			return false;
		}

		if (this.isTargeted())
		{
			/*
			if (this.m.IsVisibleTileNeeded && !_targetTile.IsVisibleForEntity)
			{
				return false;
			}*/

			if (_userTile == null)
			{
				_userTile = this.getContainer().getActor().getTile();
			}
			local d = _userTile.getDistanceTo(_targetTile);

			if (d < this.m.MinRange || !this.m.IsRanged && d > this.getMaxRange())
			{
				return false;
			}

			local levelDifference = _userTile.Level - _targetTile.Level;
			if (this.m.IsRanged && d > this.getMaxRange() + ::Math.min(this.m.MaxRangeBonus, ::Math.max(0, levelDifference)))
			{
				return false;
			}

			if (!this.onVerifyTarget(_userTile, _targetTile))
			{
				return false;
			}

			if (this.m.ModernVisibilityNeeded && !::Const.Tactical.Common.hasLineOfSight(_userTile, _targetTile))
			{
				return false;
			}
		}

		return true;
	}

	q.use = @(__original) function( _targetTile, _forFree = false )
	{
		if (!_forFree && !this.isAffordable() || !this.isUsable())
		{
			return false;
		}

		local _userTile = this.getContainer().getActor().getTile;
		if (this.m.ModernVisibilityNeeded && !::Const.Tactical.Common.hasLineOfSight(_userTile, _targetTile))
		{
			return false;
		}

		return __original(_targetTile, _forFree);
	}

	q.onVerifyTarget = @(__original) function( _originTile, _targetTile )
	{
		// ::logWarning("onVerifyTarget");
		/*if (this.m.ModernVisibilityNeeded)
		{
			// ::MSU.Log.printStackTrace();
			// ::logWarning("ModernVisibilityNeeded");
			// markTiles([_originTile, _targetTile]);
			if (!::Const.Tactical.Common.hasLineOfSight(_originTile, _targetTile))
			{
				::logWarning("has NOT hasLineOfSight");
				return false;
			}
		}*/

		return __original(_originTile, _targetTile);
	}
});

::modLOSFIX.HooksMod.hookTree("scripts/skills/skill", function(q) {
	if ("create" in q) // skill.nut itself has no create function in vanilla
	{
		q.create = @(__original) function()
		{
			__original();
			this.ModernVisibilityNeeded = this.m.IsVisibleTileNeeded;
			this.m.IsVisibleTileNeeded = false;
		}
	}
});


