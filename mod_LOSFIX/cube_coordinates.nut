::modLOSFIX.CubeCoordinates <- {
	function Origin()
	{
		return this.CCTile(0, 0, 0);
	}

	CCTile = class
	{
		X = null;
		Y = null;
		Z = null;

		oddX = null;	// Vanilla odd-q square coordinates
		oddY = null;	// Vanilla odd-q square coordinates

		axialX = null;	// Vanilla axial coords coordinates
		axialY = null;	// Vanilla axial coords coordinates

		constructor( _x, _y, _z )
		{
			X = _x;
			Y = _y;
			Z = _z;

			oddX = _x;
			oddY = _y + (_x - (::Math.round(_x) & 1)) / 2;

			axialX = _x;
			axialY = _y;
		}

		function get( _index )
		{
			if (_index == 0) return this.X;
			if (_index == 1) return this.Y;
			if (_index == 2) return this.Z;
		}

		function set( _index, _value )
		{
			if (_index == 0) this.X = _value;
			if (_index == 1) this.Y = _value;
			if (_index == 2) this.Z = _value;
		}

		function asString()
		{
			return "[" + X + ", " + Y + ", " + Z + "]";
		}

		// Invert this tile
		function invert()
		{
			return ::modLOSFIX.CubeCoordinates.CCTile(-X, -Y, -Z);
		}

		// Return true if the coordinates of two tiles are exactly equal
		function isEqual( _otherTile )
		{
			return X == _otherTile.X && Y == _otherTile.Y && Z == _otherTile.Z;
		}

		// Normalize this vector compared to the Origin point
		function darxoNormalize()
		{
			local hexDistance = getHexDistance();
			return ::modLOSFIX.CubeCoordinates.CCTile(X / hexDistance, Y / hexDistance, Z / hexDistance);
		}

		function getHexDistance( _otherTile = null )
		{
			if (_otherTile == null) _otherTile = ::modLOSFIX.CubeCoordinates.Origin();
			return (::fabs(X - _otherTile.X) + ::fabs(Y - _otherTile.Y) + ::fabs(Z - _otherTile.Z)) / 2.0;
		}

		// Return the index of the value that is the absolute highest
		function indexOfMaxAbsolute()
		{
			// Compute absolute values
			local absA = ::Math.abs(X);
			local absB = ::Math.abs(Y);
			local absC = ::Math.abs(Z);

			// Determine the index of the maximum absolute value
			if (absA >= absB && absA >= absC)
				return 0;  // a has the largest absolute value
			else if (absB >= absA && absB >= absC)
				return 1;  // b has the largest absolute value
			else
				return 2;  // c has the largest absolute value
		}
	}
	// Generate a CC Tile, given Odd-q coordinates like how BB uses them
	function fromOddQ( _tacticalTile, _optionalY = null )
	{
		local x = _tacticalTile;
		local y = _optionalY;
		if (_optionalY == null)
		{
			x = _tacticalTile.SquareCoords.X;
			y = _tacticalTile.SquareCoords.Y;
		}

		local r = y - (x - (y & 1)) / 2;
		return this.CCTile(x, r, -x - r);
	}

	function fromAxial( _tacticalTile, _optionalY = null )
	{
		local x = _tacticalTile;
		local y = _optionalY;
		if (_optionalY == null)
		{
			x = _tacticalTile.X;
			y = _tacticalTile.Y;
		}

		return this.CCTile(x, y, -x -y);
	}

	function cloneTile( _tile )
	{
		return this.CCTile(_tile.X, _tile.Y, _tile.Z);
	}

	function getVector( _start, _end )
	{
		return this.CCTile(_end.X - _start.X, _end.Y - _start.Y, _end.Z - _start.Z);
	}

	// Return up to two normalized direction vectors from _start to _end, expressed in one or two direction vectors
	function getNormalizedDirections( _start, _end )
	{
		local vector = this.getVector(_start, _end);
		if (_start.X == _end.X || _start.Y == _end.Y || _start.Z == _end.Z)	// _end is sitting on one of the _start - axis. Calculation is trivial
		{
			return [vector.darxoNormalize()];
		}
		else
		{
			local axisTiles = this.getAxisTiles(vector);
			return [axisTiles[0].darxoNormalize(), axisTiles[1].darxoNormalize()];
		}
	}

	// Add two vector and return the result as a newly instantiated vector
	function add( _tile1, _tile2 )
	{
		return this.CCTile(_tile1.X + _tile2.X, _tile1.Y + _tile2.Y, _tile1.Z + _tile2.Z);
	}

// Experimental
	// Given a tile that must lie on a plane (not axis). Return 2 tiles on the two axis on both sides with the same distance to the origin
	function getAxisTiles( _tile )
	{
		local constantAxisIndex = _tile.indexOfMaxAbsolute();
		local max = _tile.get(constantAxisIndex);

		local ret1 = this.CCTile(max, max, max);
		local ret2 = this.CCTile(max, max, max);

		constantAxisIndex = (++constantAxisIndex) % 3;

		ret1.set(constantAxisIndex, 0);
		ret2.set(constantAxisIndex, -max);

		constantAxisIndex = (++constantAxisIndex) % 3;

		ret1.set(constantAxisIndex, -max);
		ret2.set(constantAxisIndex, 0);

		return [ret1, ret2];
	}

	// Given 2 tiles that are on the same axis. Return all tiles that are in between those two tiles including the passed ones
	function getTilesBetween( _start, _end )
	{
		if (_start.isEqual(_end))
		{
			return [this.cloneTile(_start)];
		}

		// ::logWarning("getTilesBetween " + _start.asString() + " and " + _end.asString());
		local ret = [this.cloneTile(_start), this.cloneTile(_end)];

		local normalizedVector = this.getVector(_start, _end).darxoNormalize();
		// ::logWarning("normalizedVector " + normalizedVector.asString());
		local it = this.add(_start, normalizedVector);
		while (!it.isEqual(_end))
		{
			// ::logWarning("it = " + it.asString());
			ret.push(it);
			it = this.add(it, normalizedVector);
		}
		// ::logWarning("result: ");
		this.printTiles(ret);
		return ret;
	}

	// If one of the _tilesToCheck is exactly the same as _stepCenter, then only one tile is returned.
	// Otherwise the closest two tiles are returned
	function getClosestTiles( _stepCenter, _tilesToCheck )
	{
		// ::logWarning("getClosestTiles " + _stepCenter.asString() + " _tilesToCheck: ");
		this.printTiles(_tilesToCheck)
		if (_tilesToCheck.len() == 1) return _tilesToCheck;

		local sortedTiles = [];
		foreach (tile in _tilesToCheck)
		{
			sortedTiles.push({
				Distance = tile.getHexDistance(_stepCenter),
				Tile = tile
			});
		}

		sortedTiles.sort(@(a, b) a.Distance <=> b.Distance);

		// ::logWarning("Shortest Distance " + sortedTiles[0].Distance);
		// ::logWarning("Longest Distance " + sortedTiles[sortedTiles.len() - 1].Distance);

		if (sortedTiles[0].Distance == 0)
		{
			return [sortedTiles[0].Tile];
		}
		else
		{
			return [sortedTiles[0].Tile, sortedTiles[1].Tile];
		}
	}

	function generatePath( _start, _end )
	{
		local offset = _start;

		// From here on out, everything is treated as being from the origin

		local destination = this.getVector(_start, _end);
		local allowedTiles = this.__generatePath(destination);

		// Now we calculate the offset back on top of this

		this.transformPositions(allowedTiles, offset);

		return allowedTiles;
	}

	// Generate a path from the origin to _end
	function __generatePath( _end )
	{
		// ::logWarning("generatePath");
		if (_end.X == 0 || _end.Y == 0 || _end.Z == 0)	// _end is sitting on one of the axis. Calculation is trivial
		{
			return getTilesBetween(this.Origin(), _end);
		}
		else
		{
			local ret = [this.Origin(), this.cloneTile(_end)];

			local normalizedVector = _end.darxoNormalize();
			local stepCenter = this.add(this.Origin(), normalizedVector);
			for (local i = 1; i < _end.getHexDistance(); ++i)
			{
				// ::logWarning("Distance " + i + "; stepCenter: " + stepCenter.asString());
				local axis = this.getAxisTiles(stepCenter);
				local candidates = this.getTilesBetween(axis[0], axis[1]);
				ret.extend(getClosestTiles(stepCenter, candidates));
				stepCenter = this.add(stepCenter, normalizedVector);
			}

			return ret;
		}
	}

	function isPathPossible(_start, _destination, _allowedTiles )
	{
		local allowedDirections = this.getNormalizedDirections(_start, _destination);
		// ::logWarning("Direction 1: " + allowedDirections[0].asString());
		// if (allowedDirections.len() == 2) ::logWarning("Direction 2: " + allowedDirections[1].asString());
		return this.__isPathPossible(_start, _destination, _allowedTiles, allowedDirections);
	}

	// is it possible to traverse from _destination to origin using only _allowedTiles, without ever backtracking?
	// We use recursion because of ease of implementation
	function __isPathPossible( _start, _destination, _allowedTiles, _allowedDirections )
	{
		// We are at the destination
		if (_start.isEqual(_destination)) return true;

		local isAllowed = false;
		foreach (tile in _allowedTiles)
		{
			if (_start.isEqual(tile))
			{
				isAllowed = true;
				break;
			}
		}
		if (!isAllowed) return false;	// We entered an invalid tile

		foreach (chosenDirection in _allowedDirections)
		{
			if (this.__isPathPossible(this.add(_start, chosenDirection), _destination, _allowedTiles, _allowedDirections))
			{
				return true;
			}
		}
		return false;
	}

	// Apply the offset _offset to all tiles in _tileArray, replacing the existing values in it
	function transformPositions( _tileArray, _offset )
	{
		foreach (index, tile in _tileArray)
		{
			_tileArray[index] = this.add(tile, _offset);
		}
	}

	function main( _start, _destination )
	{
		local allowedTiles = this.generatePath(_start, _destination);
		this.isPathPossible(_start, _destination, _allowedTiles);
	}

	function printTiles( _tileArray )
	{
		local arrayString = "";
		foreach (tile in _tileArray)
		{
			arrayString += tile.asString() + ", ";
		}
		// ::logWarning(arrayString);
	}
}

// ::logWarning(::modLOSFIX.CubeCoordinates.generatePath([-2, -2, 4]).len());

// ::modLOSFIX.CubeCoordinates.printTiles(::modLOSFIX.CubeCoordinates.generatePath(::modLOSFIX.CubeCoordinates.Tile(3, 1, -4), ::modLOSFIX.CubeCoordinates.Tile(-2, -2, 4)));
// ::modLOSFIX.CubeCoordinates.main(::modLOSFIX.CubeCoordinates.Tile(3, 1, -4), ::modLOSFIX.CubeCoordinates.Tile(-2, -2, 4));
// ::modLOSFIX.CubeCoordinates.main(::modLOSFIX.CubeCoordinates.Origin(), ::modLOSFIX.CubeCoordinates.Tile(-2, -2, 4));




/*
local destination = [5, -5, 0];
local path = ::modLOSFIX.CubeCoordinates.getTilesBetween([0, 0, 0], destination);
path.remove(3);
::logWarning(::modLOSFIX.CubeCoordinates.isPathPossible(destination, path, ::modLOSFIX.CubeCoordinates.getNormalizedDirections(::modLOSFIX.CubeCoordinates.invertVector(destination))));
*/
