-- Wightbrarian
-- ID: 83750018
local s, id = GetID()

local POLYMERIZATION = 24094653
local SET_FUSION = 0x46
local SKULL_SERVANT = 32274490

s.listed_names = {POLYMERIZATION, SKULL_SERVANT}

function s.initial_effect(c)
    -- Discard; reveal 1 Zombie Fusion in Extra Deck; add referenced monster or Fusion Spell/Trap
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- If sent to GY: add 1 Spell/Trap that mentions "Skull Servant", and it cannot be activated this turn
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.reccon)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
end

function s.zombiefusionfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_FUSION)
end

function s.zombiefusionthfilter(c, tp)
    return s.zombiefusionfilter(c)
        and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, c)
end

function s.isfusionst(c)
    if not (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) then return false end
    return c:IsCode(POLYMERIZATION) or c:IsSetCard(SET_FUSION)
end

function s.thfilter(c, fc)
    if not c:IsAbleToHand() then return false end
    if s.isfusionst(c) then return true end
    return c:IsType(TYPE_MONSTER) and fc:ListsCode(c:GetCode())
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.zombiefusionthfilter, tp, LOCATION_EXTRA, 0, 1, nil, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local fg = Duel.SelectMatchingCard(tp, s.zombiefusionthfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, tp)
    local tc = fg:GetFirst()
    if not tc then return end
    Duel.ConfirmCards(1 - tp, fg)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, tc)
    local sc = g:GetFirst()
    if sc then
        Duel.SendtoHand(sc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sc)
    end
end

function s.reccon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE)
end

function s.recfilter(c)
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:ListsCode(SKULL_SERVANT) and c:IsAbleToHand()
end

function s.rectg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.recfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.recop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.recfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)

        -- Mark the exact added card, then prevent activating that marked card this turn.
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetTargetRange(1, 0)
        e1:SetValue(function(_, re2, _tp)
            local rc = re2:GetHandler()
            return rc and rc:GetFlagEffect(id) > 0
        end)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
