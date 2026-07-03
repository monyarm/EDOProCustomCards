-- Wight-o'-the-Wisp
-- ID: 83750012
local s, id = GetID()

local SKULL_SERVANT = 32274490
local KING_OF_SKULL = 36021814

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- Cannot be Special Summoned
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)

    -- Spirit: return to hand during End Phase of the turn summoned/flipped
    Spirit.AddProcedure(c, EVENT_SUMMON_SUCCESS, EVENT_FLIP_SUMMON_SUCCESS, EVENT_FLIP)

    -- Name becomes Skull Servant in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e1)

    -- Hand effect: When a Skull Servant / King you control would be destroyed,
    -- discard this instead; then mill 2.
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end

function s.repfilter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
        and (c:IsCode(SKULL_SERVANT) or c:IsCode(KING_OF_SKULL))
        and c:IsReason(REASON_BATTLE + REASON_EFFECT)
        and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return eg:IsExists(s.repfilter, 1, nil, tp) end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then return false end
    -- Select one skull/king from the destruction group to save
    local g = eg:Filter(s.repfilter, nil, tp)
    local tc
    if g:GetCount() > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
        local sel = Duel.SelectMatchingCard(tp, function(mc) return g:IsContains(mc) end,
            tp, LOCATION_MZONE, 0, 1, 1, nil)
        tc = sel:GetFirst()
    else
        tc = g:GetFirst()
    end
    e:SetLabelObject(tc)
    return true
end
function s.repval(e, c)
    return c == e:GetLabelObject()
end
function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
    -- Mill 2
    local g = Duel.GetDecktopGroup(tp, 2)
    if g:GetCount() > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
