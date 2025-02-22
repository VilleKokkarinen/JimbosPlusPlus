--- STEAMODDED HEADER
--- MOD_NAME: Jimbos++
--- MOD_ID: Jimbos++
--- MOD_AUTHOR: [Rare_K]
--- MOD_DESCRIPTION: The Jimbos++ mod
--- MOD_VERSION: 1.0.0
--- MOD_SITE: https://github.com/VilleKokkarinen/JimbosPlusPlus

--------------------------------
------------MOD CODE------------

-- shared helper functions
function shakecard(self)
    G.E_MANAGER:add_event(Event({
        func = function()
            self:juice_up(0.5, 0.5)
            return true
        end
    }))
end

local mod_name = 'Jimbos++'

local jokers = {   
    seal = {
        name = "The Seal",
        text = {
            "{C:inactive}Arf... arf..... Arf!",
            "{C:chips}+#4#{} Chips, {C:mult}+#5#{} Mult, {X:mult,C:white}X#6#{} Mult",
            "per scored {C:attention}Seal",
            "{C:inactive}Currently: {C:chips}+#1#{}, {C:mult}+#2#{}, {X:mult,C:white}X#3#{}",
        },
        config = { extra = { chips = 0, mult = 0, x_mult = 1, chips_gain = 2, mult_gain = 1, xmult_gain = 0.02 } },
        pos = { x = 0, y = 0 },
        rarity = 3,
        cost = 10,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.debuff then return nil end

            if context.individual and context.cardarea == G.play and not context.end_of_round then
                if context.other_card.seal and not (context.blueprint or context.other_card.debuff) then
                    self.ability.extra.x_mult = self.ability.extra.x_mult + self.ability.extra.xmult_gain
                    self.ability.extra.mult = self.ability.extra.mult + self.ability.extra.mult_gain
                    self.ability.extra.chips = self.ability.extra.chips + self.ability.extra.chips_gain
                    
                    return {
                        extra = {focus = self, message = localize('k_upgrade_ex')},
                        card = self,
                        focus = self
                    }
                end
            end

            if context.joker_main and context.cardarea == G.jokers then
                return {
                    chips = self.ability.extra.chips,
                    mult = self.ability.extra.mult,
                    x_mult = self.ability.extra.x_mult,
                    card = self
                }
            end
        end,

        loc_def = function(self)
            return { self.ability.extra.chips, self.ability.extra.mult, self.ability.extra.x_mult, self.ability.extra.chips_gain, self.ability.extra.mult_gain, self.ability.extra.xmult_gain }
        end    
    },
    fundmanager = {
        name = "Fund Manager",
        text = {
            "Gains {C:money}$#1#{} of ",
            "{C:attention}sell value{} at",
            "end of round.",
            "{C:inactive}Increases each {C:attention}Ante{}{C:inactive}.",
        },
        config = { extra = 2 },
        pos = { x = 0, y = 0 },
        rarity = 1,
        cost = 4,
        blueprint_compat = false,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.debuff then return nil end
            if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
                -- ease_dollars(G.GAME.round_resets.blind_ante*2)
                local current_ante = G.GAME.round_resets.blind_ante
                self.ability.extra = 1 + current_ante
                self.ability.extra_value = self.ability.extra_value + self.ability.extra
                self:set_cost()
                return {
                    message = localize('k_val_up'),
                    colour = G.C.MONEY
                }
            end
        end,

        loc_def = function(self)
            return { self.ability.extra }
        end
    },
    stockmarket = {
        name = "Stockmarket",
        text = {
            "Invests 50% of your money {C:money}(min 5$){}",
            "at the end of each round",
            "into the stock market.",
            "{C:inactive}(Stocks only go up, right?)"
        },
        config = { },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.debuff then return nil end
            if context.end_of_round and not (context.individual or context.repetition)then
                -- 10% chance to increase by 20%
                -- 10% chance to decrease by 15%
                -- 15% chance to increase by 10
                -- 15% chance to decrease by 7
                -- 25% chance to increase by 3
                -- 25% chance to decrease by 2


                if G.GAME.dollars >= 10 then
                    local money = math.floor(G.GAME.dollars / 2)
                    local chance = math.random(1, 100)

                    if chance <= 10 then
                        money = math.floor(money * 1.2)
                    elseif chance <= 20 then
                        money = math.floor(money * 0.85)
                    elseif chance <= 35 then
                        money = 10
                    elseif chance <= 50 then
                        money = -math.min(7, money)
                    elseif chance <= 75 then
                        money = 3
                    elseif chance <= 100 then
                        money = -2
                    end

                    shakecard(self)

                    return {
                        message = localize('$') .. money,
                        colour = G.C.MONEY,
                        delay = 0.45,
                        card = self,
                        extra = {
                            func = function()
                                ease_dollars(money)
                            end
                        }
                    }

                end
            end
        end,

        loc_def = function(self)
            return { }
        end
    },
    cryptomarket = {
        name = "Cryptomarket",
        text = {
            "Invests 50% of your money {C:money}(min 5$){}",
            "at the end of each round",
            "into the JimboCoin.",
            "{C:inactive}It's not a bubble, it's a feature!"
        },
        config = { },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 4,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.debuff then return nil end
            if context.end_of_round and not (context.individual or context.repetition) then
                -- 5% chance to increase by 25x
                -- 10% chance to increase by 7x
                -- 10% chance to increase by 3x
                -- 25% chance to lose all
                -- 10% chance to halve
                -- 20% chance to lose 5
                -- 20% chance to lose 50
                -- losses are capped by the amount invested (e.g. invest 10, lose 50 -> lose 10)

                if G.GAME.dollars >= 10 then
                    local money = math.floor(G.GAME.dollars / 2)
                    local chance = math.random(1, 100)

                    if chance <= 5 then
                        money = money * 25
                    elseif chance <= 15 then
                        money = money * 7
                    elseif chance <= 25 then
                        money = money * 3
                    elseif chance <= 50 then
                        money = -money
                    elseif chance <= 60 then
                        money = -math.floor(money / 2)
                    elseif chance <= 80 then
                        money = -5
                    elseif chance <= 100 then
                        money = -math.min(50, money)
                    end
                    
                    shakecard(self)

                    return {
                        message = localize('$') .. money,
                        colour = G.C.MONEY,
                        delay = 0.45,
                        card = self,
                        extra = {
                            func = function()
                                ease_dollars(money)
                            end
                        }
                    }
                end
            end
        end,

        loc_def = function(self)
            return { }
        end
    },
    roomba = {
        name = "Roomba",
        text = {
            "Attempts to remove edition*",
            "from another Joker",
            "at the end of each round",
            "{C:inactive}*Foil, Holo, Polychrome"
        },
        config = { extra = {  } },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 4,
        blueprint_compat = true,
        eternal_compat = false,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,
        calculate = function(self, context)
            if self.debuff then return nil end
            if context.end_of_round and not (context.individual or context.repetition) then
                local cleanable_jokers = {}

                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] ~= self then
                        cleanable_jokers[#cleanable_jokers+1] = G.jokers.cards[i] 
                    end
                end

                local joker_to_clean = #cleanable_jokers > 0 and pseudorandom_element(cleanable_jokers, pseudoseed('clean')) or nil

                if joker_to_clean then
                    shakecard(joker_to_clean)
                    if(joker_to_clean.edition) then --if joker has an edition
                        if not joker_to_clean.edition.negative then --if joker is not negative
                            joker_to_clean:set_edition(nil)
                        end
                    end
                end
            end
        end,
        loc_def = function(self)
            return { }
        end
    },
    thehand = {
        name = "The Hand",
        text = {
            "Adds the number of times",
            "{C:attention}poker hand{} has been",
            "played this run {X:mult,C:white}X#1#{} to Mult",
            "{C:inactive}~I fear not the one who has tried all hands once,",
            "{C:inactive}but one who has practiced one hand a thousand times.",
        },
        config = { extra = { x_mult_gain = 0.1 } },
        pos = { x = 0, y = 0 },
        rarity = 3,
        cost = 8,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.debuff then return nil end
            if context.joker_main and context.cardarea == G.jokers and context.scoring_name then
                local gain = 1 + (G.GAME.hands[context.scoring_name].played*self.ability.extra.x_mult_gain)
                return {
                    message = localize{type='variable',key='a_xmult',vars={gain}},
                    x_mult = gain, 
                    colour = G.C.RED
                }
            end
        end,

        loc_def = function(self)
            return { self.ability.extra.x_mult_gain }
        end
    },
    numbergoupfactory = {
        name = "Number Go Up Factory",
        text = {
            "Each {C:attention}Steel{} or {C:attention}Gold Card",
            "held in hand",
            "makes number go up by {X:mult,C:white} X#1# {}",
        },
        config = { extra = { x_mult = 1.25 } },
        pos = { x = 0, y = 0 },
        rarity = 3,
        cost = 10,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = nil,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.debuff then return nil end
            if not context.end_of_round then
                if context.cardarea == G.hand and context.individual and (context.other_card.ability.name == 'Gold Card' or context.other_card.ability.name == 'Steel Card') then
                    if context.other_card.debuff then
                        return {
                            message = localize('k_debuffed'),
                            colour = G.C.RED,
                            card = self,
                        }
                    else
                        return {
                            x_mult = self.ability.extra.x_mult,
                            card = self
                        }
                    end
                end
            end
        end,

        loc_def = function(self)
            return { self.ability.extra.x_mult }
        end
    },
}

