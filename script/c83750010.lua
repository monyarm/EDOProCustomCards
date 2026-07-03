-- Haunting Wight
-- ID: 83750010
local s, id = GetID()

local SKULL_SERVANT = 32274490
local FLAG_HAUNTING = 0x83750010  -- flag to track this-way summon

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- When opponent's monster declares attack: Special Summon this as Effect Monster
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Name becomes Skull Servant in GY
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e2)

    -- If summoned this way and sent to GY: mill 1
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.millcond)
    e3:SetTarget(s.milltg)
    e3:SetOperation(s.millop)
    c:RegisterEffect(e3)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    -- tp is the defender (trap owner); turn player is the attacker
    return tp == 1 - Duel.GetTurnPlayer()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0, TYPE_MONSTER + TYPE_EFFECT + TYPE_TRAP, 0, 0, 1, RACE_ZOMBIE, ATTRIBUTE_DARK)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    -- Summon as Effect Monster, Zombie, DARK, Level 1, ATK 0, DEF 0
    -- (stats defined in CDB; we just summon and mark the flag)
    c:AddMonsterAttribute(TYPE_EFFECT + TYPE_TRAP)
    if Duel.SpecialSummonStep(c, 0, tp, tp, true, false, POS_FACEUP_DEFENCE) then
        c:RegisterFlagEffect(FLAG_HAUNTING, RESET_PHASE + PHASE_END, 0, 1)
    end
    c:AddMonsterAttributeComplete()
    Duel.SpecialSummonComplete()
end

-- Mill 1 condition: was summoned by this effect
function s.millcond(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE)
        and (c:GetFlagEffectLabel(FLAG_HAUNTING) or 0) > 0
end
function s.milltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 1 end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, 0)
end
function s.millop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetDecktopGroup(tp, 1)
    if g:GetCount() > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
