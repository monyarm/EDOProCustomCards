-- Wightdissolver
-- ID: 83750008
local s, id = GetID()

local SKULL_SERVANT  = 32274490
local DISSOLVEROCK   = 40826495
local FLAME_GHOST    = 58528964

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- Always treated as Rock monster (on field)
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetRange(LOCATION_MZONE + LOCATION_HAND)
    e0:SetValue(RACE_ROCK)
    c:RegisterEffect(e0)

    -- Name becomes Skull Servant in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e1)

    -- Fusion substitute for Dissolverock: add Dissolverock as an additional code
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_CODE)
    e2:SetRange(LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetValue(DISSOLVEROCK)
    c:RegisterEffect(e2)

    -- When sent to GY for Fusion Summon of Zombie: mill 2
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.millcond)
    e3:SetTarget(s.milltg)
    e3:SetOperation(s.millop)
    c:RegisterEffect(e3)

    -- While in GY or banished: Flame Ghost is also Skull Servant
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CHANGE_CODE)
    e4:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
    e4:SetTargetRange(LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_MZONE + LOCATION_GRAVE + LOCATION_REMOVED)
    e4:SetTarget(function(e, c) return c:IsCode(FLAME_GHOST) end)
    e4:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e4)
end

function s.millcond(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE)
        and r == REASON_FUSION
        and eg:IsExists(function(mc) return mc:IsRace(RACE_ZOMBIE) end, 1, nil)
end
function s.milltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 1 end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 2, tp, 0)
end
function s.millop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetDecktopGroup(tp, 2)
    if g:GetCount() > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
