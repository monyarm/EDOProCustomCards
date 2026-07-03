-- Wight Amalgamation
-- ID: 83750016
local s, id = GetID()

local SKULL_SERVANT = 32274490
local ZOMBIE_WORLD  = 4064256
local REQUIRED_MAT  = 5

s.listed_names = {SKULL_SERVANT}

function s.matfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER)
end
function s.oppmatfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function s.skullfilter(c)
    return c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT)
end
function s.zombieworld(c)
    return c:IsCode(ZOMBIE_WORLD)
end

function s.initial_effect(c)
    -- Contact Fusion: Ignition from MZONE to special summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.sumcond)
    e1:SetTarget(s.sumtg)
    e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)

    -- NOTE: "counts as half-level monsters when used as material" has no native engine hook.
    -- That text is on the card for design purposes; enforcement would require custom proc wrappers.

    -- OPT: Send 1 monster from Deck to GY; adjust Level and gain name until End Phase
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 100)
    e3:SetTarget(s.foolishtg)
    e3:SetOperation(s.foolishop)
    c:RegisterEffect(e3)
end

function s.build_pool(tp)
    local pool = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_MZONE, 0, nil)
    if s.has_zombie_world(tp) then
        local opp = Duel.GetMatchingGroup(s.oppmatfilter, tp, 0, LOCATION_MZONE, nil)
        if opp:GetCount() > 0 then pool:Merge(opp) end
        local ban = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_REMOVED, 0, nil)
        if ban:GetCount() > 0 then pool:Merge(ban) end
    end
    return pool
end

function s.sumcond(e, tp, eg, ep, ev, re, r, rp)
    local pool = s.build_pool(tp)
    if pool:GetCount() < REQUIRED_MAT then return false end
    return pool:IsExists(s.skullfilter, 1, nil)
end

function s.has_zombie_world(tp)
    return Duel.IsExistingMatchingCard(s.zombieworld, tp, LOCATION_SZONE, LOCATION_SZONE, 1, nil)
end

function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return s.sumcond(e, tp, eg, ep, ev, re, r, rp)
            and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.sumop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local selected = Group.CreateGroup()

    if s.has_zombie_world(tp) then
        -- Optionally pick 1 opponent face-up zombie (shows all, player picks 0 or 1)
        local opp_pool = Duel.GetMatchingGroup(s.oppmatfilter, tp, 0, LOCATION_MZONE, nil)
        if opp_pool:GetCount() > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
            local og = opp_pool:Select(tp, 0, 1, nil)
            local oc = og:GetFirst()
            if oc then selected:AddCard(oc) end
        end
        -- Optionally pick 1 banished own zombie (shows all, player picks 0 or 1)
        local ban_pool = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_REMOVED, 0, nil)
        if ban_pool:GetCount() > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
            local bg = ban_pool:Select(tp, 0, 1, nil)
            local bc = bg:GetFirst()
            if bc then selected:AddCard(bc) end
        end
    end

    -- Pick remaining from own field using continuous UI (list updates each pick)
    local needed = REQUIRED_MAT - selected:GetCount()
    if needed > 0 then
        local own_pool = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_MZONE, 0, nil)
        own_pool:Sub(selected)
        if own_pool:GetCount() < needed then return end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
        local mg = own_pool:SelectWithSumGreater(tp, function(mc) return 1 end, needed, nil)
        if not mg or mg:GetCount() < needed then return end
        local mc = mg:GetFirst()
        while mc do selected:AddCard(mc); mc = mg:GetNext() end
    end

    if selected:GetCount() < REQUIRED_MAT then return end
    if not selected:IsExists(s.skullfilter, 1, nil) then return end

    -- Opponent's monster → their GY; own cards → shuffle to deck
    local opp_mat = selected:Filter(function(mc)
        return mc:IsControler(1 - tp) and mc:IsLocation(LOCATION_MZONE)
    end, nil)
    local deck_mat = selected:Clone()
    deck_mat:Sub(opp_mat)

    Duel.SendtoDeck(deck_mat, tp, SEQ_DECKSHUFFLE, REASON_COST + REASON_EFFECT)
    if opp_mat:GetCount() > 0 then
        Duel.SendtoGrave(opp_mat, REASON_COST + REASON_EFFECT)
    end
    if c:IsRelateToEffect(e)
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) then
        Duel.SpecialSummon(c, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP_ATTACK)
    end
end

-- OPT: Foolish Burial + Level change + name change
function s.foolishtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_MONSTER) end,
            tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, function(c) return c:IsType(TYPE_MONSTER) end,
        tp, LOCATION_DECK, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        e:SetLabelObject(tc)
        Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, tc, 1, 0, 0)
    end
end

function s.foolishop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if not tc then return end
    local sent_lv = tc:GetLevel()
    local sent_code = tc:GetCode()
    Duel.SendtoGrave(tc, REASON_EFFECT)

    local amalgam = e:GetHandler()
    if not amalgam:IsLocation(LOCATION_MZONE) then return end

    -- Ask: increase or decrease?
    local op = Duel.SelectOption(tp, aux.Stringid(id, 4), aux.Stringid(id, 5))
    local delta = (op == 0) and sent_lv or -sent_lv

    -- Apply level change until End Phase
    local elv = Effect.CreateEffect(amalgam)
    elv:SetType(EFFECT_TYPE_SINGLE)
    elv:SetCode(EFFECT_UPDATE_LEVEL)
    elv:SetReset(RESETS_STANDARD_PHASE_END)
    elv:SetValue(delta)
    amalgam:RegisterEffect(elv, true)

    -- Apply name change until End Phase
    local ename = Effect.CreateEffect(amalgam)
    ename:SetType(EFFECT_TYPE_SINGLE)
    ename:SetCode(EFFECT_CHANGE_CODE)
    ename:SetReset(RESETS_STANDARD_PHASE_END)
    ename:SetValue(sent_code)
    amalgam:RegisterEffect(ename, true)
end
