-- Wightshield Paladin
-- ID: 83750011
local s, id = GetID()

local SKULL_SERVANT = 32274490

s.listed_names = {SKULL_SERVANT}

function s.zombiefilter(tc)
    return tc:IsRace(RACE_ZOMBIE)
end

function s.initial_effect(c)
    -- Name becomes Skull Servant in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e1)

    -- Union equip/unequip/destroy substitution
    Auxiliary.AddUnionProcedure(c, s.zombiefilter, false, false)

    -- When sent from field to GY while equipped: mill 1
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.millcond)
    e2:SetTarget(s.milltg)
    e2:SetOperation(s.millop)
    c:RegisterEffect(e2)
end

function s.millcond(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Was equipped (in SZONE) and sent to GY
    return c:IsLocation(LOCATION_GRAVE)
        and c:IsPreviousLocation(LOCATION_SZONE)
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
