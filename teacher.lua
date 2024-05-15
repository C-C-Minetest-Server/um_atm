local S = minetest.get_translator("um_atm")

teacher.register_turorial("um_atm:tutorial_atm", {
    title = S("Automated Teller Machines"),
    triggers = {
        {
            name = "approach_node",
            nodenames = "group:um_atm",
        },
        {
            name = "obtain_item",
            itemname = "um_atm:atm_1",
        },
        {
            name = "obtain_item",
            itemname = "um_atm:atm_2",
        },
        {
            name = "obtain_item",
            itemname = "um_atm:atm_3",
        },
    },

    {
        texture = "um_atm_tutorial_1.png",
        text =
            S("Automated Teller Machines (ATM) can withdrawal or deposit money. " ..
                "There are three models, with model 3 being the most feature-rich."),
    },
    {
        texture = "um_atm_tutorial_2.png",
        text =
            S("Right-click ATMs to open their interface. " ..
                "The following buttons may be avaliable depending on the model:") ..
            "\n\n" ..
            "* " .. S("Numbers: Withdrawal or deposit this many banknotes.") .. "\n" ..
            "* " .. S("\"ALL\": Withdrawal or deposit all banknotes of this type.") ..
            "\n\n" ..
            S("Positive signs represent withdrawal, and negative signs represent deposit. " ..
                "The \"ALL\" buttons are only available on ATM model 3.")
    },
})
