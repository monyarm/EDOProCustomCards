-- Ojama Gold
local s, id = GetID()
function s.initial_effect(c)
  -- effects
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
  --Direct attack
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DIRECT_ATTACK)
  c:RegisterEffect(e1)
  --Reduce damage
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
  e3:SetCondition(s.rdcon)
  e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
  c:RegisterEffect(e3)


  
end
s.listed_series={0xf}
s.listed_names={13685271, 55008284, 86780027, 1033312, 8608979, 20513882}
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and (c:IsSetCard(0xf) or c:IsCode(13685271) or c:IsCode(55008284) or c:IsCode(86780027) or c:IsCode(1033312) or c:IsCode(20513882) or c:IsCode(8608979))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
	end
end

function s.rdcon(e)
  local c,tp=e:GetHandler(),e:GetHandlerPlayer()
  return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
      and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end