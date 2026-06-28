-- Global Tag Force DP System State
local tf_stats = {
    turn_count = 1,
    spells_activated = 0,
    traps_activated = 0,
    fusion_summons = 0,
    ritual_summons = 0,
    synchro_summons = 0,
    xyz_summons = 0,    
    link_summons = 0,   
    tribute_summons = 0,
    special_summons = 0,
    flip_summons = 0,            
    tokens_summoned = 0,         
    max_chain = 0,
    total_chains = 0,            
    max_atk = 0,
    max_battle_dmg = 0,
    max_lp_diff = 0,
    reflected_damage = 0,
    p0_damaged = false,       
    p1_battle_damaged = false, 
    p1_effect_damaged = false, 
    battle_destroyed_count = 0,
    effect_destroyed_count = 0,
    banished_count = 0,          -- Opponent cards banished
    total_banished_count = 0,    -- Both players combined
    opponent_deck_banish = 0,    -- Banished straight from deck
    player_discard_count = 0,    -- Self hand discards
    monsters_stolen = 0,         -- Control swap count
    wight_fooling_count = 0,     -- Dynamic Wight milling tracker
    hand_discard_count = 0,
    deck_mill_count = 0,
    bounce_count = 0,
    counters_generated = 0,
    union_instances = 0,
    same_card_achieved = false,
    all_zones_occupied = false,
    opponent_zones_blocked = false,
    key_cards_destroyed = 0,  
    skull_servant_finish = false,
    turn_start_lp_lower = false,
    last_damage_amount = 0,
    first_blood_turn = 0,        
    avenge_count = 0,            
    concurrent_carnage = 0,      
    gy_activations = 0,          
    zone_moves = 0,              
    gemini_summons = 0,          
    coin_wins = 0,               
    coin_streak = 0,             
    max_coin_streak = 0,         
    has_ended = false
}

-- Constant for Skull Servant base code
local CARD_SKULL_SERVANT = 46411259

-- Bonus Defined Key Cards Array
local key_cards = {
    [89631139] = true, -- Blue-Eyes White Dragon
    [46986414] = true, -- Dark Magician
    [74677422] = true  -- Red-Eyes Black Dragon
}

-- Dynamic Archetype Engine
local function is_wight_card(tc)
    if not tc then return false end
    return tc:IsCode(CARD_SKULL_SERVANT) or tc:ListsCode(CARD_SKULL_SERVANT)
end

local function global_chain_handler(e, tp, eg, ep, ev, re, r, rp)
    local cl = Duel.GetCurrentChain()
    if cl > tf_stats.max_chain then tf_stats.max_chain = cl end
    if cl == 1 then tf_stats.total_chains = tf_stats.total_chains + 1 end
    
    if rp == 0 and re then
        if re:IsActiveType(TYPE_SPELL) then tf_stats.spells_activated = tf_stats.spells_activated + 1 end
        if re:IsActiveType(TYPE_TRAP) then tf_stats.traps_activated = tf_stats.traps_activated + 1 end
        if re:GetActivateLocation() == LOCATION_GRAVEYARD and re:IsActiveType(TYPE_MONSTER) then
            tf_stats.gy_activations = tf_stats.gy_activations + 1
        end
    end
end

local function global_summon_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg and eg:GetCount() > 0 then
        local tc = eg:GetFirst()
        if tc and tc:GetSummonPlayer() == 0 then
            if tc:IsStatus(STATUS_SUMMON_TURN) and tc:GetLevel() >= 5 then
                tf_stats.tribute_summons = tf_stats.tribute_summons + 1
            end
            if tc:IsType(TYPE_GEMINI) and tc:IsGeminiState() then
                tf_stats.gemini_summons = tf_stats.gemini_summons + 1
            end
        end
    end
end

local function global_flipsummon_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg and eg:GetCount() > 0 then
        local tc = eg:GetFirst()
        if tc and tc:GetSummonPlayer() == 0 then
            tf_stats.flip_summons = tf_stats.flip_summons + eg:GetCount()
        end
    end
end

