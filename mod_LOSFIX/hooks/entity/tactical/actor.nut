::modLOSFIX.HooksMod.hook("scripts/entity/tactical/actor", function(q) {
	q.onInit = @(__original) function()
	{
		__original();

		// This is one of the few function given to entities somewhere after create() but before onInit()
		local oldUpdateVisibility = this.updateVisibility;
		this.updateVisibility = function( _tile, _visionRadius, _faction )
		{
			if (!::modLOSFIX.Mod.ModSettings.getSetting("CustomLOSActive").getValue())
			{
				return oldUpdateVisibility(_tile, _visionRadius, _faction);
			}

			// I don't know what the vanilla implementation is. But I presume that it first resets the visibility for this entity.
			// So if I call it with a vision of -5 then it should not discover anything. Unless that something is more than 5 levels downhill
			oldUpdateVisibility( _tile, -5, _faction);

			local forPlayer = (this.getFaction() == ::Const.Faction.Player || this.getFaction() == ::Const.Faction.PlayerAnimals);
			if (forPlayer)
			{
				// this.LF_UpdateVisibility();
				this.LF_UpdateVisibilityForPlayer();
			}
			else
			{
				this.LF_UpdateVisibility();
			}
		}
	}

// New Functions
	// Reveal all tiles around this actor for this actor and the player faction, including hidden tiles, which will be hidden later on
	// Reveal all tiles around this actor, which this actor can currently see
	// If _forPlayer is set to true, we might repeat this call once
	q.LF_UpdateVisibilityForPlayer <- function()
	{
		local repeat = false;

		local size = ::Tactical.getMapSize();
		for (local x = 0; x < size.X; ++x)
		{
			for (local y = 0; y < size.Y; ++y)
			{
				local tile = ::Tactical.getTileSquare(x, y);
				if (tile.IsVisibleForPlayer)
				{
					// ::logWarning("Tile " + x + " " + y + " is weirdly enough visible to the player");
					// ::MSU.Log.printStackTrace();
					::modLOSFIX.Logic.getTileInfo(tile).Defogged = true;
				}

				if (::modLOSFIX.Logic.canSeeTile(this, tile))
				{
					if (!::modLOSFIX.Logic.canSeeContent(this, tile))	// We are about to reveal a tile, that has a bush (or similar) on it
					{
						if (tile.IsDiscovered)
						{
							continue;	// We don't reveal bush tiles that are already discovered, just in case no repeat is happening to reset them
						}
						else
						{
							repeat = true;	// We just revealed a black/undiscovered bush tile. Now we need a full resetFox
						}
					}
					else
					{
						tile.addVisibilityForCurrentEntity();
						if (tile.IsOccupiedByActor)	// Player and PlayerAnimals will discover entities for the Player
						{
							tile.getEntity().setDiscovered(true);
						}
					}

					tile.addVisibilityForFaction(this.getFaction());
					if (this.getFaction() == ::Const.Faction.PlayerAnimals)
					{
						tile.addVisibilityForFaction(::Const.Faction.Player);
					}
				}
			}
		}

		if (repeat)
		{
			::modLOSFIX.Logic.resetFog();	// Add fog of war everywhere and then reveal tiles that the player can see
			this.LF_UpdateVisibility();
		}
	}

	// Reveal all tiles around this actor for this actor and its faction, excluding hidden tiles
	q.LF_UpdateVisibility <- function()
	{
		local size = ::Tactical.getMapSize();
		for (local x = 0; x < size.X; ++x)
		{
			for (local y = 0; y < size.Y; ++y)
			{
				local tile = ::Tactical.getTileSquare(x, y);
				if (::modLOSFIX.Logic.canSeeTile(this, tile) && ::modLOSFIX.Logic.canSeeContent(this, tile))
				{
					::modLOSFIX.Logic.revealTile(this, tile);
				}
			}
		}
	}
});
