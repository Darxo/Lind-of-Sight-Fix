::modLOSFIX.HooksMod.hook("scripts/skills/actives/release_falcon_skill", function(q) {
	q.onUse = @(__original) function( _user, _targetTile )
	{
		local ret = __original(_user, _targetTile);

		if (this.Tactical.TurnSequenceBar.getActiveEntity() != null)
		{
			this.Tactical.TurnSequenceBar.getActiveEntity().updateVisibilityForFaction();	// In Vanilla this is not done one at the end, but rather once for each tile
		}

		return ret;
	}

	// Overwrite, because we need to remove the manual 'updateVisibilityForFaction' call for each onQueryTile, which is redundant and a huge performance issue with this mod
	q.onQueryTile = @() function( _tile, _factionID )
	{
		_tile.addVisibilityForFaction(_factionID);
		if (_tile.IsOccupiedByActor)
		{
			_tile.getEntity().setDiscovered(true);
		}
	}
});
