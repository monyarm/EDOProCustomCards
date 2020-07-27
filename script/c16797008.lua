-- Ojama Fusion
local s,id=GetID()
function s.initial_effect(c)
    local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xf),Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial)
    c:RegisterEffect(e1)
    if not GhostBelleTable then GhostBelleTable={} end
    table.insert(GhostBelleTable,e1)
end
s.listed_series={0xf}
function s.fextra(e,tp,mg)
    if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
        return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
    end
    return nil
end