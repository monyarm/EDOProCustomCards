-- Wight Plunderer
-- ID: 83750006
local s, id = GetID()

local SKULL_SERVANT = 32274490

s.listed_names = {SKULL_SERVANT}

-- Gemini support Spell/Trap IDs
local GEMINI_SUPPORT = {
    33846209, -- Gemini Spark
    18096222, -- Gemini Booster
    81601517, -- Gemini Counter
    80758812, -- Gemini Ablation    
    67045174, -- Gemini Trap Hole
    26120084, -- Super Double Summon
    73567374, -- Unleash Your Power!
    57441100, -- Herculean Power
    95750695, -- Supervise
    65959844, -- Catalyst Field
}

function s.initial_effect(c)
    -- Gemini summon mechanics
    Gemini.AddProcedure(c)

    -- Name becomes Skull Servant in GY
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_GRAVE)
    e0:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e0)

    -- Discard 1 card; add 1 Spell/Trap from Deck that mentions Skull Servant or Gemini
    -- (only when Gemini Summoned)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(Gemini.EffectStatusCondition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(
        function(c) return c:IsDiscardable() end, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local g = Duel.SelectMatchingCard(tp, function(c) return c:IsDiscardable() end,
        tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

function s.isgeminisupport(c)
    for _, code in ipairs(GEMINI_SUPPORT) do
        if c:IsCode(code) then return true end
    end
    return false
end

function s.stfilter(c)
    return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
        and (c:ListsCode(SKULL_SERVANT) or s.isgeminisupport(c))
        and c:IsAbleToHand()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.stfilter, tp,
            LOCATION_DECK | LOCATION_GRAVE, LOCATION_DECK | LOCATION_GRAVE, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, PLAYER_ALL,
        LOCATION_DECK | LOCATION_GRAVE)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.stfilter, tp,
        LOCATION_DECK | LOCATION_GRAVE, LOCATION_DECK | LOCATION_GRAVE, 1, 1, nil)
    if g:GetCount() > 0 then
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
