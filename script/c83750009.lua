-- Wightwarrior
-- ID: 83750009
local s, id = GetID()

local SKULL_SERVANT   = 32274490
local BATTLE_WARRIOR  = 55550921
local ZOMBIE_WARRIOR  = 31339260

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- Always treated as Warrior monster (on field)
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetRange(LOCATION_MZONE + LOCATION_HAND)
    e0:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e0)

    -- Name becomes Skull Servant in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e1)

    -- Fusion substitute for Battle Warrior: add Battle Warrior as an additional code
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_CODE)
    e2:SetRange(LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetValue(BATTLE_WARRIOR)
    c:RegisterEffect(e2)

    -- If you control a Zombie monster, can Special Summon this from hand
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.spcond)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- While in GY or banished: Zombie Warrior is also Skull Servant
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CHANGE_CODE)
    e4:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
    e4:SetTargetRange(LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED)
    e4:SetTarget(function(e, c) return c:IsCode(ZOMBIE_WARRIOR) end)
    e4:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e4)
end

function s.spcond(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsRace(RACE_ZOMBIE)
    end, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
    end
end
