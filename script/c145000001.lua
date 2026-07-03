--月光狼
--Lunalight Wolf
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon
	local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_LUNALIGHT),matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),
					extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratarget}
	--Piercing damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.ptg)
	c:RegisterEffect(e3)
end
s.listed_series={SET_LUNALIGHT}
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.ptg(e,c)
	return c:IsSetCard(SET_LUNALIGHT) and c:IsMonster()
end
