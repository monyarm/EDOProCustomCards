-- Call of the Bone Sovereign
-- ID: 83750007
local s, id = GetID()

local WIGHTARCANIST = 83750014
local SKULL_SERVANT = 32274490
local KING_OF_SKULL = 36021814
local ZOMBIE_WORLD  = 4064256

s.listed_names = {WIGHTARCANIST, SKULL_SERVANT, KING_OF_SKULL, ZOMBIE_WORLD}

function s.sprfilter(c, e, tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL)
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, false)
end
function s.oppzombie(c)
    return c:IsRace(RACE_ZOMBIE)
end
function s.zombieworld(c)
    return c:IsCode(ZOMBIE_WORLD)
end

function s.initial_effect(c)
    -- Effect 1: Ritual Summon activation
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Effect 2: When Wightarcanist is tributed/destroyed while face-up, shuffle this card from GY into Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY, EFFECT_FLAG2_CHECK_SIMULTANEOUS)
    e2:SetCode(EVENT_RELEASE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.shufflecond)
    e2:SetTarget(s.shuffletg)
    e2:SetOperation(s.shuffleop)
    c:RegisterEffect(e2)
    -- Also fires on destruction (but not on tribute, which fires EVENT_RELEASE above)
    local e3 = e2:Clone()
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.shufflecond_destroy)
    c:RegisterEffect(e3)
end

function s.shufflecond(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(function(c)
        return c:GetOriginalCode() == WIGHTARCANIST
            and c:IsPreviousPosition(POS_FACEUP)
            and c:IsPreviousControler(tp)
            and c:IsPreviousLocation(LOCATION_MZONE)
    end, 1, nil)
        and not eg:IsContains(e:GetHandler())
end

function s.shufflecond_destroy(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(function(c)
        return c:GetOriginalCode() == WIGHTARCANIST
            and c:IsPreviousPosition(POS_FACEUP)
            and c:IsPreviousControler(tp)
            and c:IsPreviousLocation(LOCATION_MZONE)
            and not c:IsReason(REASON_RELEASE)
    end, 1, nil)
        and not eg:IsContains(e:GetHandler())
end

function s.shuffletg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, tp, 0)
end

function s.shuffleop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.HintSelection(c)
        Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end

function s.get_available_level(tp, tc, e)
    local total = 0
    -- Field Zombie monsters
    local fldg = Duel.GetMatchingGroup(function(c)
        return c:IsRace(RACE_ZOMBIE) and c:IsCanBeRitualMaterial(tc)
    end, tp, LOCATION_MZONE, 0, tc)
    local c2 = fldg:GetFirst()
    while c2 do total = total + c2:GetLevel(); c2 = fldg:GetNext() end
    -- Hand Skull Servant-named (exclude tc itself)
    local hndg = Duel.GetMatchingGroup(function(c)
        return c ~= tc and (c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT))
    end, tp, LOCATION_HAND, 0, nil)
    c2 = hndg:GetFirst()
    while c2 do total = total + c2:GetLevel(); c2 = hndg:GetNext() end
    -- GY Skull Servant-named: capped at king_count + 1
    local king_count = Duel.GetMatchingGroupCount(function(c)
        return c:IsCode(KING_OF_SKULL) and c:IsFaceup()
    end, tp, LOCATION_MZONE, 0, nil)
    local max_gy = king_count + 1
    local gyg = Duel.GetMatchingGroup(function(c)
        return c:IsType(TYPE_MONSTER)
            and (c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT))
    end, tp, LOCATION_GRAVE, 0, nil)
    local gy_used = 0
    c2 = gyg:GetFirst()
    while c2 and gy_used < max_gy do
        total = total + c2:GetLevel()
        gy_used = gy_used + 1
        c2 = gyg:GetNext()
    end
    -- Zombie World bonus
    local has_zworld = Duel.IsExistingMatchingCard(s.zombieworld, tp,
        LOCATION_SZONE, LOCATION_SZONE, 1, nil)
    local has_opp_zombie = Duel.IsExistingMatchingCard(s.oppzombie, tp,
        0, LOCATION_MZONE, 1, nil)
    if has_zworld and has_opp_zombie then
        local oppg = Duel.GetMatchingGroup(s.oppzombie, tp, 0, LOCATION_MZONE, nil)
        local best = 0
        c2 = oppg:GetFirst()
        while c2 do
            if c2:GetLevel() > best then best = c2:GetLevel() end
            c2 = oppg:GetNext()
        end
        total = total + best
    end
    return total
