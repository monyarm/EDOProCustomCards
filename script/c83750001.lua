-- Custom Card: Wight Scraps
-- ID: 83750001
local s, id = GetID()

function s.initial_effect(c)
    -- Synchro Summon procedure
    c:EnableReviveLimit()
    -- Material requirement: 1 Zombie Tuner + 1 "Skull Servant" or monster that mentions it
    Synchro.AddProcedure(c, s.tfilter, 1, 1, Synchro.NonTuner(s.matfilter), 1, 99, s.syncheck)
    
    -- Synchro Condition: Treat 1 "Skull Servant" you control as a Tuner
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetTarget(s.syntg)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Name becomes "Skull Servant" in GY
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetValue(CARD_SKULL_SERVANT)
    c:RegisterEffect(e2)

    -- If Synchro Summoned: Send top 2 cards of Deck to GY
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DECKDES + CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.millcond1)
    e3:SetTarget(s.milltg1)
    e3:SetOperation(s.millop1)
    c:RegisterEffect(e3)

    -- End Phase: Send top card of Deck to GY (except turn it was summoned)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DECKDES + CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id + 100)
    e4:SetCondition(s.millcond2)
    e4:SetTarget(s.milltg2)
    e4:SetOperation(s.millop2)
    c:RegisterEffect(e4)

    -- Change target to this card (Quick Effect)
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id + 200)
    e5:SetCondition(s.tgcond)
    e5:SetOperation(s.tgop)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EVENT_BE_BATTLE_TARGET)
    e5b:SetCondition(s.atkcond)
    e5b:SetOperation(s.atkop)
    c:RegisterEffect(e5b)

    -- Negate attack or effect that targets this card (Quick Effect)
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_NEGATE)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_CHAINING)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1, id + 300)
    e6:SetCondition(s.negcond)
    e6:SetTarget(s.negtg)
    e6:SetOperation(s.negop)
    c:RegisterEffect(e6)
    local e6b = e6:Clone()
    e6b:SetCode(EVENT_BE_BATTLE_TARGET)
    e6b:SetCondition(s.negatkcond)
    e6b:SetTarget(s.negatktg)
    e6b:SetOperation(s.negatkop)
    c:RegisterEffect(e6b)
end

-- Synchro Helpers
function s.tfilter(c, scard, sumtype, tp)
    return c:IsRace(RACE_ZOMBIE, scard, sumtype, tp) or c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
end

function s.matfilter(c, scard, sumtype, tp)
    return c:IsCode(CARD_SKULL_SERVANT) or c:ListsCode(CARD_SKULL_SERVANT)
end

function s.syncheck(g, sc, tp)
    return true
end

-- Custom Synchro Material: Treat 1 "Skull Servant" as a Tuner
function s.syntg(e, c, tuner, mg)
    if not mg then return false end
    local tp = c:GetControler()
    return mg:IsExists(Card.IsCode, 1, nil, CARD_SKULL_SERVANT)
end

-- Effect 3: Mill 2 on Synchro Summon
function s.millcond1(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.milltg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 2, tp, LOCATION_DECK)
end
function s.millop1(e, tp, eg, ep, ev, re, r, rp)
    Duel.DiscardDeck(tp, 2, REASON_EFFECT)
end

-- Effect 4: End Phase Mill 1
function s.millcond2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and e:GetHandler():GetTurnID() ~= Duel.GetTurnCount()
end
function s.milltg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function s.millop2(e, tp, eg, ep, ev, re, r, rp)
    Duel.DiscardDeck(tp, 1, REASON_EFFECT)
end

-- Effect 5: Redirection (Card Effect)
function s.tgfilter(c, tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(3)
end
function s.tgcond(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return g and g:IsExists(s.tgfilter, 1, e:GetHandler(), tp) and Duel.CheckChainTarget(ev, e:GetHandler())
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.CheckChainTarget(ev, c) then
        local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
        -- Remove the old target(s) that matched our filter and replace with this card
        local tg = g:Filter(s.tgfilter, nil, tp)
        for tc in aux.Next(tg) do
            Duel.ChangeChainTarget(ev, Group.FromCards(c))
        end
    end
end

-- Effect 5b: Redirection (Attack)
function s.atkcond(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttackTarget()
    return tc and tc:IsControler(tp) and tc:IsRace(RACE_ZOMBIE) and tc:IsLevelBelow(3) and tc ~= e:GetHandler()
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_ATTACK_CANCELED) then
        Duel.ChangeAttackTarget(c)
    end
end

-- Effect 6: Negate Card Effect targeting this card
function s.negcond(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return g and g:IsContains(e:GetHandler()) and Duel.IsChainNegatable(ev)
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        -- Optional: you can add destruction here if you want, but your text just says "negate that effect".
    end
end

-- Effect 6b: Negate Attack targeting this card
function s.negatkcond(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttackTarget() == e:GetHandler()
end
function s.negatktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
end
function s.negatkop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
end
