-- Action Field Functions
local id = 101

local count = {
    ritual_summon = 0,
    fusion_summon = 0,
    synchro_summon = 0,
    xyz_summon = 0,
    link_summon = 0,


}

if not DP then
    DP = {}

    function DP.Start()
        local e1 = Effect.GlobalEffect()
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_IGNORE_IMMUNE +
                           EFFECT_FLAG_NO_TURN_RESET)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetCountLimit(1)
        e1:SetOperation(DP.op)
        Duel.RegisterEffect(e1, 0)

        -- Ritual/Fusion/Synchro/XYZ/Link Bonus
        local e2 = Effect.GlobalEffect()
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_RANGE +
                           EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2:SetCondition(DP.summoncon)
        e2:SetOperation(DP.summonop)
        Duel.RegisterEffect(e2, 0)

    end
    function DP.op(e, tp, eg, ep, ev, re, r, rp)
        Debug.Message("DP Calculator Enabled")
    end

    function DP.summoncon(e, tp, eg, ep, ev, re, r, rp)
        local sc = eg:GetFirst();
        return #eg == 1 and
                   (sc:IsSummonType(SUMMON_TYPE_RITUAL) or sc:IsSummonType(SUMMON_TYPE_FUSION) or
                       sc:IsSummonType(SUMMON_TYPE_SYNCHRO) or sc:IsSummonType(SUMMON_TYPE_XYZ) or
                       sc:IsSummonType(SUMMON_TYPE_LINK)) and sc:IsControler(tp)
    end

    function DP.summonop(e,tp,eg,ep,ev,re,r,rp)
        local sc = eg:GetFirst();
        local summon_type = Card.GetSummonType(sc);
        if summon_type == SUMMON_TYPE_RITUAL then
            count.ritual_summon = count.ritual_summon + 1;
        elseif summon_type == SUMMON_TYPE_FUSION then
            count.fusion_summon = count.fusion_summon + 1;
        elseif summon_type == SUMMON_TYPE_SYNCHRO then
            count.synchro_summon = count.synchro_summon + 1;
        elseif summon_type == SUMMON_TYPE_XYZ then
            count.xyz_summon = count.xyz_summon + 1;
        elseif summon_type == SUMMON_TYPE_LINK then
            count.link_summon = count.link_summon + 1;
        end

        Debug.Message(summon_type);
        Debug.Message(count);
    end
end
