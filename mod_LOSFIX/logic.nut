::modLOSFIX.Logic <- {
	// Determines whether _entity can see _targetTile
	// Will consider vision of _entity, visibility blocking obstacles and terrain level
	// Returns true if _entity can see _targetTile; return false otherwise
	function canSee( _entity, _targetTile )
	{
		local myTile = _entity.getTile();
		local visionRange = _entity.getCurrentProperties().getVision();
		local tileDistance = myTile.getDistanceTo(_targetTile);

		local bonusVision = ::Math.max(0, myTile.Level - _targetTile.Level);		// You can view further downhill
		if (tileDistance > visionRange + bonusVision)
		{
			return false;	// Our vision is not enough to see the tile
		}

		return ::modLOSFIX.Logic.hasLineOfSight(myTile, _targetTile);
	}

	// Proxy-Function.
	// Determines whether _startTile can see _targetTile
	// Will consider visibility blocking obstacles and terrain level
	// Returns true if _startTile can see _targetTile; return false otherwise
	function hasLineOfSight( _startTile, _targetTile )
	{
		::logError("Proxy Function was not replaced!");
	}

	// Determines whether _tile would block line of sight between _userTile and _targetTile
	// This function is symmetric in the sense that it will always yield the same result, even if _userTile and _targetTile was swapped
	function isBlockingLOS( _userTile, _targetTile, _tile )
	{
		if (_tile.isSameTileAs(_userTile)) return false;	// My tile never blocks line of sight
		if (_tile.isSameTileAs(_targetTile)) return false;	// The destination tile never blocks line of sight

		local tileHeight = _tile.Level;
		if (!_tile.IsEmpty && _tile.getEntity().isBlockingSight()) tileHeight += 2;	// A visibility blocking object counts as 2 height instead of blocking LOS outright

		// If the tile in question is very close to the user or target, then it is sufficient if it's 2 levels higher in order to block line of sight
		if (_userTile.getDistanceTo(_tile) == 1 && (tileHeight >= _userTile.Level + 2))
		{
			return true;
		}
		if (_targetTile.getDistanceTo(_tile) == 1 && (tileHeight >= _targetTile.Level + 2))
		{
			return true;
		}

		local totalHeightDifference = tileHeight - _userTile.Level + tileHeight - _targetTile.Level;
		return totalHeightDifference >= 3;
	}

	// Determines whether _startTile can see _targetTile
	// Will consider visibility blocking obstacles and terrain level
	// Returns true if _startTile can see _targetTile; return false otherwise
	function __hasLineOfSight( _startTile, _targetTile )
	{
		local ccStartTile = ::modLOSFIX.CubeCoordinates.fromAxial(_startTile);
		local ccTargetTile = ::modLOSFIX.CubeCoordinates.fromAxial(_targetTile);
		local path = ::modLOSFIX.CubeCoordinates.generatePath(ccStartTile, ccTargetTile);

		// Remove all tiles from the path, which block line of sight
		for (local index = path.len() - 1; index >= 0; --index)
		{
			if (!::Tactical.isValidTile(path[index].axialX, path[index].axialY))
			{
				path.remove(index);
				continue;
			}

			if (this.isBlockingLOS(_startTile, _targetTile, ::Tactical.getTile(path[index].axialX, path[index].axialY)))
			{
				path.remove(index);
				continue;
			}
		}

		return ::modLOSFIX.CubeCoordinates.isPathPossible(ccStartTile, ccTargetTile, path);
	}
}
