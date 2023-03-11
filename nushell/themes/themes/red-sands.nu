export def red_sands [] {
    # extra desired values for the red_sands theme
    # which do not fit into any nushell theme
    # these colors should be handledd by the terminal
    # emulator itself
    #
    # background: "#7a251e"
    # foreground: "#d7c9a7"
    # cursor: "#d7c9a7"

    {
        # color for nushell primitives
        separator: "#ffffff"
        leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
        header: "#00bb00"
        empty: "#0072ff"
        bool: "#ffffff"
        int: "#ffffff"
        filesize: "#ffffff"
        duration: "#ffffff"
        date: "#ffffff"
        range: "#ffffff"
        float: "#ffffff"
        string: "#ffffff"
        nothing: "#ffffff"
        binary: "#ffffff"
        cellpath: "#ffffff"
        row_index: "#00bb00"
        record: "#ffffff"
        list: "#ffffff"
        block: "#ffffff"
        hints: "#555555"

        # shapes are used to change the cli syntax highlighting
        shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
        shape_binary: "#ff55ff"
        shape_bool: "#55ffff"
        shape_int: "#ff55ff"
        shape_float: "#ff55ff"
        shape_range: "#e7b000"
        shape_internalcall: "#55ffff"
        shape_external: "#00bbbb"
        shape_externalarg: "#00bb00"
        shape_literal: "#0072ff"
        shape_operator: "#e7b000"
        shape_signature: "#00bb00"
        shape_string: "#00bb00"
        shape_string_interpolation: "#55ffff"
        shape_datetime: "#55ffff"
        shape_list: "#55ffff"
        shape_table: "#0072ae"
        shape_record: "#55ffff"
        shape_block: "#0072ae"
        shape_filepath: "#00bbbb"
        shape_globpattern: "#55ffff"
        shape_variable: "#bb00bb"
        shape_flag: "#0072ae"
        shape_custom: "#00bb00"
        shape_nothing: "#55ffff"
    }
}
