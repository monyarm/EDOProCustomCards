-- Wight Maestro
-- ID: 83750013
local s, id = GetID()

local SKULL_SERVANT = 32274490

s.listed_names = {SKULL_SERVANT}

function s.isSkullOrMentions(c)
    return c:IsType(TYPE_MONSTER)
        and (c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT))
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

    -- On Normal or Special Summon: excavate top 2, send Wight/Skull Servant to GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.extg)
    e2:SetOperation(s.exop)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- Banish from GY: change Level of 1 Zombie you control by +/-1
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(0)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 100)
    e3:SetCost(s.lvcost)
    e3:SetTarget(s.lvtg)
    e3:SetOperation(s.lvop)
    c:RegisterEffect(e3)
end

function s.extg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 1 end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 2, tp, 0)
end
function s.exop(e, tp, eg, ep, ev, re, r, rp)
    -- Excavate top 2
    local g = Duel.GetDecktopGroup(tp, 2)
    if g:GetCount() == 0 then return end
    local send = Group.CreateGroup()
    local ret  = Group.CreateGroup()
    local c2 = g:GetFirst()
    while c2 do
        -- Send Wight/Skull Servant monsters to GY; rest to bottom of Deck
        if c2:IsType(TYPE_MONSTER)
            and (c2:IsCode(SKULL_SERVANT) or c2:ListsCode(SKULL_SERVANT)) then
            send:AddCard(c2)
        else
            ret:AddCard(c2)
        end
        c2 = g:GetNext()
    end
    if send:GetCount() > 0 then
        Duel.SendtoGrave(send, REASON_EFFECT)
    end
    if ret:GetCount() > 0 then
        -- Player chooses order for bottom of deck
        Duel.SendtoDeck(ret, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
    end
end

function s.lvcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost() end
    Duel.Remove(c, POS_FACEUP, REASON_COST)
end
function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(function(c) return c:IsRace(RACE_ZOMBIE) end,
            tp, LOCATION_MZONE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectMatchingCard(tp, function(c) return c:IsRace(RACE_ZOMBIE) end,
        tp, LOCATION_MZONE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        e:SetLabelObject(tc)
        Duel.SetOperationInfo(0, CATEGORY_LEVEL_CHANGE, tc, 1, 0, 0)
    end
end
function s.lvop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if not tc or not tc:IsRelateToEffect(e) then return end
    -- Ask +1 or -1
    local up = Duel.SelectYesNo(tp, aux.Stringid(id, 2)) -- yes=+1, no=-1
    local delta = up and 1 or -1
    local ne = Effect.CreateEffect(e:GetHandler())
    ne:SetType(EFFECT_TYPE_SINGLE)
    ne:SetCode(EFFECT_CHANGE_LEVEL)
    ne:SetReset(RESETS_STANDARD_PHASE_END)
    ne:SetValue(tc:GetLevel() + delta)
    tc:RegisterEffect(ne, true)
end
