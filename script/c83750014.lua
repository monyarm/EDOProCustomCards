-- Wightarcanist
-- ID: 83750014
local s, id = GetID()

local SKULL_SERVANT = 32274490
local KING_OF_SKULL = 36021814
local BONE_SOVEREIGN = 83750007

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- Name becomes Skull Servant in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e1)

    -- ATK gain: +500 per Skull Servant / King in GY
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- DEF gain: same
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    -- On Ritual Summon: OPT return 1 banished Wight/Skull Servant to GY
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.ritcond)
    e4:SetTarget(s.rettg)
    e4:SetOperation(s.retop)
    c:RegisterEffect(e4)
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(Card.IsCode, c:GetControler(), LOCATION_GRAVE, 0, nil, SKULL_SERVANT, KING_OF_SKULL) * 500
end

function s.ritcond(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.banishedwight(c)
    if not c:IsType(TYPE_MONSTER) then return false end
    if c:IsCode(SKULL_SERVANT) then return true end
    if not c:IsFaceup() then return false end
    return c:ListsCode(SKULL_SERVANT)
end

function s.rettg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp)
            and s.banishedwight(chkc)
    end
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.banishedwight, tp, LOCATION_REMOVED, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.banishedwight, tp, LOCATION_REMOVED, 0, 1, 1, nil)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)
end
function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    local tc = g:GetFirst()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoGrave(tc, REASON_EFFECT)
    end
end