local function global_spsummon_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg and eg:GetCount() > 0 then
        local tc = eg:GetFirst()
        if tc and tc:GetSummonPlayer() == 0 then
            tf_stats.special_summons = tf_stats.special_summons + eg:GetCount()
            local sc = eg:GetFirst()
            while sc do
                if sc:IsSummonType(SUMMON_TYPE_FUSION) then tf_stats.fusion_summons = tf_stats.fusion_summons + 1 end
                if sc:IsSummonType(SUMMON_TYPE_RITUAL) then tf_stats.ritual_summons = tf_stats.ritual_summons + 1 end
                if sc:IsSummonType(SUMMON_TYPE_SYNCHRO) then tf_stats.synchro_summons = tf_stats.synchro_summons + 1 end
                if sc:IsSummonType(SUMMON_TYPE_XYZ) then tf_stats.xyz_summons = tf_stats.xyz_summons + 1 end     
                if sc:IsSummonType(SUMMON_TYPE_LINK) then tf_stats.link_summons = tf_stats.link_summons + 1 end   
                if sc:IsType(TYPE_UNION) then tf_stats.union_instances = tf_stats.union_instances + 1 end
                if sc:IsType(TYPE_TOKEN) then tf_stats.tokens_summoned = tf_stats.tokens_summoned + 1 end
                if sc:IsType(TYPE_GEMINI) and sc:IsGeminiState() then tf_stats.gemini_summons = tf_stats.gemini_summons + 1 end
                sc = eg:GetNext()
            end
        end
    end
end

local function global_damage_handler(e, tp, eg, ep, ev, re, r, rp)
    if tf_stats.first_blood_turn == 0 and ev > 0 then
        tf_stats.first_blood_turn = Duel.GetTurnCount()
    end

    if ep == 0 and ev > 0 then
        tf_stats.p0_damaged = true 
    end
    if ep == 1 and ev > 0 then
        tf_stats.last_damage_amount = ev
        if bit.band(r, REASON_BATTLE) ~= 0 then
            tf_stats.p1_battle_damaged = true
            if ev > tf_stats.max_battle_dmg then tf_stats.max_battle_dmg = ev end
            if Duel.GetTurnPlayer() == 1 then
                tf_stats.reflected_damage = tf_stats.reflected_damage + ev
            end
            local attacker = Duel.GetAttacker()
            if attacker and attacker:IsControler(0) and attacker:IsCode(CARD_SKULL_SERVANT) and Duel.GetLP(1) - ev <= 0 then
                tf_stats.skull_servant_finish = true
            end
        elseif bit.band(r, REASON_EFFECT) ~= 0 then
            tf_stats.p1_effect_damaged = true
        end
    end
    
    local diff = Duel.GetLP(1) - Duel.GetLP(0)
    if diff > tf_stats.max_lp_diff then tf_stats.max_lp_diff = diff end
end

local function global_graveyard_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg then
        local tc = eg:GetFirst()
        while tc do
            local prev_loc = tc:GetPreviousLocation()
            local owner = tc:GetOwner()
            local reason = tc:GetReason()
            
            if bit.band(reason, REASON_BATTLE) ~= 0 and owner == 1 then
                tf_stats.battle_destroyed_count = tf_stats.battle_destroyed_count + 1
                if key_cards[tc:GetCode()] or (tc:IsType(TYPE_MONSTER) and tc:GetBaseAttack() >= 3000 and tc:GetLevel() >= 8) then
                    tf_stats.key_cards_destroyed = tf_stats.key_cards_destroyed + 1
                end
                if Duel.GetTurnPlayer() == 1 and Duel.GetAttacker() == tc then
                    tf_stats.avenge_count = tf_stats.avenge_count + 1
                end
            elseif bit.band(reason, REASON_EFFECT) ~= 0 and owner == 1 then
                tf_stats.effect_destroyed_count = tf_stats.effect_destroyed_count + 1
                if rp == 0 and (key_cards[tc:GetCode()] or (tc:IsType(TYPE_MONSTER) and tc:GetBaseAttack() >= 3000 and tc:GetLevel() >= 8)) then
                    tf_stats.key_cards_destroyed = tf_stats.key_cards_destroyed + 1
                end
            end
            
            if prev_loc == LOCATION_HAND then
                if owner == 1 then
                    tf_stats.hand_discard_count = tf_stats.hand_discard_count + 1
                elseif owner == 0 then
                    tf_stats.player_discard_count = tf_stats.player_discard_count + 1
                end
            end
            
            if prev_loc == LOCATION_DECK and owner == 1 then
                tf_stats.deck_mill_count = tf_stats.deck_mill_count + 1
            end
            
            -- Wight Fooling Counter
            if owner == 0 and rp == 1 and bit.band(reason, REASON_EFFECT) ~= 0 and is_wight_card(tc) then
                tf_stats.wight_fooling_count = tf_stats.wight_fooling_count + 1
            end
            
            tc = eg:GetNext()
        end
    end
