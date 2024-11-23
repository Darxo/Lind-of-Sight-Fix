::modLOSFIX.HooksMod.hook("scripts/states/tactical_state", function(q) {
	q.initMap = @(__original) function()
	{
		__original();
		::TooltipEvents.m.MarkedTiles = [];		// Delete the previous array as it potentially points to invalid tiles from a past battle
		::modLOSFIX.VisionMatrixCache.initializeMatrix();
	}

	q.computeEntityPath = @(__original) function( _activeEntity, _mouseEvent )
	{
		__original(_activeEntity, _mouseEvent);

		if (this.m.CurrentActionState == ::Const.Tactical.ActionState.ComputePath && ::modLOSFIX.Mod.ModSettings.getSetting("CustomBlockedTilesPreview").getValue())
		{
			local targetTile = this.m.LastTileSelected;
			for (local i = 0; i < 6; i++)
			{
				if (targetTile.hasNextTile(i))
				{
					local adjacentTile = targetTile.getNextTile(i);
					// There is an edge-case when walking down 2 tiles next to our original position.
					// Because the new is 2 levels lower than our starting tile, our starting tile should be shown as cover
					// However we explicitely filter out our starting tile, because of the simplification of "the active entity does not provide cover for itself"
					if (!adjacentTile.isSameTileAs(_activeEntity.getTile()) && ::Const.Tactical.Common.isCover(targetTile, adjacentTile, true))
					{
						::Tactical.getHighlighter().addOverlayIcon(::Const.Tactical.Settings.RangedSkillBlockedIcon, adjacentTile, adjacentTile.Pos.X, adjacentTile.Pos.Y);
					}
				}
			}
		}
	}
});
