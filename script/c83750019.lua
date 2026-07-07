-- Wight Desperado
-- ID: 83750019
local s, id = GetID()

local SKULL_SERVANT = 32274490

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- If Normal Summoned: shuffle 1 Zombie or Spell from GY to Deck, draw 1
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sumtg)
    e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)
    
    -- If Special Summoned: shuffle 1 Zombie or Spell from GY to Deck, draw 1
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)
    
    -- If flipped face-up: shuffle 1 Zombie or Spell from GY to Deck, draw 1
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_FLIP)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.sumtg)
    e3:SetOperation(s.sumop)
    c:RegisterEffect(e3)

    -- Banish from GY: shuffle 1 Skull Servant mention and 1 Zombie/Spell from GY to Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 100)
    e2:SetCost(s.bncost)
    e2:SetTarget(s.bntg)
    e2:SetOperation(s.bnop)
    c:RegisterEffect(e2)
end

function s.sumfilter(c)
    return (c:IsRace(RACE_ZOMBIE) or c:IsType(TYPE_SPELL)) and c:IsAbleToDeck()
end

function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 1, tp, 0)
end

function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        if Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
            Duel.ShuffleDeck(tp)
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end

function s.bncost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToRemove() end
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.skullfilter(c)
    return c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT)
end

function s.bnzombiefilter(c)
    return (c:IsRace(RACE_ZOMBIE) or c:IsType(TYPE_SPELL)) and c:IsAbleToDeck()
end

function s.bntg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return false
    end
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.skullfilter, tp, LOCATION_GRAVE, 0, 1, nil)
            and Duel.IsExistingMatchingCard(s.bnzombiefilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 2))
    local g1 = Duel.SelectMatchingCard(tp, s.skullfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    e:SetLabelObject(g1:GetFirst())
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 3))
    local g2 = Duel.SelectMatchingCard(tp, s.bnzombiefilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    e:SetLabel(g2:GetFirst():GetFieldID())
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g1:Merge(g2), 2, tp, LOCATION_GRAVE)
end

function s.bnop(e, tp, eg, ep, ev, re, r, rp)
    local c1 = e:GetLabelObject()
    if not c1 then return end
    local fid = e:GetLabel()
    local g = Group.CreateGroup()
    g:AddCard(c1)
    
    local gc = Duel.GetMatchingGroup(s.bnzombiefilter, tp, LOCATION_GRAVE, 0, nil)
    for tc in aux.Next(gc) do
        if tc:GetFieldID() == fid then
            g:AddCard(tc)
            break
        end
    end
    
    if #g == 2 then
        Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end