function SMODS.INIT.JimbosPlusPlus()
    --localization for the info queue key
    G.localization.descriptions.Other["your_key"] = {
        name = "Example",
        text = {
            "TEXT L1",
            "TEXT L2",
            "TEXT L3"
        }
    }
    init_localization()

    --Create and register jokers
    for k, v in pairs(jokers) do --for every object in 'jokers'
        local joker = SMODS.Joker:new(v.name, k, v.config, v.pos, { name = v.name, text = v.text }, v.rarity, v.cost,
        v.unlocked, v.discovered, v.blueprint_compat, v.eternal_compat, v.effect, v.atlas, v.soul_pos)
        joker:register()

        if not v.atlas then --if atlas=nil then use single sprites. In this case you have to save your sprite as slug.png (for example j_examplejoker.png)
            SMODS.Sprite:new("j_" .. k, SMODS.findModByID(mod_name).path, "j_" .. k .. ".png", 71, 95, "asset_atli")
                :register()
        end

        --add jokers calculate function:
        SMODS.Jokers[joker.slug].calculate = v.calculate
        --add jokers loc_def:
        SMODS.Jokers[joker.slug].loc_def = v.loc_def
        --if tooltip is present, add jokers tooltip
        if (v.tooltip ~= nil) then
            SMODS.Jokers[joker.slug].tooltip = v.tooltip
        end
    end
    --Create sprite atlas
    SMODS.Sprite:new("youratlasname", SMODS.findModByID(mod_name).path, "example.png", 71, 95, "asset_atli")
        :register()
end

------------------------------------
------------MOD CODE END------------
