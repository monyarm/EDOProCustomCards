-- Wightcharge!!!
-- ID: 83750015
local s, id = GetID()

local SKULL_SERVANT = 32274490

s.listed_names = {SKULL_SERVANT}

function s.initial_effect(c)
    -- Name becomes Skull Servant in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(SKULL_SERVANT)
    c:RegisterEffect(e1)

    -- FLIP: mill 3, then destroy opponent cards equal to Wight/Skull Servant milled
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_FLIP)
    e2:SetTarget(s.fliptg)
    e2:SetOperation(s.flipop)
    c:RegisterEffect(e2)
end

function s.isSkullOrMentions(c)
    return c:IsType(TYPE_MONSTER)
        and (c:IsCode(SKULL_SERVANT) or c:ListsCode(SKULL_SERVANT))
end

function s.fliptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 3, tp, 0)
    -- Potential destruction targets (we don't know count yet, inform 0-3)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 0, 1 - tp, 0)
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    -- Mill top 3
    local top3 = Duel.GetDecktopGroup(tp, 3)
    local wight_count = 0
    if top3:GetCount() > 0 then
        -- Count Wight/Skull Servant among them before sending
        local c2 = top3:GetFirst()
        while c2 do
            if s.isSkullOrMentions(c2) then wight_count = wight_count + 1 end
            c2 = top3:GetNext()
        end
        Duel.SendtoGrave(top3, REASON_EFFECT)
    end
    if wight_count == 0 then return end
    -- Destroy up to wight_count cards opponent controls
    local opp_count = Duel.GetFieldGroupCount(1 - tp, LOCATION_MZONE + LOCATION_SZONE, 0)
    local destroy_count = math.min(wight_count, opp_count)
    if destroy_count == 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local targets = Duel.SelectMatchingCard(tp,
        function(c) return c:IsDestructable() and c:IsControler(1 - tp) end,
        tp, 0, LOCATION_MZONE + LOCATION_SZONE, 1, destroy_count, nil)
    if targets:GetCount() > 0 then
        Duel.Destroy(targets, REASON_EFFECT)
    end
end
