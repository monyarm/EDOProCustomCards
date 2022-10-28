-- Gem-Paladin Draco Knight
local s, id = GetID()
function s.initial_effect(c)
    -- fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x1047), s.ffilter)
    -- special summon condition
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.fuslimit)
    c:RegisterEffect(e1)

    -- send replace
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetCondition(s.repcon)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)

    -- atkup
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.val)
    c:RegisterEffect(e3)

    -- copy effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_MATERIAL_CHECK)
    e4:SetOperation(s.effcop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x2034, 0x1047, 0x1034}
s.listed_names = {86346643}
s.material_setcode = {0x34, 0x1034, 0x2034, 0x47, 0x1047}
function s.effcop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler();
    local g = c:GetMaterial()
    for tc in g:Iter() do
        if tc:IsSetCard(0x1047) and Card.IsControler(tc, 1 - c:GetController()) then
            c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1)
        end
    end
end
function s.ffilter(c, fc, sumtype, tp)
    return -- (c:IsSetCard(0x1043),7) or 
    c:IsSetCard(0x2043) or c:IsCode(86346643)
end
function s.filtergem(c)
    return c:IsSetCard(0x1047) and c:IsMonster()
end
function s.filtercr(c)
    return c:IsSetCard(0x1034)
end
function s.val(e, c)
  local gem1=Duel.GetMatchingGroupCount(s.filtergem, c:GetControler(), LOCATION_GRAVE, LOCATION_GRAVE, nil)
  local gem2=Duel.GetMatchingGroupCount(s.filtergem, c:GetControler(), 0, LOCATION_ONFIELD, nil)
  local crystal1= Duel.GetMatchingGroupCount(s.filtercr, c:GetControler(), LOCATION_GRAVE, LOCATION_GRAVE, nil)
  local crystal2=Duel.GetMatchingGroupCount(s.filtercr, c:GetControler(), LOCATION_SZONE, 0, nil)
  
  local total= gem1 + gem2 + crystal1 + crystal2
  return total*100
end
function s.repcon(e)
    local c = e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
    e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
    c:RegisterEffect(e1)
    Duel.RaiseEvent(c, EVENT_CUSTOM + 47408488, e, 0, tp, 0, 0)
end