end

local function global_battle_end(e, tp, eg, ep, ev, re, r, rp)
    local a = Duel.GetAttacker()
    local d = Duel.GetAttackTarget()
    if a and d and a:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsStatus(STATUS_BATTLE_DESTROYED) then
        tf_stats.concurrent_carnage = tf_stats.concurrent_carnage + 1
    end
end

local function global_remove_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg then
        local tc = eg:GetFirst()
        while tc do
            local owner = tc:GetOwner()
            local prev_loc = tc:GetPreviousLocation()
            
            tf_stats.total_banished_count = tf_stats.total_banished_count + 1
            
            if owner == 1 then
                tf_stats.banished_count = tf_stats.banished_count + 1
                if prev_loc == LOCATION_DECK then
                    tf_stats.opponent_deck_banish = tf_stats.opponent_deck_banish + 1
                end
                if rp == 0 and (key_cards[tc:GetCode()] or (tc:IsType(TYPE_MONSTER) and tc:GetBaseAttack() >= 3000 and tc:GetLevel() >= 8)) then
                    tf_stats.key_cards_destroyed = tf_stats.key_cards_destroyed + 1
                end
            end
            tc = eg:GetNext()
        end
    end
end

local function global_tohand_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg then
        local tc = eg:GetFirst()
        while tc do
            if tc:GetOwner() == 1 and (tc:GetPreviousLocation() == LOCATION_MZONE or tc:GetPreviousLocation() == LOCATION_GRAVEYARD) then
                tf_stats.bounce_count = tf_stats.bounce_count + 1
            end
            tc = eg:GetNext()
        end
    end
end

local function global_move_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg and eg:GetCount() > 0 then
        local tc = eg:GetFirst()
        if tc and tc:GetControler() == 0 and tc:GetLocation() == LOCATION_MZONE and tc:GetPreviousLocation() == LOCATION_MZONE then
            tf_stats.zone_moves = tf_stats.zone_moves + 1
        end
    end
end

local function global_control_handler(e, tp, eg, ep, ev, re, r, rp)
    if eg then
        local tc = eg:GetFirst()
        while tc do
            if tc:GetControler() == 0 and tc:GetPreviousControler() == 1 then
                tf_stats.monsters_stolen = tf_stats.monsters_stolen + 1
            end
            tc = eg:GetNext()
        end
    end
end

local function global_coin_handler(e, tp, eg, ep, ev, re, r, rp)
    if ep == 0 then 
        if ev == 1 then
            tf_stats.coin_wins = tf_stats.coin_wins + 1
            tf_stats.coin_streak = tf_stats.coin_streak + 1
            if tf_stats.coin_streak > tf_stats.max_coin_streak then
                tf_stats.max_coin_streak = tf_stats.coin_streak
            end
        else
            tf_stats.coin_streak = 0
        end
    end
end