end

function s.can_summon(e, tp)
    -- Check if any valid ritual monster has materials available to meet its level
    local rituals = Duel.GetMatchingGroup(s.sprfilter, tp, LOCATION_HAND, 0, nil, e, tp)
    local tc = rituals:GetFirst()
    while tc do
        if s.get_available_level(tp, tc, e) >= tc:GetLevel() then
            return true
        end
        tc = rituals:GetNext()
    end
    return false
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and s.can_summon(e, tp)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.can_summon(e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    -- Only show ritual monsters the player actually has materials for
    local g = Duel.SelectMatchingCard(tp, function(c)
        return s.sprfilter(c, e, tp)
            and s.get_available_level(tp, c, e) >= c:GetLevel()
    end, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    if tc then
        e:SetLabelObject(tc)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, 0, 0)
    end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if not tc then return end
    local lv = tc:GetLevel()

    -- Build combined material pool
    local mg = Group.CreateGroup()

    -- Own field Zombie monsters
    local fldg = Duel.GetMatchingGroup(function(c)
        return c:IsRace(RACE_ZOMBIE) and c:IsCanBeRitualMaterial(tc)
    end, tp, LOCATION_MZONE, 0, tc)
    mg:Merge(fldg)

    -- Hand: Skull Servant-named (exclude tc itself)
    local hndg = Duel.GetMatchingGroup(function(c)
        return c ~= tc and (c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT))
    end, tp, LOCATION_HAND, 0, nil)
    mg:Merge(hndg)

    -- GY: Skull Servant-named, capped at king_count + 1
    local king_count = Duel.GetMatchingGroupCount(function(c)
        return c:IsCode(KING_OF_SKULL) and c:IsFaceup()
    end, tp, LOCATION_MZONE, 0, nil)
    local max_gy = king_count + 1
    local gyg_all = Duel.GetMatchingGroup(function(c)
        return c:IsType(TYPE_MONSTER)
            and (c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT))
    end, tp, LOCATION_GRAVE, 0, nil)
    local gyg = Group.CreateGroup()
    local gy_added = 0
    local gc = gyg_all:GetFirst()
    while gc and gy_added < max_gy do
        gyg:AddCard(gc)
        gy_added = gy_added + 1
        gc = gyg_all:GetNext()
    end
    mg:Merge(gyg)

    -- Zombie World bonus: include opponent's Zombies in pool
    if Duel.IsExistingMatchingCard(s.zombieworld, tp, LOCATION_SZONE, LOCATION_SZONE, 1, nil) then
        mg:Merge(Duel.GetMatchingGroup(s.oppzombie, tp, 0, LOCATION_MZONE, nil))
    end

    -- SelectWithSumGreater requires every card to have a non-zero value
    mg = mg:Filter(function(c) return c:GetLevel() > 0 end, nil)
    if mg:GetCount() == 0 then return end

    -- Select materials: stops once total levels reach the ritual monster's level
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TRIBUTE)
    local mat = mg:SelectWithSumGreater(tp, Card.GetLevel, lv, nil)
    if not mat or mat:GetCount() == 0 then return end

    -- Send materials: GY cards are banished; field/hand cards go to GY
    local gy_mat = mat:Filter(function(c) return c:IsLocation(LOCATION_GRAVE) end, nil)
    local other_mat = mat:Clone()
    other_mat:Sub(gy_mat)
    if other_mat:GetCount() > 0 then
        Duel.SendtoGrave(other_mat, REASON_COST + REASON_EFFECT)
    end
    if gy_mat:GetCount() > 0 then
        Duel.Remove(gy_mat, POS_FACEUP, REASON_COST + REASON_EFFECT)
    end

    -- Ritual Summon
    Duel.BreakEffect()
    if tc:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, false) then
        Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP_ATTACK)
        tc:CompleteProcedure()
    end
end
