::modLOSFIX.HooksMod.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.m.MarkedTiles <- [];

	q.tactical_queryTileTooltipData = @(__original) function()
	{
		local lastTileHovered = ::Tactical.State.getLastTileHovered();
		if (lastTileHovered == null) return null;

		local activeEntity = ::Tactical.TurnSequenceBar.getActiveEntity();
		if (activeEntity != null)
		{
			if (::modLOSFIX.Mod.ModSettings.getSetting("DisplayLOSPath").getValue())
			{
				local pathArray = this.getTacticalPath(activeEntity.getTile(), lastTileHovered);
				this.markTiles(pathArray[0], pathArray[1]);
			}
		}

			return __original();
	}

// New Functions
	// Unmark the previous tiles and mark the new passed ones
	q.markTiles <- function( _validTiles, _blockedTiles )
	{
		foreach (tile in this.m.MarkedTiles)
		{
			tile.clear(::Const.Tactical.DetailFlag.SpecialOverlay);
		}

		foreach (tile in _validTiles)
		{
			tile.spawnDetail("zone_selection_overlay", ::Const.Tactical.DetailFlag.SpecialOverlay, false, true);
		}

		foreach (tile in _blockedTiles)
		{
			tile.spawnDetail("zone_target_overlay", ::Const.Tactical.DetailFlag.SpecialOverlay, false, true);
		}

		this.m.MarkedTiles = _validTiles;
		this.m.MarkedTiles.extend(_blockedTiles)
	}

	// Generate a path from _startTile to _targetTile and diffentiate tiles which block vision on that path
	// Return an array with two entries. The first entry is an array of all valid tiles. The second entry is an array with all invalid tiles
	q.getTacticalPath <- function( _startTile, _targetTile )
	{
		local ccStartTile = ::modLOSFIX.CubeCoordinates.fromAxial(_startTile);
		local ccTargetTile = ::modLOSFIX.CubeCoordinates.fromAxial(_targetTile);
		local path = ::modLOSFIX.CubeCoordinates.generatePath(ccStartTile, ccTargetTile);

		local validTiles = [];
		local blockedTiles = [];

		// Remove all tiles from the path, which block line of sight
		for (local index = path.len() - 1; index >= 0; --index)
		{
			if (!::Tactical.isValidTile(path[index].axialX, path[index].axialY))
			{
				continue;
			}

			local tacticalTile = ::Tactical.getTile(path[index].axialX, path[index].axialY);
			if (::modLOSFIX.Logic.isBlockingLOS(_startTile, _targetTile, tacticalTile))
			{
				blockedTiles.push(tacticalTile);
			}
			else
			{
				validTiles.push(tacticalTile);
			}
		}

		return [validTiles, blockedTiles];
	}
});

