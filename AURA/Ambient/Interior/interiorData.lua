local this = {}

this.statics = {
    ["Caves"] = {
        "in_moldcave",
        "in_mudcave",
        "in_lavacave",
        "in_pycave",
        "in_bonecave",
        "in_bc_cave",
        "in_m_sewer",
        "in_sewer",
    },
    ["Daedric"] = {
        "in_dae_hall",
        "in_dae_room",
        "in_dae_pillar",
    },
    ["Dwemer"]= {
        "in_dwrv_hall",
        "in_dwrv_corr",
        "in_dwe_corr",
        "in_dwe_archway",
    },
    ["Ice Caves"] = {
        "bm_ic_",
        "bm_ka",
    },
}

this.names = {
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
        "Maar Gan Shrine",
        "Vos Chapel",
        "High Fane",
        "Necrom",
        "Holamayan"
    },
    ["Library"] = {
        "Library",
    }
}

return this