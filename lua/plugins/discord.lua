return {
    "vyfor/cord.nvim",
    build = ":Cord update",
    opts = {
        display = {
            theme = "catppuccin",
            flavor = "accent",
        },

        text = {
            editing = "Editing %s",
            workspace = "Working on %s",
        },

        buttons = {
            {
                label = "GitHub",
                url = "https://github.com/lul-v3"
            }
        }
    }
}
