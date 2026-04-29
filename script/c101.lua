-- DP Calculator
local s, id = GetID()

local count = {
    ritual_summon = 0,
    fusion_summon = 0,
    synchro_summon = 0,
    xyz_summon = 0,
    link_summon = 0,
    spell = 0

}

local DP = 0

function s.initial_effect(c)
    -- activate
    aux.AddSkillProcedure(c, 2, false, nil, nil)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCondition(s.flipcon)
    e1:SetOperation(s.flipop)
    Duel.RegisterEffect(e1, 0)
end

function s.summoncon(e, tp, eg, ep, ev, re, r, rp)
    local sc = eg:GetFirst();
    return #eg == 1 and
               (sc:IsSummonType(SUMMON_TYPE_RITUAL) or sc:IsSummonType(SUMMON_TYPE_FUSION) or
                   sc:IsSummonType(SUMMON_TYPE_SYNCHRO) or sc:IsSummonType(SUMMON_TYPE_XYZ) or
                   sc:IsSummonType(SUMMON_TYPE_LINK)) and sc:IsControler(tp)
end

function s.summonop(e, tp, eg, ep, ev, re, r, rp)
    local sc = eg:GetFirst();
    local summon_type = Card.GetSummonType(sc);
    local summon_string = ""
    if summon_type == SUMMON_TYPE_RITUAL then
        count.ritual_summon = count.ritual_summon + 1;
        summon_string = "ritual"
    elseif summon_type == SUMMON_TYPE_FUSION then
        count.fusion_summon = count.fusion_summon + 1;
        summon_string = "fusion"
    elseif summon_type == SUMMON_TYPE_SYNCHRO then
        count.synchro_summon = count.synchro_summon + 1;
        summon_string = "synchro"
    elseif summon_type == SUMMON_TYPE_XYZ then
        count.xyz_summon = count.xyz_summon + 1;
        summon_string = "xyz"
    elseif summon_type == SUMMON_TYPE_LINK then
        count.link_summon = count.link_summon + 1;
        summon_string = "link"
    end

    DP = DP + 4
    s.debugop(string.format("[DP] Awarding for DP for a successful %s summon", summon_string))

end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    count.spell = count.spell + 1
    if (count.spell >= 10) then
        DP = DP + 2
        s.debugop("[DP] Awarding for DP for spell")
    end


    end

function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
    -- condition
    return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
end
function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id | (1 << 32))
    Duel.Hint(HINT_CARD, tp, id)
    Debug.Message("DP Calculator Enabled")

    -- Ritual/Fusion/Synchro/XYZ/Link Bonus
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.summoncon)
    e2:SetOperation(s.summonop)
    Duel.RegisterEffect(e2, 0)

    -- Spell Bonus
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_CHAINING)
    e0:SetOperation(aux.spop)
    c:RegisterEffect(e0)


end

function s.debugop(s)
  Debug.Message(s)
  io.write(s)
end