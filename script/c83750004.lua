-- Wight Gemini
-- ID: 83750004
local s, id = GetID()

local SKULL_SERVANT = 32274490

s.listed_names = {SKULL_SERVANT}

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

    -- Effect (only when Gemini Summoned):
    -- You can banish this card from your field; Special Summon up to 2 Level 2 or lower
    -- Normal Monsters from your GY, except "Wight Gemini".
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end

function s.normalfilter(c, e, tp)
    return c:IsType(TYPE_NORMAL) and c:GetLevel() <= 2
        and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.normalfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, LOCATION_GRAVE)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local free = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local max = math.min(2, free)
    if max <= 0 then return end
    if not Duel.IsExistingMatchingCard(s.normalfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.normalfilter, tp, LOCATION_GRAVE, 0, 1, max, nil, e, tp)
    for tc in g:Iter() do
        if tc:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
        end
    end
    Duel.SpecialSummonComplete()
end
