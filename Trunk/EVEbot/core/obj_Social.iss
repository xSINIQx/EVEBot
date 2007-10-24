/*
This contains all stuff dealing with other players around us. - Hessinger
	
	Methods
		- GetPlayers(): Updates our Pilot Index (Currently updated on pulse, do not use elsewhere)
	
	Members
		- (bool) PlayerDetection(): Returns TRUE if a Player is near us. (Notes: Ignores Gang Members)
		- (bool) NPCDetection(): Returns TRUE if an NPC is near us.
		- (bool) PilotsWithinDectection(int Distance): Returns True if there are pilots within the distance passed to the member. (Notes: Only works for players)
		- (bool) StandingDetection(int Standing): Returns True if there are pilots below the standing passed to the member. (Notes: Only works for players)
		- (bool) PossibleHostiles(): Returns True if there are ships targeting us.
*/

objectdef obj_Social
{
	;Variables 
	variable index:entity PilotIndex
	variable index:entity EntityIndex
	variable int FrameCounter
	
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:Pulse]
		UI:UpdateConsole["obj_Social: Initialized"]
	}
	
	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:Pulse]
	}

	method Pulse()
	{
		if ${EVEBot.Paused}
		{
			return
		}

		FrameCounter:Inc

		/* TODO : CyberTech - This is on-demand stuff. don't store it, get it as needed. */
		if (${Me.InStation(exists)} && !${Me.InStation})
		{
			variable int IntervalInSeconds = 5
			if ${FrameCounter} >= ${Math.Calc[${Display.FPS} * ${IntervalInSeconds}]}
			{
				This:GetLists
				FrameCounter:Set[0]
			}
		}
	}
	
	method GetLists()
	{
		EVE:DoGetEntities[PilotIndex,CategoryID,6]
		EVE:DoGetEntities[EntityIndex,CategoryID,11]
	}
	
	member:bool PlayerDetection()
	{
		if !${This.PilotIndex.Used}
		{
			return FALSE
		}
		
		variable iterator PilotIterator
		This.PilotIndex:GetIterator[PilotIterator]
		
		if ${PilotIterator:First(exists)}
		{
			do
			{
				if ${PilotIterator.Value.IsPC} && \
				 	${Me.ShipID} != ${PilotIterator.Value} && \
				 	${PilotIterator.Value.Distance} < ${Config.Miner.AvoidPlayerRange} && \
				 	!${PilotIterator.Value.Owner.ToGangMember}
				{
					return TRUE
				}
			}
			while ${PilotIterator:Next(exists)}
		}
		return FALSE
	}
	
	member:bool NPCDetection()
	{
		if !${This.EntityIndex.Used}
		{
			return FALSE
		}
		
		variable iterator EntityIterator
		This.EntityIndex:GetIterator[EntityIterator]
		
		if ${EntityIterator:First(exists)}
		{
			do
			{
				if ${EntityIterator.Value.IsNPC}
				{
					return TRUE
				}
			}
			while ${EntityIterator:Next(exists)}
		}
		
		return FALSE
	}
	
	member:bool StandingDetection(int Standing)
	{
		if !${This.PilotIndex.Used}
		{
			return FALSE
		}
		
		variable iterator PilotIterator
		This.PilotIndex:GetIterator[PilotIterator]
		
		if ${PilotIterator:First(exists)}
		{
			do
			{
				if (${Me.ShipID} == ${PilotIterator.Value}) && \
					${PilotIterator.Value.Owner.ToGangMember(exists)}
				{
					return FALSE
				}

				/* Check Standing */
				if	${EVE.Standing[${Me.CharID},${PilotITerator.Value.Owner.CharID}]} < ${Standing} || \
					${EVE.Standing[${Me.CorpID},${PilotITerator.Value.Owner.CharID}]} < ${Standing} || \
					${EVE.Standing[${Me.AllianceID},${PilotITerator.Value.Owner.CharID}]} < ${Standing} || \
					${EVE.Standing[${Me.CharID},${PilotITerator.Value.Owner.CorpID}]} < ${Standing} || \
					${EVE.Standing[${Me.CorpID},${PilotITerator.Value.Owner.CorpID}]} < ${Standing} || \
					${EVE.Standing[${Me.AllianceID},${PilotITerator.Value.Owner.CorpID}]} < ${Standing} || \
					${EVE.Standing[${Me.CharID},${PilotITerator.Value.Owner.AllianceID}]} < ${Standing} || \
					${EVE.Standing[${Me.CorpID},${PilotITerator.Value.Owner.AllianceID}]} < ${Standing} || \
					${EVE.Standing[${Me.AllianceID},${PilotITerator.Value.Owner.AllianceID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.CharID},${Me.CharID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.CorpID},${Me.CharID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.AllianceID},${Me.CharID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.CharID},${Me.CorpID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.CorpID},${Me.CorpID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.AllianceID},${Me.CorpID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.CharID},${Me.AllianceID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.CorpID},${Me.AllianceID}]} < ${Standing} || \
					${EVE.Standing[${PilotITerator.Value.Owner.AllianceID},${Me.AllianceID}]} < ${Standing}
				{
					/* Yep, I'm laughing right now as well -- CyberTech */
					return TRUE
				}
			}
			while ${PilotIterator:Next(exists)}
			
		}
		
		return FALSE
	}
	
	member:bool PilotsWithinDetection(int Dist)
	{
		if !${This.PilotIndex.Used}
		{
			return FALSE
		}
		
		variable iterator PilotIterator
		This.PilotIndex:GetIterator[PilotIterator]
		
		if ${PilotIterator:First(exists)}
		{
			do
			{
				if (${Me.ShipID} != ${PilotIterator.Value}) && \
				!${PilotIterator.Value.Owner.ToGangMember} && \
				${PilotITerator.Value.Distance} < ${Dist}
				{
					return TRUE
				}
			}
			while ${PilotIterator:Next(exists)}
		}
		
		return FALSE
	}
	
	member:bool PossibleHostiles()
	{
		if !${This.EntityIndex.Used} && !${This.PilotIndex.Used}
		{
			return FALSE
		}
		
		variable iterator EntityIterator
		This.EntityIndex:GetIterator[EntityIterator]
		
		if ${EntityIterator:First(exists)}
		{
			do
			{
				if ${EntityIterator.Value.IsTargetingMe}
				{
					return TRUE
				}
			}
			while ${EntityIterator:Next(exists)}
		}
		
		variable iterator PilotIterator
		This.PilotIndex:GetIterator[PilotIterator]
		
		if ${PilotIterator:First(exists)}
		{
			do
			{
				if ${PilotIterator.Value.IsTargetingMe}
				{
					return TRUE
				}
			}
			while ${PilotIterator:Next(exists)}
		}
		
		return FALSE
	}
	
}
	
	