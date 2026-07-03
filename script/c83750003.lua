-- Wight Dual-Burial
-- ID: 83750003
local s, id = GetID()

local SKULL_SERVANT = 32274490
s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
        and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 1
end

function s.geminifilter(c)
    return c:IsType(TYPE_GEMINI) and c:IsFaceup() and c:CanSummonOrSet(true, nil)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 1
    end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetDecktopGroup(tp, 1)
    if g:GetCount() == 0 then return end

    -- Reveal excavated card to both players
    Duel.ConfirmCards(1 - tp, g)

    local tc = g:GetFirst()
    if tc:IsType(TYPE_MONSTER) and tc:IsRace(RACE_ZOMBIE) then
        -- Send the Zombie to GY
        Duel.SendtoGrave(tc, REASON_EFFECT)
        -- Bonus: immediately Normal Summon 1 Gemini monster from your field
        if Duel.IsExistingMatchingCard(s.geminifilter, tp, LOCATION_MZONE, 0, 1, nil) then
            if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
                local sg = Duel.SelectMatchingCard(tp, s.geminifilter, tp,
                    LOCATION_MZONE, 0, 1, 1, nil)
                local sc = sg:GetFirst()
                if sc and sc:CanSummonOrSet(true, nil) then
                    Duel.SummonOrSet(tp, sc, true, nil)
                end
            end
        end
    else
        -- Shuffle it back
        Duel.ShuffleDeck(tp)
    end
end
