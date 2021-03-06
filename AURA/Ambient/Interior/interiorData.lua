local this = {}

this.statics = {
    ["Abandoned"] = {
        "in_stronghold",
        "in_strong",
        "in_strongruin",
        "in_sewer",
        "t_ayl_dngruin",
        "t_bre_dngruin",
        "t_de_dngrtrongh",
        "t_he_dngdirenni",
        "t_imp_dngruincyr",
        "t_imp_dngsewers",
        "in_om_",
    },
    ["Caves"] = {
        "in_moldcave",
        "in_mudcave",
        "in_lavacave",
        "in_pycave",
        "in_bonecave",
        "in_bc_cave",
        "in_m_sewer",
        "in_sewer",
        "ab_in_kwama",
        "ab_in_lava",
        "ab_in_mvcave",
        "t_cyr_cavegc",
        "t_glb_cave",
        "t_mw_cave",
        "t_sky_cave"
    },
    ["Daedric"] = {
        "in_dae_hall",
        "in_dae_room",
        "in_dae_pillar",
        "t_dae_dngruin"
    },
    ["Dwemer"]= {
        "in_dwrv_hall",
        "in_dwrv_corr",
        "in_dwe_corr",
        "in_dwe_archway",
        "t_dwe_dngruin",
    },
    ["Ice Caves"] = {
        "bm_ic_",
        "bm_ka",
    },
}

this.names = {
    ["Alchemist"] = {
        "Alchemist",
        "Apothecary",
        "Tel Uvirith, Omavel's House",
        "Healer",
    },
    ["Mages"] = {
        "Mages Guild",
        "Mage's Guild",
        "Guild of Mages"
    },
    ["Fighters"] = {
        "Fighters Guild",
        "Fighter's Guild",
        "Guild of Fighters",
    },
    ["Temple"] = {
        "Temple",
        "Maar Gan, Shrine",
        "Vos Chapel",
        "High Fane",
        "Fane of the Ancestors",
        "Tiriramannu",
    },
    ["Library"] = {
        "Library",
        "Bookseller",
        "Books"
    },
    ["Smith"] = {
        "Smith",
        "Armorer",
        "Weapons",
        "Armor",
        "Smithy",
        "Weapon",
        "Armors",
        "Blacksmith",
    },
    ["Trader"] = {
        "Trader",
        "Pawnbroker",
        "Merchandise",
        "Merchant",
        "Goods",
        "Outfitter",
        "Laborers",
        "Brewers",
        "Tradehouse",
        "Hostel",
    },
    ["Clothier"] = {
        "Clothier",
        "Tailors",
    },
    ["Tomb"]= {
        "Tomb",
        "Burial",
        "Crypt",
        "Barrow",
        "Catacomb",
    }
}

this.tavernNames = {
    ["Dark Elf"] = {
        --[["Cornerclub",
        "Corner Club",
        "Tradehouse",]]
        "Rat in the Pot",
        "House of Earthly Delights",
        "Elven Nations"
    },
    ["Imperial"] = {
        "Ebonheart, Six Fishes",
        "Arrille"
    },
    ["Nord"] = {
        "Skaal Village, The Greathall",
        "Solstheim, Thirsk"
    }
}

return this