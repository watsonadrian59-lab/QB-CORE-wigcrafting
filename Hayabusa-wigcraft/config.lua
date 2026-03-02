Config = {}

-- ============================
-- NPC WIG SELL PAYOUT
-- ============================
Config.WigSell = {
    payout = {
        basic_wig = 500,
        premium_wig = 1750,
        dyed_wig = 2000,
        lace_wig = 2500,       -- price per single
        full_lace_wig = 2750,   -- price per item (x3)
        synth_wig = 1300        -- price per item (x5)
    }
}

-- ============================
-- CRAFTING SETTINGS
-- ============================
Config.Crafting = {
    tableModel = "prop_table_03",
    progressTime = 15000
}

-- ============================
-- RECIPES (materials required)
-- ============================
Config.Recipes = {
    basic_wig = {
        materials = {
            wig_mesh = 1,
            wig_cap = 1,
            hair_bundle = 3,
            wig_glue = 1
        }
    },

    premium_wig = {
        materials = {
            wig_mesh = 1,
            wig_cap = 1,
            hair_bundle = 5,
            wig_glue = 2
        }
    },

    dyed_wig = {
        materials = {
            wig_mesh = 1,
            wig_cap = 1,
            hair_bundle = 5,
            wig_glue = 2,
            color_dye = 1
        }
    },

    lace_wig = {
        materials = {
            wig_mesh = 1,
            wig_cap = 1,
            hair_bundle = 5,
            wig_glue = 2,
            color_dye = 1
        }
    },

    full_lace_wig = {   -- FIXED NAME (matches sell & crafting)
        materials = {
            wig_mesh = 1,
            wig_cap = 1,
            hair_bundle = 5,
            wig_glue = 2
        }
    },

    synth_wig = {
        materials = {
            wig_mesh = 1,
            wig_cap = 1,
            hair_bundle = 5,
            wig_glue = 2,
            color_dye = 1
        }
    }
}

-- ============================
-- ANIMATIONS
-- ============================
Config.Anim = {
    craft = {
        dict = "mini@repair",
        anim = "fixing_a_ped"
    },
    deal = {
        dict = "mp_common",
        anim = "givetake1_a"
    }
}