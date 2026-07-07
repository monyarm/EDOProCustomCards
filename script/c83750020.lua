-- Grand Necro-Archive
-- ID: 83750020
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, s.normfilter, s.fusfilter, s.synfilter, s.ritfilter)

    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_LOSE_DECK)
    e2:SetRange(LOCATION_MZONE | LOCATION_GRAVE)
    e2:SetCondition(s.losecon)
    e2:SetTargetRange(1, 0)
    c:RegisterEffect(e2)

    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetTarget(s.tglimit)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.tdcon)
    e4:SetTarget(s.tdtg)
    e4:SetOperation(s.tdop)
    c:RegisterEffect(e4)

    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_TODECK)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetTarget(s.rtdtg)
    e5:SetOperation(s.rtdop)
    c:RegisterEffect(e5)
end

function s.normfilter(c, fc, sumtype, tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_NORMAL)
end

function s.fusfilter(c, fc, sumtype, tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_FUSION)
end

function s.synfilter(c, fc, sumtype, tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO)
end

function s.ritfilter(c, fc, sumtype, tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL)
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(Card.IsRace, c:GetControler(), LOCATION_GRAVE, LOCATION_GRAVE, nil, RACE_ZOMBIE) * 100
end

function s.losecon(e)
    local c = e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()
end

function s.tglimit(e, c)
    return c ~= e:GetHandler() and c:IsRace(RACE_ZOMBIE)
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.tdfilter(c)
    return c:IsAbleToDeck()
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.tdfilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.tdfilter, tp, LOCATION_GRAVE, 0, 1, math.min(3, Duel.GetMatchingGroupCount(s.tdfilter, tp, LOCATION_GRAVE, 0, nil)), nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g == 0 then return end
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    if og:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end
end

function s.rtdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetMatchingGroupCount(s.tdfilter, tp, LOCATION_GRAVE, 0, nil) >= 5
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 5, tp, LOCATION_GRAVE)
end

function s.rtdop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.tdfilter, tp, LOCATION_GRAVE, 0, nil)
    if #g < 5 then return end
    local rg = g:RandomSelect(tp, 5)
    Duel.SendtoDeck(rg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    if og:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end
end