-- Win/Loss Evaluation Matcher
local function evaluate_tag_force_dp()
    if tf_stats.has_ended then return end
    
    local lp0 = Duel.GetLP(0) 
    local lp1 = Duel.GetLP(1) 
    local deck0 = Duel.GetFieldGroupCount(0, LOCATION_DECK, 0)
    local deck1 = Duel.GetFieldGroupCount(1, LOCATION_DECK, 0)
    
    local my_outcome = "active"
    if lp0 <= 0 and lp1 <= 0 then my_outcome = "draw"
    elseif lp1 <= 0 then my_outcome = "win"  
    elseif lp0 <= 0 then my_outcome = "lose" 
    elseif deck0 == 0 and deck1 == 0 then my_outcome = "draw"
    elseif deck0 == 0 then my_outcome = "lose"
    elseif deck1 == 0 then my_outcome = "win"
    end
    
    if my_outcome == "active" then return end
    tf_stats.has_ended = true
    
    local my_dp = 0
    local log_me = {}
    
    -- Evaluate Victory Outcomes
    if my_outcome == "win" then
        local tb = tf_stats.turn_count * 2
        my_dp = my_dp + tb
        table.insert(log_me, string.format("Turn Bonus: +%d DP", tb))
        
        if deck1 == 0 then my_dp = my_dp + 20; table.insert(log_me, "No More Cards Bonus: +20 DP") end
        if tf_stats.turn_count <= 5 then my_dp = my_dp + 10; table.insert(log_me, "Quick Finish Bonus: +10 DP") end
        if tf_stats.turn_start_lp_lower then my_dp = my_dp + 20; table.insert(log_me, "Reversal Finish Bonus: +20 DP") end
        if Duel.GetTurnPlayer() == 1 then my_dp = my_dp + 20; table.insert(log_me, "Opponent's Turn Finish Bonus: +20 DP") end
        
        if lp0 <= 100 then my_dp = my_dp + 200; table.insert(log_me, "Extremely Low LP Bonus: +200 DP")
        elseif lp0 <= 1000 then my_dp = my_dp + 50; table.insert(log_me, "Low LP Bonus: +50 DP")
        end
        
        if not tf_stats.p0_damaged then my_dp = my_dp + 10; table.insert(log_me, "LP Keep Bonus: +10 DP") end
        if lp0 > 20000 then my_dp = my_dp + 100; table.insert(log_me, "Over 20,000 LP Bonus: +100 DP") end
        if lp0 == 5730 then my_dp = my_dp + 573; table.insert(log_me, "Konami Bonus: +573 DP") end
        if deck0 < 10 and deck0 > 0 then my_dp = my_dp + 20; table.insert(log_me, "Low Deck Bonus: +20 DP") end
        if deck0 == 0 then my_dp = my_dp + 100; table.insert(log_me, "Extremely Low Deck Bonus: +100 DP") end
        
        if tf_stats.spells_activated >= 10 then
            local val = tf_stats.spells_activated * 2
            my_dp = my_dp + val; table.insert(log_me, string.format("Spell Card Bonus (%d acts): +%d DP", tf_stats.spells_activated, val))
        end
        if tf_stats.traps_activated >= 10 then
            local val = tf_stats.traps_activated * 2
            my_dp = my_dp + val; table.insert(log_me, string.format("Trap Card Bonus (%d acts): +%d DP", tf_stats.traps_activated, val))
        end
        
        if tf_stats.spells_activated == 0 then my_dp = my_dp + 50; table.insert(log_me, "No Spell Cards Bonus: +50 DP") end
        if tf_stats.traps_activated == 0 then my_dp = my_dp + 50; table.insert(log_me, "No Trap Cards Bonus: +50 DP") end
        if tf_stats.special_summons == 0 then my_dp = my_dp + 50; table.insert(log_me, "No Special Summon Bonus: +50 DP") end
        
        if tf_stats.fusion_summons > 0 then
            local val = tf_stats.fusion_summons * 10
            my_dp = my_dp + val; table.insert(log_me, string.format("Fusion Summon Bonus: +%d DP", val))
        end
        if tf_stats.ritual_summons > 0 then
            local val = tf_stats.ritual_summons * 10
            my_dp = my_dp + val; table.insert(log_me, string.format("Ritual Summon Bonus: +%d DP", val))
        end
        if tf_stats.tribute_summons > 0 then
            local val = tf_stats.tribute_summons * 10
            my_dp = my_dp + val; table.insert(log_me, string.format("Tribute Summon Bonus: +%d DP", val))
        end
        if tf_stats.synchro_summons > 0 then
            local val = tf_stats.synchro_summons * 1
            my_dp = my_dp + val; table.insert(log_me, string.format("Synchro Summon Bonus: +%d DP", val))
        end
        if tf_stats.xyz_summons > 0 then
            local val = tf_stats.xyz_summons * 1
            my_dp = my_dp + val; table.insert(log_me, string.format("XYZ Summon Bonus: +%d DP", val)) 
        end
        if tf_stats.link_summons > 0 then
            local val = tf_stats.link_summons * 1
            my_dp = my_dp + val; table.insert(log_me, string.format("Link Summon Bonus: +%d DP", val)) 
        end
        if tf_stats.flip_summons > 0 then
            local val = tf_stats.flip_summons * 2
            my_dp = my_dp + val; table.insert(log_me, string.format("Flip Summon Bonus: +%d DP", val))
        end
        if tf_stats.tokens_summoned > 0 then
            local val = tf_stats.tokens_summoned * 2
            my_dp = my_dp + val; table.insert(log_me, string.format("Token Monster Bonus: +%d DP", val))
        end
        if tf_stats.gemini_summons > 0 then
            local val = tf_stats.gemini_summons * 6
            my_dp = my_dp + val; table.insert(log_me, string.format("Gemini Bonus: +%d DP", val))
        end
        if tf_stats.union_instances > 0 then
            local val = tf_stats.union_instances * 6
            my_dp = my_dp + val; table.insert(log_me, string.format("Union Bonus: +%d DP", val))
        end
        
        if tf_stats.max_lp_diff >= 5000 then
            local val = math.floor(tf_stats.max_lp_diff / 250)
            my_dp = my_dp + val; table.insert(log_me, string.format("LP Differential Bonus: +%d DP", val))
        end
        if tf_stats.last_damage_amount > 0 and lp1 == 0 then my_dp = my_dp + 10; table.insert(log_me, "Exactly 0 LP Bonus: +10 DP") end
        
        if tf_stats.p1_battle_damaged and not tf_stats.p1_effect_damaged then my_dp = my_dp + 30; table.insert(log_me, "Battle Damage only Bonus: +30 DP") end
        if tf_stats.p1_effect_damaged and not tf_stats.p1_battle_damaged then my_dp = my_dp + 60; table.insert(log_me, "Effect Damage only Bonus: +60 DP") end
        if tf_stats.skull_servant_finish then my_dp = my_dp + 1; table.insert(log_me, "Skull Servant Finish Bonus: +1 DP") end
        
        if tf_stats.first_blood_turn > 0 then
            local val = tf_stats.first_blood_turn * 10
            my_dp = my_dp + val; table.insert(log_me, string.format("First Blood Bonus (Turn %d): +%d DP", tf_stats.first_blood_turn, val))
        end
    elseif my_outcome == "lose" then
        local tb = tf_stats.turn_count * 1
        my_dp = my_dp + tb + 10
        table.insert(log_me, string.format("Turn Bonus: +%d DP", tb))
        table.insert(log_me, "Lose Bonus: +10 DP")
    elseif my_outcome == "draw" then
        local tb = tf_stats.turn_count * 1
        my_dp = my_dp + tb + 50
        table.insert(log_me, string.format("Turn Bonus: +%d DP", tb))
        table.insert(log_me, "Draw Game Bonus: +50 DP")
    end
    
    -- Performance Tracking Metrics (Earned Regardless)
    local my_perf = 0
    if tf_stats.max_chain >= 3 then
        local val = tf_stats.max_chain * 2
        my_perf = my_perf + val; table.insert(log_me, string.format("Chain Bonus (Link %d): +%d DP", tf_stats.max_chain, val))
    end
    if tf_stats.total_chains > 0 then
        my_perf = my_perf + tf_stats.total_chains
        table.insert(log_me, string.format("Total Chains Formed (%d counts): +%d DP", tf_stats.total_chains, tf_stats.total_chains))
    end
    if tf_stats.max_atk >= 3000 then
        local val = math.floor(tf_stats.max_atk / 50)
        my_perf = my_perf + val; table.insert(log_me, string.format("Max ATK Bonus (%d ATK): +%d DP", tf_stats.max_atk, val))
    end
    if tf_stats.max_battle_dmg >= 3000 then
        local val = math.floor(tf_stats.max_battle_dmg / 250)
        my_perf = my_perf + val; table.insert(log_me, string.format("Max Damage Bonus (%d Dmg): +%d DP", tf_stats.max_battle_dmg, val))
    end
    if tf_stats.reflected_damage > 0 then
        local val = math.floor(tf_stats.reflected_damage / 50) 
        my_perf = my_perf + val; table.insert(log_me, string.format("Max Reflected Damage Bonus: +%d DP", val))
    end
    if tf_stats.battle_destroyed_count >= 10 then
        local val = tf_stats.battle_destroyed_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Destroyed in Battle Bonus: +%d DP", val))
    end
    if tf_stats.effect_destroyed_count >= 10 then
        local val = tf_stats.effect_destroyed_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Destroyed by Effect Bonus: +%d DP", val))
    end
    if tf_stats.banished_count >= 10 then
        local val = tf_stats.banished_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Opponent Monsters Banished Bonus: +%d DP", val))
    end
    if tf_stats.total_banished_count > 0 then
        local val = tf_stats.total_banished_count * 2
        my_perf = my_perf + val; table.insert(log_me, string.format("Cards Removed From Play Bonus (%d cards): +%d DP", tf_stats.total_banished_count, val))
    end
    if tf_stats.opponent_deck_banish > 0 then
        local val = tf_stats.opponent_deck_banish * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Opponent Deck Banish Out Bonus (%d cards): +%d DP", tf_stats.opponent_deck_banish, val))
    end
    if tf_stats.player_discard_count > 0 then
        local val = tf_stats.player_discard_count * 2
        my_perf = my_perf + val; table.insert(log_me, string.format("Cards Discarded from Hand Bonus: +%d DP", val))
    end
    if tf_stats.monsters_stolen > 0 then
        local val = tf_stats.monsters_stolen * 10
        my_perf = my_perf + val; table.insert(log_me, string.format("Controlled Opponent Monsters Bonus: +%d DP", val))
    end
    if tf_stats.wight_fooling_count > 0 then
        local val = tf_stats.wight_fooling_count * 15
        my_perf = my_perf + val; table.insert(log_me, string.format("Skull Servant Grave Trick Bonus (%d mills): +%d DP", tf_stats.wight_fooling_count, val))
    end
    if tf_stats.hand_discard_count >= 10 then
        local val = tf_stats.hand_discard_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Hand Destruction Bonus: +%d DP", val))
    end
    if tf_stats.deck_mill_count >= 10 then
        local val = tf_stats.deck_mill_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Deck Destruction Bonus: +%d DP", val))
    end
    if tf_stats.bounce_count >= 10 then
        local val = tf_stats.bounce_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Return to Hand Bonus: +%d DP", val))
    end
    if tf_stats.counters_generated >= 5 then
        local val = tf_stats.counters_generated * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Counter Bonus (%d count): +%d DP", tf_stats.counters_generated, val))
    end
    if tf_stats.same_card_achieved then my_perf = my_perf + 5; table.insert(log_me, "Same Card Bonus: +5 DP") end
    if tf_stats.all_zones_occupied then my_perf = my_perf + 10; table.insert(log_me, "All Monster Zone Bonus: +10 DP") end
    if tf_stats.opponent_zones_blocked then my_perf = my_perf + 60; table.insert(log_me, "No Monster Zone Bonus: +60 DP") end
    if tf_stats.key_cards_destroyed > 0 then
        local val = tf_stats.key_cards_destroyed * 20
        my_perf = my_perf + val; table.insert(log_me, string.format("Key Card Destruction Bonus: +%d DP", val))
    end

    if tf_stats.avenge_count > 0 then
        local val = tf_stats.avenge_count * 4
        my_perf = my_perf + val; table.insert(log_me, string.format("Avenge Bonus: +%d DP", val))
    end
    if tf_stats.concurrent_carnage > 0 then
        local val = tf_stats.concurrent_carnage * 10
        my_perf = my_perf + val; table.insert(log_me, string.format("Concurrent Carnage Bonus: +%d DP", val))
    end
    if tf_stats.gy_activations > 0 then
        local val = tf_stats.gy_activations * 6
        my_perf = my_perf + val; table.insert(log_me, string.format("Graveyard Activation Bonus: +%d DP", val))
    end
    if tf_stats.zone_moves > 0 then
        local val = tf_stats.zone_moves * 6
        my_perf = my_perf + val; table.insert(log_me, string.format("Position Move Bonus: +%d DP", val))
    end

    -- Progressive Luck Logic
    if tf_stats.coin_wins > 0 then
        local luck_val = 111 + (2 * tf_stats.max_coin_streak)
        my_perf = my_perf + luck_val
        table.insert(log_me, string.format("Luck Bonus (%d Wins, Max Streak %d): +%d DP", tf_stats.coin_wins, tf_stats.max_coin_streak, luck_val))
        
        if tf_stats.max_coin_streak >= 7 then
            my_perf = my_perf + 777
            table.insert(log_me, "7 Consecutive Coin Wins Milestone: +777 DP")
        end
    end

    my_dp = my_dp + my_perf

    -- Output Layout
    Debug.Message("=============================================")
    Debug.Message("             MATCH CONCLUDED                 ")
    Debug.Message("=============================================")
    Debug.Message(string.format(" [YOUR OUTCOME: %s]", string.upper(my_outcome)))
    for _, msg in ipairs(log_me) do 
        Debug.Message("   " .. msg) 
    end
    Debug.Message(string.format(" TOTAL DP EARNED: %d DP", my_dp))
    Debug.Message("=============================================")
