if !file.Exists( "weapons/weapon_nyangun.lua", "LUA" ) then return end

local IsValid = IsValid
local CurTime = CurTime
local random = math.random
local Rand = math.Rand
local ents_Create = ents.Create
local CreateSound = CreateSound
local callbackTbl = { clipdrain = true, sound = true }
local secondaryTbl = { clipdrain = true, sound = true, damage = true, cooldown = true }
local bulletTbl = {
	Num = 6,
	TracerName = "rb655_nyan_tracer",
	Damage = 8,
	Force = 8,
	Spread = Vector( 0.233, 0.233, 0 )
}

local function KillSounds( wepent )
	if wepent.BeatSound then wepent.BeatSound:Stop(); wepent.BeatSound = nil end
	if wepent.LoopSound then wepent.LoopSound:Stop(); wepent.LoopSound = nil end
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    nyan_gun = {
        model = "models/weapons/w_smg1.mdl",
        origin = "Misc",
        prettyname = "Nyan Gun",
        killicon = "weapon_nyangun",
        holdtype = "smg",
        bonemerge = true,
        keepdistance = 400,
        attackrange = 1500,

        clip = 1,
        tracername = "rb655_nyan_tracer",
        damage = 16,
        spread = 0.133,
        rateoffire = 0.1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1,

        OnAttack = function( self, wepent, target )
			if self:IsInRange( target, 768 ) then
				local rndAttack = random( 1, 30 )
				if rndAttack == 1 then
					local ent = ents_Create( "ent_nyan_bomb" )
					if !IsValid( ent ) then return true end

					ent:SetPos( wepent:GetPos() )
					ent:SetAngles( ( target:GetPos() - wepent:GetPos() ):Angle() )
					ent:SetOwner( self )
					ent:Spawn()
					ent:Activate()
					
					local phys = ent:GetPhysicsObject()
					if IsValid( phys ) then 
						phys:Wake() 
						phys:AddVelocity( ent:GetForward() * 1337 + ( target:GetUp() * self:GetRangeTo( target ) / random( 2, 4 ) ) ) 
					end

					self.l_WeaponUseCooldown = ( CurTime() + Rand( 1.0, 1.5 ) )
					wepent:EmitSound( "weapons/nyan/nya" .. random( 2 ) .. ".wav", 100, random( 60, 80 ) )

                    self:CallOnRemove( "LambdaNyanGun_SetBombOwner_" .. ent:EntIndex(), function()
                    	if !IsValid( ent ) then return end
                    	ent:SetOwner( Entity( 0 ) )
                    end )

					return secondaryTbl
				elseif rndAttack == 30 then
					self.l_WeaponUseCooldown = ( CurTime() + Rand( 0.5, 0.8 ) )
					wepent:EmitSound( "weapons/nyan/nya" .. random( 2 ) .. ".wav", 100, random( 85, 100 ) )

					bulletTbl.Attacker = self
					bulletTbl.IgnoreEntity = self
					bulletTbl.Src = wepent:GetPos()
					bulletTbl.Dir = ( target:WorldSpaceCenter() - bulletTbl.Src ):GetNormalized()
					wepent:FireBullets( bulletTbl )

					return secondaryTbl
				end
			end

			if wepent.LoopSound then
				wepent.LoopSound:ChangeVolume( 1, 0.1 )
			else
				wepent.LoopSound = CreateSound( wepent, "weapons/nyan/nyan_loop.wav" )
				if wepent.LoopSound then wepent.LoopSound:Play() end
			end
			if wepent.BeatSound then wepent.BeatSound:ChangeVolume( 0, 0.1 ) end

			wepent.LoopSoundPlayTime = ( CurTime() + 0.2 )
            return callbackTbl
        end,

        OnDeploy = function( self, wepent )
			wepent.BeatSound = CreateSound( wepent, "weapons/nyan/nyan_beat.wav" )
			if wepent.BeatSound then wepent.BeatSound:Play() end

			wepent.LoopSoundPlayTime = CurTime()
			wepent:CallOnRemove( "LambdaNyanGun_KillSoundsOnRemove_" .. wepent:EntIndex(), KillSounds )
        end,

        OnHolster = function( self, wepent )
        	KillSounds( wepent )

        	wepent.LoopSoundPlayTime = nil
        	wepent:RemoveCallOnRemove( "LambdaNyanGun_KillSoundsOnRemove_" .. wepent:EntIndex() )
        end,

        OnThink = function( self, wepent, isdead )
        	if isdead or wepent:GetNoDraw() then
				if wepent.LoopSound then wepent.LoopSound:ChangeVolume( 0, 0.1 ) end
				if wepent.BeatSound then wepent.BeatSound:ChangeVolume( 0, 0.1 ) end
        	elseif CurTime() > wepent.LoopSoundPlayTime then
				if wepent.LoopSound then wepent.LoopSound:ChangeVolume( 0, 0.1 ) end
				if wepent.BeatSound then wepent.BeatSound:ChangeVolume( 1, 0.1 ) end
			end
        end,

        islethal = true
    }
} )