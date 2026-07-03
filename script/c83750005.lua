-- Wight Militia
-- ID: 83750005
local s, id = GetID()

local SKULL_SERVANT = 32274490
local KING_OF_SKULL = 36021814

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

    -- ATK gain: +100 per Skull Servant / King in GY (only when Gemini Summoned)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- If destroys by battle: Special Summon 1 Normal Monster from GY (only when Gemini Summoned)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.btlcond)
    e2:SetTarget(s.btltg)
    e2:SetOperation(s.btlop)
    c:RegisterEffect(e2)
end

function s.atkval(e, c)
    -- Only applies when this card is in Gemini Summoned state
    local owner = e:GetHandler()
    if not owner:IsGeminiStatus() or owner:IsDisabled() then return 0 end
    local tp = c:GetControler()
    local cnt = Duel.GetMatchingGroupCount(function(mc)
        return mc:IsCode(SKULL_SERVANT) or mc:IsCode(KING_OF_SKULL)
    end, tp, LOCATION_GRAVE, 0, nil)
    return cnt * 100
end

function s.btlcond(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsGeminiStatus()
end

function s.normalfilter(c, e, tp)
    return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.btltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
            and s.normalfilter(chkc, e, tp)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.normalfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.normalfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.btlop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
    end
end