end

local last_turn = 0
local function global_state_scan(e, tp, eg, ep, ev, re, r, rp)
    local current_turn = Duel.GetTurnCount()
    if current_turn ~= last_turn then
        tf_stats.turn_count = current_turn
        last_turn = current_turn
        local lp0 = Duel.GetLP(0) 
        local lp1 = Duel.GetLP(1) 
        if Duel.GetTurnPlayer() == 0 then
            tf_stats.turn_start_lp_lower = (lp0 < lp1)
        end
    end

    local g = Duel.GetMatchingGroup(Card.IsFaceup, 0, LOCATION_MZONE, 0, nil)
    if g then
        local tc = g:GetFirst()
        while tc do
            if tc:GetControler() == 0 then
                local atk = tc:GetAttack()
                if atk > tf_stats.max_atk then tf_stats.max_atk = atk end
            end
            tc = g:GetNext()
        end
    end
    
    local mzone_count0 = Duel.GetMatchingGroupCount(nil, 0, LOCATION_MZONE, 0, nil)
    if mzone_count0 == 5 then tf_stats.all_zones_occupied = true end
    
    local usable_zones1 = Duel.GetLocationCount(1, LOCATION_MZONE)
    if usable_zones1 == 0 and Duel.GetMatchingGroupCount(nil, 1, LOCATION_MZONE, 0, nil) == 0 then
        tf_stats.opponent_zones_blocked = true
    end
    
    local g0 = Duel.GetFieldGroup(0, LOCATION_ONFIELD, 0)
    if g0 then
        local names = {}
        local tc = g0:GetFirst()
        while tc do
            if not tc:IsType(TYPE_TOKEN) then
                local code = tc:GetCode()
                names[code] = (names[code] or 0) + 1
                if names[code] >= 3 then tf_stats.same_card_achieved = true end
            end
            tc = g0:GetNext()
        end
    end
    
    local total_counters = 0
    local cards = Duel.GetFieldGroup(0, LOCATION_ONFIELD, LOCATION_ONFIELD)
    if cards then
        local tc = cards:GetFirst()
        while tc do
            total_counters = total_counters + tc:GetCounter(0x1)
            tc = cards:GetNext()
        end
    end
    if total_counters > tf_stats.counters_generated then tf_stats.counters_generated = total_counters end

    evaluate_tag_force_dp()
end

-- Strictly verified event table mapping to your engine's definitions
local events = {
    {EVENT_CHAINING,            global_chain_handler},
    {EVENT_SUMMON_SUCCESS,      global_summon_handler},
    {EVENT_FLIP_SUMMON_SUCCESS, global_flipsummon_handler},
    {EVENT_SPSUMMON_SUCCESS,    global_spsummon_handler},
    {EVENT_DAMAGE,              global_damage_handler},
    {EVENT_TO_GRAVE,            global_graveyard_handler},
    {EVENT_BATTLE_DESTROYED,    global_battle_end}, 
    {EVENT_REMOVE,              global_remove_handler},
    {EVENT_TO_HAND,             global_tohand_handler},
    {EVENT_MOVE,                global_move_handler},
    {EVENT_CONTROL_CHANGED,     global_control_handler},
    {EVENT_TOSS_COIN,           global_coin_handler},
    {EVENT_ADJUST,              global_state_scan}
}

-- Registry execution loop 
for _, v in ipairs(events) do
    local el = Effect.GlobalEffect()
    el:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    el:SetCode(v[1])
    el:SetOperation(v[2])
    Duel.RegisterEffect(el, 0)
end
