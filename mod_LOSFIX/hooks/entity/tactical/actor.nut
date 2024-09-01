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

			local size = ::Tactical.getMapSize();
			for (local x = 0; x < size.X; x = ++x)
			{
				for (local y = 0; y < size.Y; y = ++y)
				{
					local tile = ::Tactical.getTileSquare(x, y);
					if (::modLOSFIX.Logic.canSee(this, tile))
					{
						tile.addVisibilityForCurrentEntity();
						tile.addVisibilityForFaction(this.getFaction());
						if (this.getFaction() == this.Const.Faction.PlayerAnimals)
						{
							tile.addVisibilityForFaction(::Const.Faction.Player);
						}

						if (tile.IsOccupiedByActor)
						{
							// Player and PlayerAnimals will discover tiles for the Player
							if (this.getFaction() == ::Const.Faction.Player || this.getFaction() == ::Const.Faction.PlayerAnimals)
							{
								tile.getEntity().setDiscovered(true);
							}
						}
					}
				}
			}
		}
	}
});
