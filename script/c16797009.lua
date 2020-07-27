-- Ojama Coronation
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsCode,90140980),Card.IsAbleToDeck,s.fextra,Fusion.ShuffleMaterial)
    c:RegisterEffect(e1)
    if not GhostBelleTable then GhostBelleTable={} end
    table.insert(GhostBelleTable,e1)
end
s.listed_names={90140980,	12482652,42941100,79335209}
function s.matfilter(c,lc,stype,tp)
    return c:IsSummonCode(lc,stype,tp,12482652,	42941100,79335209) and c:IsAbleToDeck()
end
function s.frec(c,tp,sg,g,code,...)
    if not c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) then return false end
    if ... then
        g:AddCard(c)
        local res=sg:IsExists(s.frec,1,g,tp,sg,g,...)
        g:RemoveCard(c)
        return res
    else return true end
end
function s.fcheck(tp,sg,fc,mg)
    return #sg==3 and sg:IsExists(s.frec,1,nil,tp,sg,Group.CreateGroup(),12482652,	42941100,79335209)
end
function s.fextra(e,tp,mg)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
    return g,s.fcheck
end