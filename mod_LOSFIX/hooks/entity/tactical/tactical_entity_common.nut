{
	// Complete overwrite. Our version is shorter and it now respects hills also as cover
	local oldGetBlockedTiles = ::Const.Tactical.Common.getBlockedTiles;
	::Const.Tactical.Common.getBlockedTiles = function( _myTile, _targetTile, _myFaction, _visibleOnly = false )
	{
		if (!::modLOSFIX.Mod.ModSettings.getSetting("CustomBlockedTiles").getValue())
		{
			return oldGetBlockedTiles(_myTile, _targetTile, _myFaction, _visibleOnly);
		}
		else
		{
			local blockedTiles = [];

			local tileDistance = _myTile.getDistanceTo(_targetTile);
			for (local i = 0; i < 6; i++)
			{
				if (_targetTile.hasNextTile(i))
				{
					local adjacentTile = _targetTile.getNextTile(i);

					if (_myTile.getDistanceTo(adjacentTile) >= tileDistance) continue;	// That tile does not face our direction

					if (!::Const.Tactical.Common.isCover(_targetTile, adjacentTile, _visibleOnly)) continue;	// The tile does not provide cover at all

					// Special rule in vanilla. Your allies are not treated as cover at close range.
					if (adjacentTile.IsOccupiedByActor && _myTile.getDistanceTo(adjacentTile) == 1 && adjacentTile.getEntity().isAlliedWith(_myFaction))
					{
						continue;
					}

					blockedTiles.push(adjacentTile);
				}
			}

			return blockedTiles;
		}
	}

// New Functions
	// Returns true if _coveringTile is considered a cover for an actor standing on _actorTile, returns false otherwise
	::Const.Tactical.Common.isCover <- function( _actorTile, _coveringTile, _visibleOnly )
	{
		if (_visibleOnly && !_coveringTile.IsDiscovered) return false;	// We have no information about the tile

		if (_coveringTile.Level >= _actorTile.Level + 2) return true;	// The covering tile is high enough to provide natural cover no matter what is on it
		if (_actorTile.Level >= _coveringTile.Level + 2) return false;	// The covering tile is way too low to provide natural cover no matter what is on it

		if (_visibleOnly && !_coveringTile.IsVisibleForPlayer) return false;	// We don't see the content of the tile so we don't know whether it provides cover
		// Actually sometimes we know that, because some obstacles are seen even in fog of war.
		// However it's not clear at this point what all of those obstacles have in common so that I can differentiate
		// We might be able to split them with "if (!_coveringTile.IsEmpty && !_coveringTile.IsOccupiedByActor)"

		if (_coveringTile.IsEmpty) return false;

		if (_coveringTile.IsOccupiedByActor)
		{	// Actor
			return true;
		}
		else
		{	// Non-Living Obstacle
			return true;
		}
	}
}
