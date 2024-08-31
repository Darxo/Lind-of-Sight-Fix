::Const.Tactical.Common.isBlockingLOS <- function( _userTile, _targetTile, _tile )
{
	if (_userTile.getDistanceTo(_targetTile) <= 1) return false;

	local tileHeight = _tile.Level;
	if (!_tile.IsEmpty && _tile.getEntity().isBlockSight()) tileHeight += 2;

	local heightDifference = tileHeight - _userTile.Level + tileHeight - _targetTile.Level;
	return heightDifference >= 3;
}

::Const.Tactical.Common.hasLineOfSight <- function( _startTile, _targetTile )
{
	local ccStartTile = ::CubeCoordinates.fromAxial(_startTile);
	local ccTargetTile = ::CubeCoordinates.fromAxial(_targetTile);
	local path = ::CubeCoordinates.generatePath(ccStartTile, ccTargetTile);

	// Remove all tiles from the path, which block line of sight
	for (local index = path.len() - 1; index >= 0; --index)
	{
		if (!::Tactical.isValidTile(path[index].axialX, path[index].axialY))
		{
			path.remove(index);
			continue;
		}

		if (::Const.Tactical.Common.isBlockingLOS(_startTile, _targetTile, ::Tactical.getTile(path[index].axialX, path[index].axialY)))
		{
			path.remove(index);
			continue;
		}
	}

	return ::CubeCoordinates.isPathPossible(ccStartTile, ccTargetTile, path);
}

::Const.Tactical.Common.getLineOfSightPath <- function( _startTile, _targetTile )
{
	local ccStartTile = ::CubeCoordinates.fromAxial(_startTile);
	local ccTargetTile = ::CubeCoordinates.fromAxial(_targetTile);
	local path = ::CubeCoordinates.generatePath(ccStartTile, ccTargetTile);

	// Remove all tiles from the path, which block line of sight
	for (local index = path.len() - 1; index >= 0; --index)
	{
		if (!::Tactical.isValidTile(path[index].axialX, path[index].axialY))
		{
			path.remove(index);
			continue;
		}

		if (::Const.Tactical.Common.isBlockingLOS(_startTile, _targetTile, ::Tactical.getTile(path[index].axialX, path[index].axialY)))
		{
			path.remove(index);
			continue;
		}
	}

	return path;
}
