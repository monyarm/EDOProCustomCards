-- Grave Tithe
-- ID: 83750017
local s, id = GetID()

function s.initial_effect(c)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Must be able to discard a non-Zombie card (monster, spell, or trap)
function s.discardfilter(c)
    return not (c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE)) and c:IsDiscardable()
end

-- Target: 1 Zombie monster OR 1 Spell from GY
function s.gyfilter(c)
    return (c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE))
        or (c:IsType(TYPE_SPELL))
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.discardfilter, tp, LOCATION_HAND, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.gyfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.discardfilter, tp, LOCATION_HAND, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local g = Duel.SelectMatchingCard(tp, s.discardfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.gyfilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.gyfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        e:SetLabelObject(tc)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, tc, 1, 0, 0)
    end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_GRAVE) and tc:IsAbleToHand() then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    end
end
