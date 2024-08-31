::Hardened.HooksMod.hook("scripts/states/tactical_state", function(q) {
	q.m.AllEntities <- [];	// Including Obstacles

	q.customHighlight <- function( _activeEntity, _skill )
	{
		local size = this.Tactical.getMapSize();
		for (local x = 0; x < size.X; x = ++x)
		{
			for (local y = 0; y < size.Y; y = ++y)
			{
				local tile = ::Tactical.getTileSquare(x, y);

				if (_skill.isInRange(tile, _activeEntity.getTile()))
				{
					if (!tile.IsDiscovered)
					{
						continue;
					}

					// ::logWarning("onVerifyTarget");
					if (_skill.m.ModernVisibilityNeeded && !::Const.Tactical.Common.hasLineOfSight(_activeEntity.getTile(), tile))
					{
						continue;
					}

					if (_skill.onVerifyTarget(_activeEntity.getTile(), tile))
					{
						::Tactical.getHighlighter().addOverlayIcon("zone_target_overlay", tile, tile.Pos.X, tile.Pos.Y);
					}
					else
					{
						::Tactical.getHighlighter().addOverlayIcon("zone_range_overlay", tile, tile.Pos.X, tile.Pos.Y);
					}
				}
			}
		}
	}

	q.setActionStateBySkill = @(__original) function( _activeEntity, _skill )
	{

		if (this.m.IsGameFinishable && this.isBattleEnded())
		{
			return;
		}

		if (this.m.CurrentActionState != null)
		{
			switch(this.m.CurrentActionState)
			{
			case this.Const.Tactical.ActionState.ComputePath:
				this.cancelEntityPath(_activeEntity);
				break;

			case this.Const.Tactical.ActionState.TravelPath:
				this.logInfo("entity is currently travelling!");
				return;

			case this.Const.Tactical.ActionState.ExecuteSkill:
				this.logInfo("entity is currently executing a skill!");
				return;
			}
		}

		if (this.m.SelectedSkillID == _skill.getID() && this.m.CurrentActionState == this.Const.Tactical.ActionState.SkillSelected)
		{
			_skill.onTargetDeselected();
			this.cancelEntitySkill(_activeEntity);
		}
		else
		{
			this.m.SelectedSkillID = _skill.getID();
			this.m.CurrentActionState = this.Const.Tactical.ActionState.SkillSelected;
			this.Tactical.TurnSequenceBar.selectSkillById(_skill.getID(), true);
			this.Tactical.TurnSequenceBar.setActiveEntityCostsPreview({
				ActionPoints = _skill.getActionPointCost(),
				Fatigue = _skill.getFatigueCost(),
				SkillID = _skill.getID()
			});
			this.Tooltip.reload();

			if (!_skill.isTargeted())
			{
				this.executeEntitySkill(_activeEntity, _activeEntity.getTile());
			}
			else
			{
				this.Tactical.getHighlighter().clear();
				this.customHighlight(_activeEntity, _skill);
				// this.Tactical.getHighlighter().highlightRangeOfSkill(_skill, _activeEntity);

				if (!this.Cursor.isOverUI())
				{
					this.updateCursorAndTooltip(true);
				}
			}
		}

/*
		foreach (entity in this.m.AllEntities)
		{
			if (!::MSU.isNull(entity))
			{
				::logWarning("Set Blocking to false of: " + entity.getName());
				entity.m.OldBlockingSight = entity.isBlockingSight();
				entity.setBlockSight(false);
			}
		}

		__original(_activeEntity, _skill);

		foreach (entity in this.m.AllEntities)
		{
			if (!::MSU.isNull(entity))
			{
				entity.setBlockSight(entity.m.OldBlockingSight);
			}
		}*/
	}
});
