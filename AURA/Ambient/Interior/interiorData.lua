local this = {}

this.statics = {
    ["Abandoned"] = {
        "in_stronghold",
        "in_strong",
        "in_strongruin",
        "in_sewer",
        "T_Ayl_DngRuin",
        "T_Bre_DngRuin",
        "T_De_DngStrongh",
        "T_He_DngDirenni",
        "T_Imp_DngRuinCyr",
        "T_Imp_DngSewers",
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
        "AB_In_Kwama",
        "AB_In_Lava",
        "AB_In_MVCave",
        "T_Cyr_CaveGC",
        "T_Glb_Cave",
        "T_Mw_Cave",
        "T_Sky_Cave"
    },
    ["Daedric"] = {
        "in_dae_hall",
        "in_dae_room",
        "in_dae_pillar",
        "T_Dae_DngRuin"
    },
    ["Dwemer"]= {
        "in_dwrv_hall",
        "in_dwrv_corr",
        "in_dwe_corr",
        "in_dwe_archway",
        "T_Dwe_DngRuin",
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
        "Tiriramanu",
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
        "Tradehouse"
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
        "Ebonheart, Six Fishes"
    },
    ["Nord"] = {
        "Skaal Village, The Greathall",
        "Solstheim, Thirsk"
    }
}

return this