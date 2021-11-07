-- Jor'Mox's Generic Map Script
-- the script self-updates, changing this value will bring an update to all installations
-- make sure versions.lua has the latest version in it
local version = "2.0.22"

-- look into options for non-standard door usage for speedwalk
-- come up with aliases to set translations and custom exits, add appropriate help info

mudlet = mudlet or {}
mudlet.mapper_script = true
map = map or {}

map.help = {[[
    <cyan>炎黄MUD地图导航系统<reset>

    本脚本是根据mudlet内置的Jor'Mox's Generic Map Script修改。
    <red>注意：使用时请禁用mudlet内置的generic_mapper脚本。<reset>

    <cyan>基本命令:<reset>
        These are commands used to get the mapper functional on a basic level

        <link: show>map show</link> - Displays or hides a map window
        <link: quick start>map basics</link> - Shows a quick-start guide with some basic information to
            help get the script working
        <link: 1>map help <optional command name></link> - Shows either this help file or the
            help file for the command given
        <link: find prompt>find prompt</link> - Instructs the script to look for a prompt that matches
            a known pattern
        <link: prompt>map prompt</link> - Provides a specific pattern to the script that matches
            your prompt, uses Lua string-library patterns
        <link: ignore>map ignore</link> - Provides a specific pattern for the script to ignore,
            uses Lua string-library patterns
        <link: debug>map debug</link> - Toggles on debug mode, in which extra messages are shown
            with the intent of assisting in troubleshooting getting the
            script setup
        <link: me>map me</link> - Locates the user on the map, if possible
        <link: path>map path <room name> <; optional area name></link> - Finds a walking path to
            the named room, in the named area if specified
        <link: character>map character <name></link> - Sets a given name as the current character for
            the purposes of the script, used for different prompt patterns
            and recall locations
        <link: recall>map recall</link> - Sets the current room as the recall location of the
            current character
        <link: config>map config <configuration> <optional value></link> - Sets or toggles the
            given configuration either turning it on or off, if no value is
            given, or sets it to the given value
        <link: window>map window <configuration> <value></link> - Sets the given configuration for
            the map window to the given value
        <link: translate>map translate <english direction> <translated long direction></link>
            <link: translate><translated short direction></link> - Sets the provided translations for
            the given english direction word.

    <cyan>Mapping Commands:<reset>
        These are commands used in the process of actually creating a map

        <link: start mapping>start mapping <optional area name></link> - Starts adding content to the
            map, using either the area of the room the user is currently in,
            or the area name provided
        <link: stop mapping>stop mapping</link> - Stops adding content to the map
        <link: set area>set area <area name></link> - Moves the current room to the named area
        <link: mode>map mode <lazy, simple, normal or complex></link> - Sets the mapping mode, which
            defines how new rooms are added to the map.
        <link: add door>add door <direction> <optional door status> <optional one way></link> -
            Creates a door in the given direction, with the given status
            (default closed), in both directions, unless a one-direction door
            is specified
        <link: add portal>add portal <entry command></link> - Creates a portal in the current room,
            using the given command for entry
        <link: shift>shift <direction></link> - Moves the current room on the map in the given
            direction
        <link: merge rooms>merge rooms</link> - Combines overlapping rooms that have the same name into
            a single room
        <link: clear moves>clear moves</link> - Clears the list of movement commands maintained by the
            script
        <link: set exit>set exit <direction> <roomID></link> - Creates a one-way exit in the given
            direction to the room with the specified roomID, can also be used
            with portals
        <link: areas>map areas</link> - Shows a list of all area, with links to show a list of
            rooms in the area
        <link: rooms>map rooms <area name></link> - Shows a list of rooms in the named area

    <cyan>Sharing and Backup Commands:<reset>

        <link: save>map save</link> - Creates a backup of the map
        <link: load>map load <remote address></link> - Loads a map backup, or a map file from a
            remote address
        <link: export>map export <area name></link> - Creates a file from the named area that can
            be shared
        <link: import>map import <area name></link> - Loads an area from a file

    <cyan>Mapping Events:<reset>
        These events are used by triggers to direct the script's behavior

        <link: onNewRoom>onNewRoom</link> - Signals that a room has been detected, optional exits
            argument
        <link: onMoveFail>onMoveFail</link> - Signals that an attempted move failed
        <link: onForcedMove>onForcedMove</link> - Signals that the character moved without a command
            being entered, required direction argument
        <link: onRandomMove>onRandomMove</link> - Signals that the character moved in an unknown
            direction without a command being entered
        <link: onVisionFail>onVisionFail</link> - Signals that the character moved but some or all of
            the room information was not able to be gathered

    <cyan>Key Variables:<reset>
        These variables are used by the script to keep track of important
            information

        <yellow>map.prompt.room<reset> - Can be set to specify the room name
        <yellow>map.prompt.exits<reset> - Can be set to specify the room exits
        <yellow>map.character<reset> - Contains the current character name
        <yellow>map.save.recall<reset> - Contains a table of recall roomIDs for all
            characters
        <yellow>map.save.prompt_pattern<reset> - Contains a table of prompt patterns for all
            characters
        <yellow>map.save.ignore_patterns<reset> - Contains a table of patterns of text the
            script ignores
        <yellow>map.configs<reset> - Contains a number of different options that can be set
            to modify script behavior
        <yellow>map.currentRoom<reset> - Contains the roomID of the room your character is
            in, according to the script
        <yellow>map.currentName<reset> - Contains the name of the room your character is in,
            according to the script
        <yellow>map.currentExits<reset> - Contains a table of the exits of the room your
            character is in, according to the script
        <yellow>map.currentArea<reset> - Contains the areaID of the area your character is
            in, according to the script
]]}
map.help.save = [[
    <cyan>Map Save<reset>
        syntax: <yellow>map save<reset>

        This command creates a copy of the current map and stores it in the
        profile folder as map.dat. This can be useful for creating a backup
        before adding new content, in case of problems, and as a way to share an
        entire map at once.
]]
map.help.load = [[
    <cyan>Map Load<reset>
        syntax: <yellow>map load <optional download address><reset>

        This command replaces the current map with the map stored as map.dat in
        the profile folder. Alternatively, if a download address is provided, a
        map is downloaded from that location and loaded to replace the current
        map. If no filename is given with the download address, the script tries
        to download map.dat. If a filename is given it MUST end with .dat.
]]
map.help.show = [[
    <cyan>Map Show<reset>
        syntax: <yellow>map show<reset>

        This command shows a map window, as specified by the window configs set
        via the <link: window>map window command</link>. It isn't necessary to use this method to
        show a map window to use this script, any map window will work.
]]
map.help.export = [[
    <cyan>Map Export<reset>
        syntax: <yellow>map export <area name><reset>

        This command creates a file containing all the informatino about the
        named area and stores it in the profile folder, with a file name based
        on the area name. This file can then be imported, allowing for easy
        sharing of single map areas. The file name will be the name of the area
        in all lower case, with spaces replaced with underscores, and a .dat
        file extension.
]]
map.help.import = [[
    <cyan>Map Import<reset>
        syntax: <yellow>map import <area name><reset>

        This command imports a file from the profile folder with a name matching
        the name of the file, and uses it to create an area on the map. The area
        name used can be capitalized or not, and may have either spaces or
        underscores between words. The actual area name is stored within the
        file, and is not set by the area name used in this command.
]]
map.help.start_mapping = [[
    <cyan>Start Mapping<reset>
        syntax: <yellow>start mapping <optional area name><reset>

        This command instructs the script to add new content to the map when it
        is seen. When first used, an area name is mandatory, so that an area is
        created for new rooms to be placed in. If used with an area name while
        the map shows the character within a room on the map, that room will be
        moved to be in the named area, if it is not already in it. If used
        without an area name, the room is not moved, and mapping begins in the
        area the character is currently located in.
]]
map.help.stop_mapping = [[
    <cyan>Stop Mapping<reset>
        syntax: <yellow>stop mapping<reset>

        This command instructs the script to stop adding new content until
        mapping is resumed at a later time. The map will continue to perform
        other functions.
]]
map.help.find_prompt = [[
    <cyan>Find Prompt<reset>
        syntax: <yellow>find prompt<reset>

        This command instructs the script to begin searching newly arriving text
        for something that matches one of its known prompt patterns. If one is
        found, that pattern will be set as the current prompt pattern. This
        should typically be the first command used to set up this script with a
        new profile. If your prompt appears after using this command, but there
        is no message saying that the prompt has been found, it will be
        necessary to use the map prompt command to manually set a pattern.
]]
map.help.prompt = [[
    <cyan>Map Prompt<reset>
        syntax: <yellow>map prompt <prompt pattern><reset>

        This command manually sets a prompt pattern for the script to use.
        Because of the way this script works, the prompt pattern should match
        the entire prompt, so that if the text matching the pattern were
        removed, the line with the prompt would be blank. The patterns must be
        of the type used by the Lua string library. If you are unsure about what
        pattern to use, seek assistance on the Mudlet Forums or the Mudlet
        Discord channel.
]]
map.help.debug = [[
    <cyan>Map Debug<reset>
        syntax: <yellow>map debug<reset>

        This command toggles the map script's debug mode on or off when it is
        used. Debug mode provides some extra messages to help with setting up
        the script and identifying problems to help with troubleshooting. If you
        are getting assistance with setting up this script, using debug mode may
        make the process faster and easier.
]]
map.help.ignore = [[
    <cyan>Map Ignore<reset>
        syntax: <yellow>map ignore <ignore pattern><reset>

        This command adds the given pattern to a list the script maintains to
        help it locate the room name. Any text that might appear after a command
        is sent to move and before the room name appears, or after the prompt
        and before the room name if several movement commands are sent at once,
        should have an ignore pattern added for it.

        If the given pattern is already in the list of ignore patterns, that
        pattern will be removed from the list.
]]
map.help.areas = [[
    <cyan>Map Areas<reset>
        syntax: <yellow>map areas<reset>

        This command displays a linked list of all areas in the map. When
        clicked, the rooms in the selected area will be displayed, as if the
        'map rooms' command had been used with that area as an argument.
]]
map.help.rooms = [[
    <cyan>Map Rooms<reset>
        syntax: <yellow>map rooms <area name><reset>

        This command shows a list of all rooms in the area, with the roomID and
        the room name, as well as a count of how many rooms are in the area
        total. Note that the area name argument is not case sensitive.
]]
map.help.set_area = [[
    <cyan>Set Area<reset>
        syntax: <yellow>set area <area name><reset>

        This command move the current room into the named area, creating the
        area if needed.
]]
map.help.mode = [[
    <cyan>Map Mode<reset>
        syntax: <yellow>map mode <lazy, simple, normal, or complex><reset>

        This command changes the current mapping mode, which determines what
        happens when new rooms are added to the map.

        In lazy mode, connecting exits aren't checked and a room is only added if
        there isn't an adjacent room with the same name.

        In simple mode, if an adjacent room has an exit stub pointing toward the
        newly created room, and the new room has an exit in that direction,
        those stubs are connected in both directions.

        In normal mode (default), the newly created room is connected to the room you left
        from, so long as it has an exit leading in that direction.

        In complex mode, none of the exits of the newly connected room are
        connected automatically when it is created.
]]
map.help.add_door = [[
    <cyan>Add Door<reset>
        syntax: <yellow>add door <direction> <optional none, open, closed, or locked>
        <optional yes or no><reset>

        This command places a door on the exit in the given direction, or
        removes it if "none" is given as the second argument. The door status is
        set as given by the second argument, default "closed". The third
        argument determines if the door is a one-way door, default "no".
]]
map.help.add_portal = [[
    <cyan>Add Portal<reset>
        syntax: <yellow>add portal <optional -f> <entry command><reset>

        This command creates a special exit in the current room that is entered
        by using the given entry command. The given entry command is then sent,
        moving to the destination room. If the destination room matches an
        existing room, the special exit will link to that room, and if not a new
        room will be created. If the optional "-f" argument is given, a new room
        will be created for the destination regardless of if an existing room
        matches the room seen when arriving at the destination.
]]
map.help.shift = [[
    <cyan>Shift<reset>
        syntax: <yellow>shift <direction><reset>

        This command moves the current room one step in the direction given, on
        the map.
]]
map.help.merge_rooms = [[
    <cyan>Merge Rooms<reset>
        syntax: <yellow>merge rooms<reset>

        This command combines all rooms that share the same coordinates and the
        same room name into a single room, with all of the exits preserved and
        combined.
]]
map.help.clear_moves = [[
    <cyan>Clear Moves<reset>
        syntax: <yellow>clear moves<reset>

        This command clears the script's queue of movement commands, and is
        intended to be used after you attempt to move while mapping but the
        movement is prevented in some way that is not caught and handled by a
        trigger that raises the onMoveFail event.
]]
map.help.set_exit = [[
    <cyan>Set Exit<reset>
        syntax: <yellow>set exit <direction> <destination roomID><reset>

        This command sets the exit in the current room in the given direction to
        connect to the target room, as specified by the roomID. This is a
        one-way connection.
]]
map.help.onnewroom = [[
    <cyan>onNewRoom Event<reset>

        This event is raised to inform the script that a room has been detected.
        When raised, a string containing the exits from the detected room should
        be passed as a second argument to the raiseEvent function, unless those
        exits have previously been stored in map.prompt.exits.
]]
map.help.onmovefail = [[
    <cyan>onMoveFail Event<reset>

        This event is raised to inform the script that a move was attempted but
        the character was unable to move in the given direction, causing that
        movement command to be removed from the script's movement queue.
]]
map.help.onforcedmove = [[
    <cyan>onForcedMove Event<reset>

        This event is raised to inform the script that the character moved in a
        specified direction without a command being entered. When raised, a
        string containing the movement direction must be passed as a second
        argument to the raiseEvent function.

        The most common reason for this event to be raised is when a character
        is following someone else.
]]
map.help.onrandommove = [[
    <cyan>onRandomMove Event<reset>

        This event is raised to inform the script that the character has moved
        in an unknown direction. The script will compare the next room seen with
        rooms that are adjacent to the current room to try to determine the best
        match for where the character has gone.

        In some situations, multiple options are equally viable, so mistakes may
        result. The script will automatically keep verifying positioning with
        each step, and automatically correct the shown location on the map when
        possible.
]]
map.help.onvisionfail = [[
    <cyan>onVisionFail Event<reset>

        This event is raised to inform the script that some or all of the room
        information was not able to be gathered, but the character still
        successfully moved between rooms in the intended direction.
]]
map.help.onprompt = [[
    <cyan>onPrompt Event<reset>

        This event can be raised when using a non-conventional setup to trigger
        waiting messages from the script to be displayed. Additionally, if
        map.prompt.exits exists and isn't simply an empty string, raising this
        event will cause the onNewRoom event to be raised as well. This
        functionality is intended to allow people who have used the older
        version of this script to use this script instead, without having to
        modify the triggers they created for it.
]]
map.help.me = [[
    <cyan>Map Me<reset>
        syntax: <yellow>map me<reset>

        This command forces the script to look at the currently captured room
        name and exits, and search for a potentially matching room, moving the
        map if applicable. Note that this command is generally never needed, as
        the script performs a similar search any time the room name and exits
        don't match expectations.
]]
map.help.path = [[
    <cyan>Map Path<reset>
        syntax: <yellow>map path <room name> <; optional area name><reset>

        This command tries to find a walking path from the current room to the
        named room. If an area name is given, only rooms within that area that
        is given are checked. Neither the room name nor the area name are case
        sensitive, but otherwise an exact match is required. Note that a
        semicolon is required between the room name and area name, if an area
        name is given, but spaces before or after the semicolon are optional.

        Example: <yellow>map path main street ; newbie town<reset>
]]
map.help.character = [[
    <cyan>Map Character<reset>
        syntax: <yellow>map character <name><reset>

        This command tells the script what character is currently being used.
        Setting a character is optional, but recall locations and prompt
        patterns are stored by character name, so using this command allows for
        easy switching between different setups. The name given is stored in
        map.character. The name is a case sensitive exact match. The value of
        map.character is not saved between sessions, so this must be set again
        if needed each time the profile is opened.
]]
map.help.recall = [[
    <cyan>Map Recall<reset>
        syntax: <yellow>map recall<reset>

        This command tells the script that the current room is the recall point
        for the current character, as stored in map.character. This information
        is stored in map.save.recall[map.character], and is remembered between
        sessions.
]]
map.help.config = [[
    <cyan>Map Config<reset>
        syntax: <yellow>map config <setting> <optional value><reset>

        This command changes any of the available configurations listed below.
        If no value is given, and the setting is either 'on' or 'off', then the
        value is switched. When naming a setting, spaces can be used in place of
        underscores. Details of what options are available and what each one
        does are provided.

        <yellow>speedwalk_delay<reset> - When using the speedwalk function of the script,
            this is the amount of time the script waits after either sending
            a command or, if speedwalk_wait is set, after arriving in a new
            room, before the next command is sent. This may be any number 0
            or higher.

        <yellow>speedwalk_wait<reset> - When using the speedwalk function of the script,
            this indicates if the script waits for your character to move
            into a new room before sending the next command. This may be true
            or false.

        <yellow>speedwalk_random<reset> - When using the speedwalk function of the script
            with a speedwalk_delay value, introduces a randomness to the wait
            time by adding some amount up to the speedwalk_delay value. This
            may be true or false.

        <yellow>stretch_map<reset> - When adding a new room that would overlap an existing
            room, if this is set the map will stretch out to prevent the
            overlap, with all rooms further in the direction moved getting
            pushed one further in that direction. This may be true or false.

        <yellow>max_search_distance<reset> - When mapping, this is the maximum number of
            rooms that the script will search in the movement direction for a
            matching room before deciding to create a new room. This may be
            false, or any positive whole number. This can also be set to 0,
            which is the same as setting it to false.

        <yellow>search_on_look<reset> - When this is set, using the "look" command causes
            the map to verify your position using the room name and exits
            seen following using the command. This may be true or false.

        <yellow>clear_lines_on_send<reset> - When this is set, any time a command is sent,
            any lines stored from the game used to search for the room name
            are cleared. This may be true or false.

        <yellow>mode<reset> - This is the default mapping mode on startup, and defines how
            new rooms are added to the map. May be "lazy", "simple",
            "normal" or "complex".

        <yellow>download_path<reset> - This is the path that updates are downloaded from.
            This may be any web address where the versions.lua and
            generic_mapper.xml files can be downloaded from.

        <yellow>prompt_test_patterns<reset> - This is a table of default patterns checked
            when using the "find prompt" command. The patterns in this table
            should start with a '^', and be written to be used with the Lua
            string library. Most importantly, '%' is used as the escape
            character instead of '\' as in trigger regex patterns.

        <yellow>custom_exits<reset> - This is a table of custom exit directions and their
            relevant extra pieces of info. Each entry should have the short
            direction as the keyword for a table containing first the long
            direction, then the long direction of the reverse of this
            direction, and then the x, y, and z change in map position
            corresponding to the movement. As an example: us = {'upsouth',
            'downnorth', 0, -1, 1}

        <yellow>custom_name_search<reset> - When this is set, instead of running the default
            function name_search, a user-defined function called
            'mudlet.custom_name_search' is used instead. This may be true or false.

        <yellow>use_translation<reset> - When this is set, the lang_dirs table is used to
            translate movement and status commands in some other language
            into the English used by the script. This may be true or false.

        <yellow>debug<reset> - When this is set, the script will start in debug mode. This
            may be true or false.
]]
map.help.window = [[
    <yellow>Map Window<reset>
        syntax: <yellow>map window <setting> <value><reset>

        This command changes any of the available configurations listed below,
        which determine the appearance and positioning of the map window when
        the 'map show' command is used. Details of what options are available
        and what each one does are provided.

        <yellow>x<reset> - This is the x position of the map window, and should be a
            positive number of pixels or a percentage of the screen width.

        <yellow>y<reset> - This is the y position of the map window, and should be a
            positive number of pixels or a percentage of the screen height.

        <yellow>w<reset> - This is the width of the map window, and should be a positive
            number of pixels or a percentage of the screen width.

        <yellow>h<reset> - This is the height of the map window, and should be a positive
            number of pixels or a percentage of the screen height.

        <yellow>origin<reset> - This is the corner from which the window position is
            measured, and may be 'topright', 'topleft', 'bottomright', or
            'bottomleft'.

        <yellow>shown<reset> - This determines if the map window is shown immediately upon
            connecting to the game. This may be true or false. If you intend
            to have some other script control the map window, this should be
            set to false.
]]
map.help.translate = [[
    <yellow>Map Translate<reset>
        syntax: <yellow>map translate <english direction> <translated long direction>
            <translated short direction><reset>

        This command sets direction translations for the script to use, either
        for commands entered to move around, or listed exits the game shows when
        you enter a room. Available directions: north, south, east, west,
        northwest, northeast, southwest, southeast, up, down, in, and out.
        Also you can customize special commands sent to mud like 'look'.
]]
map.help.quick_start = [[
    <link: quick_start>map basics</link> (quick start guide)
    ----------------------------------------

    Mudlet Mapper works in tandem with a script, and this generic mapper script needs
    to know 2 things to work:
      - <dim_grey>room name<reset> $ROOM_NAME_STATUS ($ROOM_NAME)
      - <dim_grey>exits<reset>     $ROOM_EXITS_STATUS ($ROOM_EXITS)

    1. <link: start mapping>start mapping <optional area name></link>
       If both room name and exits are good, you can start mapping! Give it the
       area name you're currently in, usually optional but required for the first one.
    2. <link: find prompt>find prompt</link>
       Room name or exits aren't recognised? Try this command then. It will make
       the script start looking for a prompt using several standard prompt
       patterns. If a prompt is found, you will be notified, if not, you will
       need to set a prompt pattern yourself using <link: prompt>map prompt</link>.
       Reach out to the <urllink: https://discord.gg/kuYvMQ9>Mudlet community</urllink> for help, we'd be happy to help
       you figure it out!
    3. <link: debug>map debug</link>
       This toggles debug mode. When on, messages will be displayed showing what
       information is captured and a few additional error messages that can help
       with getting the script fully compatible with your game.
    4. <link: 1>map help</link>
       This will bring up a more detailed help file, starting with the available
       help topics.
]]

map.character = map.character or ""
map.prompt = map.prompt or {}
map.save = map.save or {}
map.save.recall = map.save.recall or {}
map.save.prompt_pattern = map.save.prompt_pattern or {}
map.save.ignore_patterns = map.save.ignore_patterns or {}

local oldstring = string
local string = utf8
string.format = oldstring.format
string.trim = oldstring.trim
string.starts = oldstring.starts
string.split = oldstring.split
string.ends = oldstring.ends


local profilePath = getMudletHomeDir()
profilePath = profilePath:gsub("\\", "/")

map.defaults = {
    mode = "lazy", -- can be lazy, simple, normal, or complex
    stretch_map = true,
    search_on_look = true,
    speedwalk_delay = 0.1,
    speedwalk_wait = true,
    speedwalk_random = true,
    max_search_distance = 1,
    clear_lines_on_send = true,
    map_window = {
        x = 0,
        y = 0,
        w = "30%",
        h = "40%",
        origin = "topright",
        shown = false,
    },
    prompt_test_patterns = {"^%[?%a*%]?<.*>", "^%[.*%]%s*>", "^%w*[%.?!:]*>", "^%[.*%]", "^[Hh][Pp]:.*>"},
    custom_exits = {},  -- format: short_exit = {long_exit, reverse_exit, x_dif, y_dif, z_dif}
                        -- ex: { us = {"upsouth", "downnorth", 0, -1, 1}, dn = {"downnorth", "upsouth", 0, 1, -1} }
    custom_name_search = false,
    use_translation = true,
    lang_dirs = {n = 'n', ne = 'ne', nw = 'nw', e = 'e', w = 'w', s = 's', se = 'se', sw = 'sw',
        u = 'u', d = 'd', ["in"] = 'in', out = 'out', north = 'north', northeast = 'northeast',
        east = 'east', west = 'west', south = 'south', southeast = 'southeast', southwest = 'southwest',
        northwest = 'northwest', up = 'up', down = 'down', l = 'l', look = 'look',
        ed = 'ed', eu = 'eu', eastdown = 'eastdown', eastup = 'eastup',
        nd = 'nd', nu = 'nu', northdown = 'northdown', northup = 'northup',
        sd = 'sd', su = 'su', southdown = 'southdown', southup = 'southup',
        wd = 'wd', wu = 'wu', westdown = 'westdown', westup = 'westup',
    },
    debug = false,
    download_path = "https://raw.githubusercontent.com/Mudlet/Mudlet/development/src/mudlet-lua/lua/generic-mapper",
}

local move_queue, lines = {}, {}
local find_portal, vision_fail, room_detected, random_move, force_portal, find_prompt, downloading, walking, help_shown
local mt = getmetatable(map) or {}

local exitmap = {
    n = 'north',    ne = 'northeast',   nw = 'northwest',   e = 'east',
    w = 'west',     s = 'south',        se = 'southeast',   sw = 'southwest',
    u = 'up',       d = 'down',         ["in"] = 'in',      out = 'out',
    l = 'look',
    ed = 'eastdown',    eu = 'eastup',  nd = 'northdown',   nu = 'northup',
    sd = 'southdown',   su = 'southup', wd = 'westdown',    wu = 'westup',
}

local short = {}
for k, v in pairs(exitmap) do
  short[v] = k
end

local stubmap = {
    north = 1,      northeast = 2,      northwest = 3,      east = 4,
    west = 5,       south = 6,          southeast = 7,      southwest = 8,
    up = 9,         down = 10,          ["in"] = 11,        out = 12,
    northup = 13,   southdown = 14,     southup = 15,       northdown = 16,
    eastup = 17,    westdown = 18,      westup = 19,        eastdown = 20,
    [1] = "north",  [2] = "northeast",  [3] = "northwest",  [4] = "east",
    [5] = "west",   [6] = "south",      [7] = "southeast",  [8] = "southwest",
    [9] = "up",     [10] = "down",      [11] = "in",        [12] = "out",
    [13] = "northup", [14] = "southdown",[15] = "southup",  [16] = "northdown",
    [17] = "eastup", [18] = "westdown", [19] = "westup",    [20] = "eastdown",
}

local coordmap = {
    [1] = {0,1,0},      [2] = {1,1,0},      [3] = {-1,1,0},     [4] = {1,0,0},
    [5] = {-1,0,0},     [6] = {0,-1,0},     [7] = {1,-1,0},     [8] = {-1,-1,0},
    [9] = {0,0,1},      [10] = {0,0,-1},    [11] = {0,0,0},     [12] = {0,0,0},
    [13] = {0,1,1},     [14] = {0,-1,-1},   [15] = {0,-1,1},    [16] = {0,1,-1},
    [17] = {1,0,1},     [18] = {-1,0,-1},   [19] = {-1,0,1},    [20] = {1,0,-1},
}

local reverse_dirs = {
    north = "south", south = "north", west = "east", east = "west", up = "down",
    down = "up", northwest = "southeast", northeast = "southwest", southwest = "northeast",
    southeast = "northwest", ["in"] = "out", out = "in",
    northup = "southdown", southdown = "northup", southup = "northdown", northdown = "southup",
    eastup = "westdown", westdown = "eastup", westup = "eastdown", eastdown = "westup",
}

local wait_echo = {}
local mapper_tag = "<112,229,0>(<73,149,0>mapper<112,229,0>): <255,255,255>"
local debug_tag = "<255,165,0>(<200,120,0>debug<255,165,0>): <255,255,255>"
local err_tag = "<255,0,0>(<178,34,34>error<255,0,0>): <255,255,255>"

local function config()
  local defaults = map.defaults
  local configs = map.configs or {}
  local path = profilePath .. "/map downloads"
  if not io.exists(path) then
    lfs.mkdir(path)
  end
  -- load stored configs from file if it exists
  if io.exists(path .. "/configs.lua") then
    table.load(path .. "/configs.lua", configs)
  end
  -- overwrite default values with stored config values
  configs = table.update(defaults, configs)
  map.configs = configs
  map.configs.translate = {}
  for k, v in pairs(map.configs.lang_dirs) do
    map.configs.translate[v] = k
  end
  -- incorporate custom exits
  for k, v in pairs(map.configs.custom_exits) do
    exitmap[k] = v[1]
    reverse_dirs[v[1]] = v[2]
    short[v[1]] = k
    local count = #coordmap + 1
    coordmap[count] = {v[3], v[4], v[5]}
    stubmap[count] = v[1]
    stubmap[v[1]] = count
  end

  -- setup metatable to store sensitive values
  local protected = {"mapping", "currentRoom", "currentName", "currentExits", "currentArea",
                     "prevRoom", "prevName", "prevExits", "mode", "version"}
  mt = getmetatable(map) or {}
  mt.__index = mt
  mt.__newindex =
    function(tbl, key, value)
      if not table.contains(protected, key) then
        rawset(tbl, key, value)
      else
        error("Protected Map Table Value")
      end
    end
  mt.set =
    function(key, value)
      if table.contains(protected, key) then
        mt[key] = value
      end
    end
  setmetatable(map, mt)
  map.set("mode", configs.mode)
  map.set("version", version)
  local saves = {}
  if io.exists(path .. "/map_save.dat") then
    table.load(path .. "/map_save.dat", saves)
  end
  saves.prompt_pattern = saves.prompt_pattern or {}
  saves.ignore_patterns = saves.ignore_patterns or {}
  saves.recall = saves.recall or {}
  map.save = saves

  if map.configs.map_window.shown then
    map.showMap(true)
  end
end

local function parse_help_text(text)
  text = text:gsub("%$ROOM_NAME_STATUS", (map.currentName and map.currentName ~= "") and '✔️' or '❌')
  text = text:gsub("%$ROOM_NAME", map.currentName or '')

  text = text:gsub("%$ROOM_EXITS_STATUS", (not map.currentExits or table.is_empty(map.currentExits)) and '❌' or '✔️')
  text = text:gsub("%$ROOM_EXITS", map.currentExits and table.concat(map.currentExits, ' ') or '')

  return text
end

function map.show_help(cmd)
  if cmd and cmd ~= "" then
    if cmd:starts("map ") then
      cmd = cmd:sub(5)
    end
    cmd = cmd:lower():gsub(" ", "_")
    if not map.help[cmd] then
      map.echo("No help file on that command.")
    end
  else
    cmd = 1
  end
  for w in parse_help_text(map.help[cmd]):gmatch("[^\n]*\n") do
    local url, target = rex.match(w, [[<(url)?link: ([^>]+)>]])
    -- lrexlib returns a non-capture as 'false', so determine which variable the capture went into
    if target == nil then
      target = url
    end
    if target then
      local before, linktext, _, link, _, after, ok =
        rex.match(w, [[(.*)<((url)?link): [^>]+>(.*)<\/(url)?link>(.*)]], 0, 'm')
      -- could not get rex.match to capture the newline - fallback to string.match
      local _, _, after = w:match("(.*)<u?r?l?link: [^>]+>(.*)</u?r?l?link>(.*)")
      cecho(before)
      fg("yellow")
      setUnderline(true)
      if linktext == "urllink" then
        echoLink(link, [[openWebPage("]] .. target .. [[")]], "Open Mudlet Discord", true)
      elseif target ~= "1" then
        echoLink(link, [[map.show_help("]] .. target .. [[")]], "View: map help " .. target, true)
      else
        echoLink(link, [[map.show_help()]], "View: map help", true)
      end
      setUnderline(false)
      resetFormat()
      if after then
        cecho(after)
      end
    else
      cecho(w)
    end
  end
  echo("\n")
end

local bool_configs = {'stretch_map', 'search_on_look', 'speedwalk_wait', 'speedwalk_random',
                      'clear_lines_on_send', 'debug', 'custom_name_search', 'use_translation'}
-- function intended to be used by an alias to change config values and save them to a file for later
function map.setConfigs(key, val, sub_key)
  if val == "off" or val == "false" then
    val = false
  elseif val == "on" or val == "true" then
    val = true
  end
  local toggle = false
  if val == nil or val == "" then
    toggle = true
  end
  key = key:gsub(" ", "_")
  if tonumber(val) then
    val = tonumber(val)
  end
  if not toggle then
    if key == "map_window" then
      if map.configs.map_window[sub_key] then
        map.configs.map_window[sub_key] = val
        map.echo(string.format("Map config %s set to: %s", sub_key, tostring(val)))
      else
        map.echo("Unknown map config.", false, true)
      end
    elseif key == "lang_dirs" then
      sub_key = exitmap[sub_key] or sub_key
      if map.configs.lang_dirs[sub_key] then
        local long_dir, short_dir = val[1], val[2]
        if #long_dir < #short_dir then
          long_dir, short_dir = short_dir, long_dir
        end
        map.configs.lang_dirs[sub_key] = long_dir
        map.configs.lang_dirs[short[sub_key]] = short_dir
        map.echo(string.format("Direction/command %s, abbreviated as %s, now interpreted as %s.", long_dir, short_dir, sub_key))
        map.configs.translate = {}
        for k, v in pairs(map.configs.lang_dirs) do
          map.configs.translate[v] = k
        end
      else
        map.echo("Invalid direction/command.", false, true)
      end
    elseif key == "prompt_test_patterns" then
      if not table.contains(map.configs.prompt_test_patterns) then
        table.insert(map.configs.prompt_test_patterns, val)
        map.echo("Prompt pattern added to list: " .. val)
      else
        table.remove(map.configs.prompt_test_patterns, table.index_of(map.configs.prompt_test_patterns, val))
        map.echo("Prompt pattern removed from list: " .. val)
      end
    elseif key == "custom_exits" then
      if type(val) == "table" then
        for k, v in pairs(val) do
          map.configs.custom_exits[k] = v
          map.echo(string.format("Custom Exit short direction %s, long direction %s", k, v[1]))
          map.echo(string.format("    set to: x: %s, y: %s, z: %s, reverse: %s", v[3], v[4], v[5], v[2]))
        end
      else
        map.echo("Custom Exit config must be in the form of a table.", false, true)
      end
    elseif map.configs[key] ~= nil then
      map.configs[key] = val
      map.echo(string.format("Config %s set to: %s", key, tostring(val)))
    else
      map.echo("Unknown configuration.", false, true)
      return
    end
  elseif toggle then
    if (type(map.configs[key]) == "boolean" and table.contains(bool_configs, key)) then
      map.configs[key] = not map.configs[key]
      map.echo(string.format("Config %s set to: %s", key, tostring(map.configs[key])))
    elseif key == "map_window" and sub_key == "shown" then
      map.configs.map_window.shown = not map.configs.map_window.shown
      map.echo(string.format("Map config %s set to: %s", "shown", tostring(map.configs.map_window.shown)))
    else
      map.echo("Unknown configuration.", false, true)
      return
    end
  end
  table.save(profilePath .. "/map downloads/configs.lua", map.configs)
  config()
end

local function show_err(msg, debug)
  map.echo(msg, debug, true)
  error(msg, 2)
end

local function print_echoes(what, debug, err)
  moveCursorEnd("main")
  local curline = getCurrentLine()
  if curline ~= "" then
    echo("\n")
  end
  decho(mapper_tag)
  if debug then
    decho(debug_tag)
  end
  if err then
    decho(err_tag)
  end
  cecho(what)
  echo("\n")
end

local function print_wait_echoes()
  for k, v in ipairs(wait_echo) do
    print_echoes(v[1], v[2], v[3])
  end
  wait_echo = {}
end

function map.echo(what, debug, err, wait)
  if debug and not map.configs.debug then
    return
  end
  what = tostring(what) or ""
  if wait then
    table.insert(wait_echo, {what, debug, err})
    return
  end
  print_wait_echoes()
  print_echoes(what, debug, err)
end

local function set_room(roomID)
  -- moves the map to the new room
  if map.currentRoom ~= roomID then
    map.set("prevRoom", map.currentRoom)
    map.set("currentRoom", roomID)
  end
  if getRoomName(map.currentRoom) ~= map.currentName then
    map.set("prevName", map.currentName)
    map.set("prevExits", map.currentExits)
    map.set("currentName", getRoomName(map.currentRoom))
    map.set("currentExits", getRoomExits(map.currentRoom))
    -- check handling of custom exits here
    for i = 13, #stubmap do
      map.currentExits[stubmap[i]] = tonumber(getRoomUserData(map.currentRoom, "exit " .. stubmap[i]))
    end
  end
  map.set("currentArea", getRoomArea(map.currentRoom))
  centerview(map.currentRoom)
  raiseEvent("onMoveMap", map.currentRoom)
end

local function add_door(roomID, dir, status)
  -- create or remove a door in the designated direction
  -- consider options for adding pickable and passable information
  dir = exitmap[dir] or dir
  if not table.contains(exitmap, dir) then
    error("Add Door: invalid direction.", 2)
  end
  if type(status) ~= "number" then
    status = assert(table.index_of({"none", "open", "closed", "locked"}, status), "Add Door: Invalid status, must be none, open, closed, or locked") - 1
  end
  local exits = getRoomExits(roomID)
  -- check handling of custom exits here
  if not exits[dir] then
    setExitStub(roomID, stubmap[dir], true)
  end
  -- check handling of custom exits here
  if not table.contains({'u', 'd'}, short[dir]) then
    setDoor(roomID, short[dir], status)
  else
    setDoor(roomID, dir, status)
  end
end

local function check_doors(roomID, exits)
  -- looks to see if there are doors in designated directions
  -- used for room comparison, can also be used for pathing purposes
  if type(exits) == "string" then
    exits = {exits}
  end
  local statuses = {}
  local doors = getDoors(roomID)
  local dir
  for k, v in pairs(exits) do
    dir = short[k] or short[v]
    if table.contains({'u', 'd'}, dir) then
      dir = exitmap[dir]
    end
    if not doors[dir] or doors[dir] == 0 then
      return false
    else
      statuses[dir] = doors[dir]
    end
  end
  return statuses
end

local function find_room(name, area)
  -- looks for rooms with a particular name, and if given, in a specific area
  local rooms = searchRoom(name)
  if type(area) == "string" then
    local areas = getAreaTable() or {}
    for k, v in pairs(areas) do
      if string.lower(k) == string.lower(area) then
        area = v
        break
      end
    end
    area = areas[area] or nil
  end
  for k, v in pairs(rooms) do
    if string.lower(v) ~= string.lower(name) then
      rooms[k] = nil
    elseif area and getRoomArea(k) ~= area then
      rooms[k] = nil
    end
  end
  return rooms
end

local function getRoomStubs(roomID)
  -- turns stub info into table similar to exit table
  local stubs = getExitStubs(roomID)
  if type(stubs) ~= "table" then
    stubs = {}
  end
  -- check handling of custom exits here
  local tmp
  for i = 13, #stubmap do
    tmp = tonumber(getRoomUserData(roomID, "stub " .. stubmap[i]))
    if tmp then
      table.insert(stubs, tmp)
    end
  end
  local exits = {}
  for k, v in pairs(stubs) do
    exits[stubmap[v]] = 0
  end
  return exits
end

local function connect_rooms(ID1, ID2, dir1, dir2, no_check)
  -- makes a connection between rooms
  -- display([[connect_rooms]])
  -- can make backwards connection without a check
  local match = false
  if not ID1 and ID2 and dir1 then
    error("Connect Rooms: Missing Required Arguments.", 2)
  end
  dir2 = dir2 or reverse_dirs[dir1]
  -- display(ID1.." "..ID2.." "..dir1.." "..dir2) -- "134 133 eastup westdown"
  -- check handling of custom exits here
  if stubmap[dir1] <= 12 then
    setExit(ID1, ID2, stubmap[dir1])
  else
    addSpecialExit(ID1, ID2, dir1)
    setRoomUserData(ID1, "exit " .. dir1, ID2)
  end
  if stubmap[dir1] > 12 then
    -- check handling of custom exits here
    setRoomUserData(ID1, "stub " .. dir1, "")
  end
  local doors1, doors2 = getDoors(ID1), getDoors(ID2)
  local dstatus1, dstatus2 =
    doors1[short[dir1]] or doors1[dir1], doors2[short[dir2]] or doors2[dir2]
  if dstatus1 ~= dstatus2 then
    if not dstatus1 then
      add_door(ID1, dir1, dstatus2)
    elseif not dstatus2 then
      add_door(ID2, dir2, dstatus1)
    end
  end
  if map.mode ~= "complex" then
    local stubs = getRoomStubs(ID2)
    if stubs[dir2] then
      match = true
    end
    if (match or no_check) then
      -- check handling of custom exits here
      if stubmap[dir1] <= 12 then
        setExit(ID2, ID1, stubmap[dir2])
      else
        addSpecialExit(ID2, ID1, dir2)
        setRoomUserData(ID2, "exit " .. dir2, ID1)
      end
      if stubmap[dir2] > 12 then
        -- check handling of custom exits here
        setRoomUserData(ID2, "stub " .. dir2, "")
      end
    end
  end
end

local function check_room(roomID, name, exits, onlyName)
  -- check to see if room name or/and exits match expectations
  if not roomID then
    error("Check Room Error: No ID", 2)
  end
  -- 直接根据hash判断
  if gmcp.Room.Info.hash ~= getRoomHashByID(roomID) then
    return false
  else
    return true
  end
  -- todo 清除以下代码
  if name ~= getRoomName(roomID) then
    return false
  end
  -- used in mode "lazy" to match only the room name
  if onlyName then
    return true
  end
  local t_exits = table.union(getRoomExits(roomID), getRoomStubs(roomID))
  -- check handling of custom exits here
  for i = 13, #stubmap do
    t_exits[stubmap[i]] = tonumber(getRoomUserData(roomID, "exit " .. stubmap[i]))
  end
  for k, v in ipairs(exits) do
    if short[v] and not table.contains(t_exits, v) then
      return false
    end
    t_exits[v] = nil
  end
  return table.is_empty(t_exits) or check_doors(roomID, t_exits)
end

local function stretch_map(dir, x, y, z)
  -- stretches a map to make room for just added room that would overlap with existing room
  local dx, dy, dz
  if not dir then
    return
  end
  for k, v in pairs(getAreaRooms(map.currentArea)) do
    if v ~= map.currentRoom then
      dx, dy, dz = getRoomCoordinates(v)
      if dx >= x and string.find(dir, "east") then
        dx = dx + 1
      elseif dx <= x and string.find(dir, "west") then
        dx = dx - 1
      end
      if dy >= y and string.find(dir, "north") then
        dy = dy + 1
      elseif dy <= y and string.find(dir, "south") then
        dy = dy - 1
      end
      if dz >= z and string.find(dir, "up") then
        dz = dz + 1
      elseif dz <= z and string.find(dir, "down") then
        dz = dz - 1
      end
      setRoomCoordinates(v, dx, dy, dz)
    end
  end
end

function map.create_room(name, x, y, z)
  local newID = createRoomID()
  addRoom(newID)
  setRoomArea(newID, gmcp.Room.Info.area)
  setRoomName(newID, name)
  setRoomCoordinates(newID, x, y, z)
  map.echo([[---create_room---]])
end

local function create_room(name, exits, dir, coords)
  -- makes a new room with captured name and exits
  -- links with other rooms as appropriate
  -- links to adjacent rooms in direction of exits if in simple mode
  -- display(coords)
  name = gmcp.Room.Info.name
  exits = gmcp.Room.Info.exits
  if map.mapping then
    -- name = map.sanitizeRoomName(name)
    -- map.echo("New Room: " .. name, false, false, (dir or find_portal or force_portal) and true or false)
    local newID = createRoomID()
    addRoom(newID)
    setRoomArea(newID, map.currentArea)
    setRoomName(newID, name)
    setRoomIDbyHash(newID, gmcp.Room.Info.hash)
    for k, v in ipairs(exits) do
      if stubmap[v] then
        if stubmap[v] <= 12 then
          setExitStub(newID, stubmap[v], true)
        else
          -- if the table has just a few values, you can skip making a local, named table:
          if string.find(v, "up") then
            setExitStub(newID, "up", true)
          elseif string.find(v, "down") then
            setExitStub(newID, "down", true)
          end
          -- check handling of custom exits here
          setRoomUserData(newID, "stub " .. v, stubmap[v])
        end
      end
    end
    if dir then
      connect_rooms(map.currentRoom, newID, dir)
    elseif find_portal or force_portal then
      addSpecialExit(map.currentRoom, newID, (find_portal or force_portal))
      setRoomUserData(newID, "portals", tostring(map.currentRoom) .. ":" .. (find_portal or force_portal))
    end
    setRoomCoordinates(newID, unpack(coords))
    local pos_rooms = getRoomsByPosition(map.currentArea, unpack(coords))
    if
      not (find_portal or force_portal) and map.configs.stretch_map and table.size(pos_rooms) > 1
    then
      set_room(newID)
      stretch_map(dir, unpack(coords))
    end
    if map.mode == "simple" then
      local x, y, z = unpack(coords)
      local dx, dy, dz, rooms
      for k, v in ipairs(exits) do
        if stubmap[v] then
          dx, dy, dz = unpack(coordmap[stubmap[v]])
          rooms = getRoomsByPosition(map.currentArea, x + dx, y + dy, z + dz)
          if table.size(rooms) == 1 then
            connect_rooms(newID, rooms[0], v)
          end
        end
      end
    end
    set_room(newID)
  end
end

local function find_area_limits(areaID)
  -- used to find min and max coordinate limits for an area
  if not areaID then
    error("Find Limits: Missing area ID", 2)
  end
  local rooms = getAreaRooms(areaID)
  local minx, miny, minz = getRoomCoordinates(rooms[0])
  local maxx, maxy, maxz = minx, miny, minz
  local x, y, z
  for k, v in pairs(rooms) do
    x, y, z = getRoomCoordinates(v)
    minx = math.min(x, minx)
    maxx = math.max(x, maxx)
    miny = math.min(y, miny)
    maxy = math.max(y, maxy)
    minz = math.min(z, minz)
    maxz = math.max(z, maxz)
  end
  return minx, maxx, miny, maxy, minz, maxz
end

local function find_link(name, exits, dir, max_distance)
  -- search for matching room in desired direction
  -- in lazy mode check_room search only by name
  -- display([[find_link]]..name)
  local x, y, z = getRoomCoordinates(map.currentRoom)
  if map.mapping and x then
    if max_distance < 1 then
      max_distance = nil
    else
      max_distance = max_distance - 1
    end
    if not stubmap[dir] or not coordmap[stubmap[dir]] then
      return
    end
    local dx, dy, dz = unpack(coordmap[stubmap[dir]])
    local room = getRoomIDbyHash(gmcp.Room.Info.hash)
    if room > 0 then
      connect_rooms(map.currentRoom, room, dir)
      set_room(room)
    else
      x, y, z = getRoomCoordinates(map.currentRoom)
      map.echo([[[find_link]create room from ]] .. x .. "," .. y .. "," .. z .. " at " .. dir)
      create_room(name, exits, dir, {x + dx, y + dy, z + dz})
    end
  end
end

local function move_map()
  -- tries to move the map to the next room
  local move = table.remove(move_queue, 1)
  if move or random_move then
    local exits = (map.currentRoom and getRoomExits(map.currentRoom)) or {}
    -- check handling of custom exits here
    if map.currentRoom then
      for i = 13, #stubmap do
        exits[stubmap[i]] = tonumber(getRoomUserData(map.currentRoom, "exit " .. stubmap[i]))
      end
    end
    local special = (map.currentRoom and getSpecialExitsSwap(map.currentRoom)) or {}
    if move and not exits[move] and not special[move] then
      for k, v in pairs(special) do
        if string.starts(k, move) then
          move = k
          break
        end
      end
    end
    if find_portal then
      map.find_me(map.currentName, map.currentExits, move)
      find_portal = false
    elseif force_portal then
      find_portal = false
      map.echo("Creating portal destination")
      map.echo([[---[move_map]create room---]])
      create_room(map.currentName, map.currentExits, nil, {getRoomCoordinates(map.currentRoom)})
      force_portal = false
    elseif move == "recall" and map.save.recall[map.character] then
      set_room(map.save.recall[map.character])
    elseif move == map.configs.lang_dirs['look'] and map.currentRoom and not check_room(map.currentRoom, map.currentName, map.currentExits) then
      -- this check isn't working as intended, find out why
      map.find_me(map.currentName, map.currentExits)
    else
      local onlyName
      if map.mode == "lazy" then
        onlyName = true
      else
        onlyName = false
      end
      if exits[move] and (vision_fail or check_room(exits[move], map.currentName, map.currentExits, onlyName)) then
        set_room(exits[move])
      elseif special[move] and (vision_fail or check_room(special[move], map.currentName, map.currentExits, onlyName)) then
        set_room(special[move])
      elseif not vision_fail then
        if map.mapping and move then
          find_link(map.currentName, map.currentExits, move, map.configs.max_search_distance)
        else
          map.find_me(map.currentName, map.currentExits, move)
        end
      end
    end
    vision_fail = false
  end
end

local function capture_move_cmd(dir, priority)
  -- captures valid movement commands
  local configs = map.configs
  if configs.clear_lines_on_send then
    lines = {}
  end
  dir = string.lower(dir)
  if dir == "/" then
    dir = "recall"
  end
  if dir == configs.lang_dirs['l'] then
    dir = configs.lang_dirs['look']
  end
  if configs.use_translation then
    dir = configs.translate[dir] or dir
  end
  local door = string.match(dir, "open (%a+)")
  if map.mapping and door and (exitmap[door] or short[door]) then
    local doors = getDoors(map.currentRoom)
    if not doors[door] and not doors[short[door]] then
      map.set_door(door, "", "")
    end
  end
  local portal = string.match(dir, "enter (%a+)")
  if map.mapping and portal then
    local portals = getSpecialExitsSwap(map.currentRoom)
    if not portals[dir] then
      map.set_portal(dir, true)
    end
  end
  if table.contains(exitmap, dir) or string.starts(dir, "enter ") or dir == "recall" then
    if priority then
      table.insert(move_queue, 1, exitmap[dir] or dir)
    else
      table.insert(move_queue, exitmap[dir] or dir)
    end
  elseif configs.search_on_look and dir == configs.lang_dirs['look'] then
    table.insert(move_queue, dir)
  elseif map.currentRoom then
    local special = getSpecialExitsSwap(map.currentRoom) or {}
    if special[dir] then
      if priority then
        table.insert(move_queue, 1, dir)
      else
        table.insert(move_queue, dir)
      end
    end
  end
end

local function deduplicate_exits(exits)
  local deduplicated_exits = {}
  for _, v in ipairs(exits) do
    deduplicated_exits[v] = true
  end
  return table.keys(deduplicated_exits)
end

local function capture_room_info(name, exits)
  -- captures room info, and tries to move map to match
  -- exits = "west、southwest 和 northup"
  if (not vision_fail) and name and exits then
    map.set("prevName", map.currentName)
    map.set("prevExits", map.currentExits)
    name = string.trim(name)
    map.set("currentName", name)
    if exits:ends(".") then
      exits = exits:sub(1, #exits - 1)
    end
    if not map.configs.use_translation then
      exits = string.gsub(string.lower(exits), " 和 ", "、")
    end
    map.set("currentExits", {})
    for w in string.gmatch(exits, "%a+") do
      if map.configs.use_translation then
        local dir = map.configs.translate and map.configs.translate[w]
        if dir then
          table.insert(map.currentExits, dir)
        end
      else
        table.insert(map.currentExits, w)
      end
    end
    undupeExits = deduplicate_exits(map.currentExits)
    -- map.set("currentExits", undupeExits)
    map.set("currentExits", gmcp.Room.Info.exits)
    map.echo(string.format("Exits Captured: %s (%s)", exits, table.concat(map.currentExits, " ")), true)
    move_map()
  elseif vision_fail then
    move_map()
  end
end

local function find_area(name)
  -- searches for the named area, and creates it if necessary
  local areas = getAreaTable()
  local areaID
  for k, v in pairs(areas) do
    if string.lower(name) == string.lower(k) then
      areaID = v
      break
    end
  end
  if not areaID then
    areaID = addAreaName(name)
  end
  if not areaID then
    show_err("Invalid Area. No such area found, and area could not be added.", true)
  end
  map.set("currentArea", areaID)
end

function map.load_map(address)
  local path = profilePath .. "/map downloads/map.dat"
  if not address then
    loadMap(path)
    map.echo("Map reloaded from local copy.")
  else
    if not string.match(address, "/[%a_]+%.dat$") then
      address = address .. "/map.dat"
    end
    downloading = true
    downloadFile(path, address)
    map.echo(string.format("Downloading map file from: %s.", address))
  end
end

function map.set_exit(dir, roomID)
  -- used to set unusual exits from the room you are standing in
  if map.mapping then
    roomID = tonumber(roomID)
    if not roomID then
      show_err("Set Exit: Invalid Room ID")
    end
    if not table.contains(exitmap, dir) and not string.starts(dir, "-p ") then
      show_err("Set Exit: Invalid Direction")
    end
    if not string.starts(dir, "-p ") then
      local exit
      if stubmap[exitmap[dir] or dir] <= 12 then
        exit = short[exitmap[dir] or dir]
        setExit(map.currentRoom, roomID, exit)
      else
        -- check handling of custom exits here
        exit = exitmap[dir] or dir
        exit = "exit " .. exit
        setRoomUserData(map.currentRoom, exit, roomID)
      end
      map.echo("Exit " .. dir .. " now goes to roomID " .. roomID)
    else
      dir = string.gsub(dir, "^-p ", "")
      addSpecialExit(map.currentRoom, roomID, dir)
      map.echo("Special exit '" .. dir .. "' now goes to roomID " .. roomID)
    end
  else
    map.echo("Not mapping", false, true)
  end
end

function map.find_path(roomName, areaName, return_tables)
  areaName = (areaName ~= "" and areaName) or nil
  local rooms = find_room(roomName, areaName)
  local found, dirs = false, {}
  local path = {}
  for k, v in pairs(rooms) do
    found = getPath(map.currentRoom, k)
    if found and (#dirs == 0 or #dirs > #speedWalkDir) then
      dirs = speedWalkDir
      path = speedWalkPath
    end
  end
  if return_tables then
    if table.is_empty(path) then
      path, dirs = nil, nil
    end
    return path, dirs
  else
    if #dirs > 0 then
      map.echo("Path to " .. roomName .. ((areaName and " in " .. areaName) or "") .. ": " .. table.concat(dirs, ", "))
    else
      map.echo("No path found to " .. roomName .. ((areaName and " in " .. areaName) or "") .. ".", false, true)
    end
  end
end

function map.export_area(name)
  -- used to export a single area to a file
  local areas = getAreaTable()
  name = string.lower(name)
  for k, v in pairs(areas) do
    if name == string.lower(k) then
      name = k
    end
  end
  if not areas[name] then
    show_err("No such area.")
  end
  local rooms = getAreaRooms(areas[name])
  local tmp = {}
  for k, v in pairs(rooms) do
    tmp[v] = v
  end
  rooms = tmp
  local tbl = {}
  tbl.name = name
  tbl.rooms = {}
  tbl.exits = {}
  tbl.special = {}
  local rname, exits, stubs, doors, special, portals, door_up, door_down, coords
  for k, v in pairs(rooms) do
    rname = getRoomName(v)
    exits = getRoomExits(v)
    stubs = getExitStubs(v)
    doors = getDoors(v)
    special = getSpecialExitsSwap(v)
    portals = getRoomUserData(v, "portals") or ""
    coords = {getRoomCoordinates(v)}
    tbl.rooms[v] =
      {
        name = rname,
        coords = coords,
        exits = exits,
        stubs = stubs,
        doors = doors,
        door_up = door_up,
        door_down = door_down,
        door_in = door_in,
        door_out = door_out,
        special = special,
        portals = portals,
      }
    tmp = {}
    for k1, v1 in pairs(exits) do
      if not table.contains(rooms, v1) then
        tmp[k1] = {v1, getRoomName(v1)}
      end
    end
    if not table.is_empty(tmp) then
      tbl.exits[v] = tmp
    end
    tmp = {}
    for k1, v1 in pairs(special) do
      if not table.contains(rooms, v1) then
        tmp[k1] = {v1, getRoomName(v1)}
      end
    end
    if not table.is_empty(tmp) then
      tbl.special[v] = tmp
    end
  end
  local path = profilePath .. "/" .. string.gsub(string.lower(name), "%s", "_") .. ".dat"
  table.save(path, tbl)
  map.echo("Area " .. name .. " exported to " .. path)
end

function map.import_area(name)
  name = profilePath .. "/" .. string.gsub(string.lower(name), "%s", "_") .. ".dat"
  local tbl = {}
  table.load(name, tbl)
  if table.is_empty(tbl) then
    show_err("No file found")
  end
  local areas = getAreaTable()
  local areaID = areas[tbl.name] or addAreaName(tbl.name)
  local rooms = {}
  local ID
  for k, v in pairs(tbl.rooms) do
    ID = createRoomID()
    rooms[k] = ID
    addRoom(ID)
    setRoomName(ID, v.name)
    setRoomArea(ID, areaID)
    setRoomCoordinates(ID, unpack(v.coords))
    if type(v.stubs) == "table" then
      for i, j in pairs(v.stubs) do
        setExitStub(ID, j, true)
      end
    end
    for i, j in pairs(v.doors) do
      setDoor(ID, i, j)
    end
    setRoomUserData(ID, "portals", v.portals)
  end
  for k, v in pairs(tbl.rooms) do
    for i, j in pairs(v.exits) do
      if rooms[j] then
        connect_rooms(rooms[k], rooms[j], i)
      end
    end
    for i, j in pairs(v.special) do
      if rooms[j] then
        addSpecialExit(rooms[k], rooms[j], i)
      end
    end
  end
  for k, v in pairs(tbl.exits) do
    for i, j in pairs(v) do
      if getRoomName(j[1]) == j[2] then
        connect_rooms(rooms[k], j[1], i)
      end
    end
  end
  for k, v in pairs(tbl.special) do
    for i, j in pairs(v) do
      addSpecialExit(k, j[1], i)
    end
  end
  map.fix_portals()
  map.echo("Area " .. tbl.name .. " imported from " .. name)
end

function map.set_recall()
  -- assigned the current room to be recall for the current character
  map.save.recall[map.character] = map.currentRoom
  table.save(profilePath .. "/map downloads/map_save.dat", map.save)
  map.echo("Recall room set to: " .. getRoomName(map.currentRoom) .. ".")
end

function map.set_portal(name, is_auto)
  -- creates a new portal in the room
  if map.mapping then
    if not string.starts(name, "-f ") then
      find_portal = name
    else
      name = string.gsub(name, "^-f ", "")
      force_portal = name
    end
    move_queue = {name}
    if not is_auto then
      send(name)
    end
  else
    map.echo("Not mapping", false, true)
  end
end

function map.set_mode(mode)
  -- switches mapping modes
  if not table.contains({"lazy", "simple", "normal", "complex"}, mode) then
    show_err("Invalid Map Mode, must be 'lazy', 'simple', 'normal' or 'complex'.")
  end
  map.set("mode", mode)
  map.echo("Current mode set to: " .. mode)
end

function map.start_mapping(area_name)
  -- starts mapping, and sets the current area to the given one, or uses the current one
  if not map.currentName then
    show_err("Room detection not yet working, see <yellow>map basics<reset> for guidance.")
  end
  local rooms
  move_queue = {}
  area_name = area_name ~= "" and area_name or nil
  if map.currentArea and not area_name then
    local areas = getAreaTableSwap()
    area_name = areas[map.currentArea]
  end
  if not area_name then
    show_err("You haven't started mapping yet, how should the first area be called? Set it with: <yellow>start mapping <area name><reset>")
  end
  map.echo("Now mapping in area: " .. area_name)
  map.set("mapping", true)
  find_area(area_name)
  rooms = find_room(map.currentName, map.currentArea)
  if table.is_empty(rooms) then
    if map.currentRoom and getRoomName(map.currentRoom) == map.currentName then
      map.set_area(area_name)
    else
      map.echo([[---[start_mapping]create room---]])
      create_room(map.currentName, map.currentExits, nil, {0, 0, 0})
    end
  elseif map.currentRoom and map.currentArea ~= getRoomArea(map.currentRoom) then
    map.set_area(area_name)
  end
end

function map.stop_mapping()
  map.set("mapping", false)
  map.echo("Mapping off.")
end

function map.clear_moves()
  local commands_in_queue = #move_queue
  move_queue = {}
  map.echo("Move queue cleared, " .. commands_in_queue .. " commands removed.")
end

function map.show_moves()
  map.echo("Moves: " .. (move_queue and table.concat(move_queue, ', ') or '(queue empty)'))
end

function map.set_area(name)
  -- assigns the current room to the area given, creates the area if necessary
  if map.mapping then
    find_area(name)
    if map.currentRoom and getRoomArea(map.currentRoom) ~= map.currentArea then
      setRoomArea(map.currentRoom, map.currentArea)
      set_room(map.currentRoom)
    end
  else
    map.echo("Not mapping", false, true)
  end
end

function map.set_door(dir, status, one_way)
  -- adds a door on a given exit
  if map.mapping then
    if not map.currentRoom then
      show_err("Make Door: No room found.")
    end
    dir = exitmap[dir] or dir
    if not stubmap[dir] then
      show_err("Make Door: Invalid direction.")
    end
    status = (status ~= "" and status) or "closed"
    one_way = (one_way ~= "" and one_way) or "no"
    if not table.contains({"yes", "no"}, one_way) then
      show_err("Make Door: Invalid one-way status, must be yes or no.")
    end
    local exits = getRoomExits(map.currentRoom)
    local exit
    -- check handling of custom exits here
    for i = 13, #stubmap do
      exit = "exit " .. stubmap[i]
      exits[stubmap[i]] = tonumber(getRoomUserData(map.currentRoom, exit))
    end
    local target_room = exits[dir]
    if target_room then
      exits = getRoomExits(target_room)
      -- check handling of custom exits here
      for i = 13, #stubmap do
        exit = "exit " .. stubmap[i]
        exits[stubmap[i]] = tonumber(getRoomUserData(target_room, exit))
      end
    end
    if one_way == "no" and (target_room and exits[reverse_dirs[dir]] == map.currentRoom) then
      add_door(target_room, reverse_dirs[dir], status)
    end
    add_door(map.currentRoom, dir, status)
    map.echo(string.format("Adding %s door to the %s", status, dir))
  else
    map.echo("Not mapping", false, true)
  end
end

function map.shift_room(dir)
  -- shifts a room around on the map
  if map.mapping then
    dir = exitmap[dir] or (table.contains(exitmap, dir) and dir)
    if not dir then
      show_err("Shift Room: Exit not found")
    end
    local x, y, z = getRoomCoordinates(map.currentRoom)
    dir = stubmap[dir]
    local coords = coordmap[dir]
    x = x + coords[1]
    y = y + coords[2]
    z = z + coords[3]
    setRoomCoordinates(map.currentRoom, x, y, z)
    centerview(map.currentRoom)
    map.echo("Shifting room", true)
  else
    map.echo("Not mapping", false, true)
  end
end

local function check_link(firstID, secondID, dir)
  -- check to see if two rooms are connected in a given direction
  if not firstID then
    error("Check Link Error: No first ID", 2)
  end
  if not secondID then
    error("Check Link Error: No second ID", 2)
  end
  local name = getRoomName(firstID)
  local exits1 = table.union(getRoomExits(firstID), getRoomStubs(firstID))
  local exits2 = table.union(getRoomExits(secondID), getRoomStubs(secondID))
  local exit
  -- check handling of custom exits here
  for i = 13, #stubmap do
    exit = "exit " .. stubmap[i]
    exits1[stubmap[i]] = tonumber(getRoomUserData(firstID, exit))
    exits2[stubmap[i]] = tonumber(getRoomUserData(secondID, exit))
  end
  local checkID = exits2[reverse_dirs[dir]]
  local exits = {}
  for k, v in pairs(exits1) do
    table.insert(exits, k)
  end
  return checkID and check_room(checkID, name, exits)
end

function map.find_me(name, exits, dir, manual)
  -- tries to locate the player using the current room name and exits, and if provided, direction of movement
  -- if direction of movement is given, narrows down possibilities using previous room info
  if move ~= "recall" then
    move_queue = {}
  end
  -- display([[map.find_me]])
  -- 直接根据hash查找
  local room = getRoomIDbyHash(gmcp.Room.Info.hash)
  if room > 0 then
    set_room(room)
    map.echo("Room found, ID: " .. room, true)
    return
  else
    map.echo("Room not found in map database", false, true)
    return
  end
  -- todo 清理以下代码
  local check = dir and map.currentRoom and table.contains(exitmap, dir)
  name = name or map.currentName
  exits = exits or map.currentExits
  if not name and not exits then
    show_err("Room not found, complete room name and exit data not available.")
  end
  local rooms = find_room(name)
  local match_IDs = {}
  for k, v in pairs(rooms) do
    if check_room(k, name, exits) then
      table.insert(match_IDs, k)
    end
  end
  rooms = match_IDs
  match_IDs = {}
  if table.size(rooms) > 1 and check then
    for k, v in pairs(rooms) do
      if check_link(map.currentRoom, v, dir) then
        table.insert(match_IDs, v)
      end
    end
  elseif random_move then
    for k, v in pairs(getRoomExits(map.currentRoom)) do
      if check_room(v, map.currentName, map.currentExits) then
        table.insert(match_IDs, v)
      end
    end
  end
  if table.size(match_IDs) == 0 then
    match_IDs = rooms
  end
  if table.index_of(match_IDs, map.currentRoom) then
    match_IDs = {map.currentRoom}
  end
  if not table.is_empty(match_IDs) and not find_portal then
    set_room(match_IDs[1])
    map.echo("Room found, ID: " .. match_IDs[1], true)
  elseif find_portal then
    if not table.is_empty(match_IDs) then
      map.echo("Found portal destination, linking rooms", false, false, true)
      addSpecialExit(map.currentRoom, match_IDs[1], find_portal)
      local portals = getRoomUserData(match_IDs[1], "portals") or ""
      portals = portals .. "," .. tostring(map.currentRoom) .. ":" .. find_portal
      setRoomUserData(match_IDs[1], "portals", portals)
      set_room(match_IDs[1])
      map.echo("Room found, ID: " .. match_IDs[1], true)
    else
      map.echo("Creating portal destination", false, false, true)
      map.echo([[---[find_me]create room---]])
      create_room(map.currentName, map.currentExits, nil, {getRoomCoordinates(map.currentRoom)})
    end
    find_portal = false
  elseif table.is_empty(match_IDs) then
    if not manual then
      map.echo("Room not found in map database!", true, true)
    else
      map.echo("Room not found in map database", false, true)
    end
  end
end

function map.fix_portals()
  if map.mapping then
    -- used to clear and update data for portal back-referencing
    local rooms = getRooms()
    local portals
    for k, v in pairs(rooms) do
      setRoomUserData(k, "portals", "")
    end
    for k, v in pairs(rooms) do
      for cmd, room in pairs(getSpecialExitsSwap(k)) do
        portals = getRoomUserData(room, "portals") or ""
        if portals ~= "" then
          portals = portals .. ","
        end
        portals = portals .. tostring(k) .. ":" .. cmd
        setRoomUserData(room, "portals", portals)
      end
    end
    map.echo("Portals Fixed")
  else
    map.echo("Not mapping", false, true)
  end
end

function map.merge_rooms()
  -- used to combine essentially identical rooms with the same coordinates
  -- typically, these are generated due to mapping errors
  if map.mapping then
    map.echo("Merging rooms")
    local x, y, z = getRoomCoordinates(map.currentRoom)
    local rooms = getRoomsByPosition(map.currentArea, x, y, z)
    local exits, portals, room, cmd, curportals
    local room_count = 1
    for k, v in pairs(rooms) do
      if v ~= map.currentRoom then
        if getRoomName(v) == getRoomName(map.currentRoom) then
          room_count = room_count + 1
          for k1, v1 in pairs(getRoomExits(v)) do
            setExit(map.currentRoom, v1, stubmap[k1])
            exits = getRoomExits(v1)
            if exits[reverse_dirs[k1]] == v then
              setExit(v1, map.currentRoom, stubmap[reverse_dirs[k1]])
            end
          end
          for k1, v1 in pairs(getDoors(v)) do
            setDoor(map.currentRoom, k1, v1)
          end
          for k1, v1 in pairs(getSpecialExitsSwap(v)) do
            addSpecialExit(map.currentRoom, v1, k1)
          end
          portals = getRoomUserData(v, "portals") or ""
          if portals ~= "" then
            portals = string.split(portals, ",")
            for k1, v1 in ipairs(portals) do
              room, cmd = unpack(string.split(v1, ":"))
              addSpecialExit(tonumber(room), map.currentRoom, cmd)
              curportals = getRoomUserData(map.currentRoom, "portals") or ""
              if not string.find(curportals, room) then
                curportals = curportals .. "," .. room .. ":" .. cmd
                setRoomUserData(map.currentRoom, "portals", curportals)
              end
            end
          end
          -- check handling of custom exits here for doors and exits, and reverse exits
          for i = 13, #stubmap do
            local door = "door " .. stubmap[i]
            local tmp = tonumber(getRoomUserData(v, door))
            if tmp then
              setRoomUserData(map.currentRoom, door, tmp)
            end
            local exit = "exit " .. stubmap[i]
            tmp = tonumber(getRoomUserData(v, exit))
            if tmp then
              setRoomUserData(map.currentRoom, exit, tmp)
              if tonumber(getRoomUserData(tmp, "exit " .. reverse_dirs[stubmap[i]])) == v then
                setRoomUserData(tmp, exit, map.currentRoom)
              end
            end
          end
          deleteRoom(v)
        end
      end
    end
    if room_count > 1 then
      map.echo(room_count .. " rooms merged", true)
    end
  else
    map.echo("Not mapping", false, true)
  end
end

function map.findAreaID(areaname, exact)
  local areaname = areaname:lower()
  local list = getAreaTable()
  -- iterate over the list of areas, matching them with substring match.
  -- if we get match a single area, then return its ID, otherwise return
  -- 'false' and a message that there are than one are matches
  local returnid, fullareaname, multipleareas = nil, nil, {}
  for area, id in pairs(list) do
    if (not exact and area:lower():find(areaname, 1, true)) or (exact and areaname == area:lower()) then
      returnid = id
      fullareaname = area
      multipleareas[#multipleareas + 1] = area
    end
  end
  if #multipleareas == 1 then
    return returnid, fullareaname
  else
    return nil, nil, multipleareas
  end
end

function map.echoRoomList(areaname, exact)
  local areaid, msg, multiples
  local listcolor, othercolor = "DarkSlateGrey", "LightSlateGray"
  if tonumber(areaname) then
    areaid = tonumber(areaname)
    msg = getAreaTableSwap()[areaid]
  else
    areaid, msg, multiples = map.findAreaID(areaname, exact)
  end
  if areaid then
    local roomlist, endresult = getAreaRooms(areaid) or {}, {}
    -- obtain a room list for each of the room IDs we got
    local getRoomName = getRoomName
    for _, id in pairs(roomlist) do
      endresult[id] = getRoomName(id)
    end
    roomlist[#roomlist + 1], roomlist[0] = roomlist[0], nil
    -- sort room IDs so we can display them in order
    table.sort(roomlist)
    local echoLink, format, fg, echo = echoLink, string.format, fg, cecho
    -- now display something half-decent looking
    cecho(
      format(
        "<%s>List of all rooms in <%s>%s<%s> (areaID <%s>%s<%s> - <%s>%d<%s> rooms):\n",
        listcolor, othercolor, msg, listcolor,  othercolor, areaid, listcolor,  othercolor, #roomlist, listcolor
      )
    )
    -- use pairs, as we can have gaps between room IDs
    for _, roomid in pairs(roomlist) do
      local roomname = endresult[roomid]
      cechoLink(format("<%s>%7s", othercolor, roomid),
                'map.speedwalk(' .. roomid .. ')',
                format("Go to %s (%s)", roomid, tostring(roomname)),
                true)
      cecho(format("<%s>: <%s>%s<%s>.\n", listcolor, othercolor, roomname, listcolor))
    end
  elseif not areaid and #multiples > 0 then
    local allareas, format = getAreaTable(), string.format

    local function countrooms(areaname)
      local areaid = allareas[areaname]
      local allrooms = getAreaRooms(areaid) or {}
      local areac = (#allrooms or 0) + (allrooms[0] and 1 or 0)
      return areac
    end

    map.echo("For which area would you want to list rooms for?")
    for _, areaname in ipairs(multiples) do
      echo("  ")
      setUnderline(true)
      cechoLink(format("<%s>%-40s (%d rooms)", othercolor, areaname, countrooms(areaname)),
                'map.echoRoomList("' .. areaname .. '", true)',
                "Click to view the room list for " .. areaname, true)
      setUnderline(false)
      echo("\n")
    end
  else
    map.echo(string.format("Don't know of any area named '%s'.", areaname), false, true)
  end
  resetFormat()
end

function map.echoAreaList()
  local totalroomcount = 0
  local rlist = getAreaTableSwap()
  local listcolor, othercolor = "DarkSlateGrey", "LightSlateGray"
  -- count the amount of rooms in an area, taking care to count the room in the 0th
  -- index as well if there is one
  -- saves the total room count on the side as well

  local function countrooms(areaid)
    local allrooms = getAreaRooms(areaid) or {}
    local areac = (#allrooms or 0) + (allrooms[0] and 1 or 0)
    totalroomcount = totalroomcount + areac
    return areac
  end

  local getAreaRooms, cecho, fg, echoLink, format = getAreaRooms, cecho, fg, echoLink, string.format
  cecho(format("<%s>List of all areas we know of (click to view room list):\n", listcolor))
  for id = 1, table.maxn(rlist) do
    if rlist[id] then
      cecho(format("<%s>%7d ", othercolor, id))
      fg(listcolor)
      echoLink(format("%-40s (%d rooms)", rlist[id], countrooms(id)), 'map.echoRoomList("' .. id .. '", true)', "View the room list for " .. rlist[id], true)
      echo("\n")
    end
  end
  cecho(string.format("<%s>Total amount of rooms in this map: %s\n", listcolor, totalroomcount))
end

function map.search_timer_check()
  if find_prompt then
    map.echo("Prompt not auto-detected, use 'map prompt' to set a prompt pattern.", false, true)
    find_prompt = false
  end
end

function map.find_prompt()
  find_prompt = true
  map.echo("Searching for prompt.")
  send("\n", false)
  tempTimer(5, "map.search_timer_check()")
end

function map.make_prompt_pattern(str)
  if not str:starts("^") then
    str = "^" .. str
  end
  map.save.prompt_pattern[map.character] = str
  find_prompt = false
  table.save(profilePath .. "/map downloads/map_save.dat", map.save)
  map.echo("Prompt pattern set: " .. str)
end

function map.make_ignore_pattern(str)
  map.save.ignore_patterns = map.save.ignore_patterns or {}
  if not table.contains(map.save.ignore_patterns, str) then
    table.insert(map.save.ignore_patterns, str)
    map.echo("Ignore pattern added: " .. str)
  else
    table.remove(map.save.ignore_patterns, table.index_of(map.save.ignore_patterns, str))
    map.echo("Ignore pattern removed: " .. str)
  end
  table.save(profilePath .. "/map downloads/map_save.dat", map.save)
end

local function grab_line()
  table.insert(lines, line)
  if
    map.save.prompt_pattern[map.character] and
    string.match(line, map.save.prompt_pattern[map.character])
  then
    if map.prompt.exits and map.prompt.exits ~= "" then
      raiseEvent("onNewRoom")
    end
    print_wait_echoes()
    map.echo("Prompt captured", true)
  end
  if find_prompt then
    for k, v in ipairs(map.configs.prompt_test_patterns) do
      if string.match(line, v) then
        map.save.prompt_pattern[map.character] = v
        table.save(profilePath .. "/map downloads/map_save.dat", map.save)
        find_prompt = false
        map.echo("Prompt found")
        break
      end
    end
  end
end

local function name_search()
  return gmcp.Room.Info.name
end

local function handle_exits(exits)
  local room = map.prompt.room or name_search()
  -- room = map.sanitizeRoomName(room)
  exits = map.prompt.exits or exits
  exits = string.lower(exits)
  exits = string.gsub(exits, "%a+", exitmap)
  if room then
    map.echo("Room Name Captured: " .. room, true)
    room = string.trim(room)
    capture_room_info(room, exits)
    map.prompt.room = nil
    map.prompt.exits = nil
  end
end

local continue_walk, timerID
continue_walk = function(new_room)
  if not walking then return end
  -- calculate wait time until next command, with randomness
  local wait = map.configs.speedwalk_delay or 0
  if wait > 0 and map.configs.speedwalk_random then
    wait = wait * (1 + math.random(0, 100) / 100)
  end
  -- if no wait after new room, move immediately
  if new_room and map.configs.speedwalk_wait and wait == 0 then
    new_room = false
  end
  -- send command if we don't need to wait
  if not new_room then
    send(table.remove(map.walkDirs, 1))
    -- check to see if we are done
    if #map.walkDirs == 0 then
      walking = false
    end
  end
  -- make tempTimer to send next command if necessary
  if walking and (not map.configs.speedwalk_wait or (map.configs.speedwalk_wait and wait > 0)) then
    if timerID then
      killTimer(timerID)
    end
    timerID = tempTimer(wait, function() continue_walk() end)
  end
end

function map.pauseSpeedwalk()
  map.echo("pauseSpeedwalk!")
  walking = false
end

function map.resumeSpeedwalk()
  map.echo("resumeSpeedwalk!")
  walking = true
end

function map.speedwalk(roomID, walkPath, walkDirs)
  roomID = roomID or speedWalkPath[#speedWalkPath]
  getPath(map.currentRoom, roomID)
  walkPath = speedWalkPath
  walkDirs = speedWalkDir
  if #speedWalkPath == 0 then
    map.echo("No path to chosen room found.", false, true)
    return
  end
  table.insert(walkPath, 1, map.currentRoom)
  -- go through dirs to find doors that need opened, etc
  -- add in necessary extra commands to walkDirs table
  local k = 1
  repeat
    local id, dir = walkPath[k], walkDirs[k]
    if exitmap[dir] or short[dir] then
      local door = check_doors(id, exitmap[dir] or dir)
      local status = door and door[dir]
      if status and status > 1 then
        -- if locked, unlock door
        if status == 3 then
          table.insert(walkPath, k, id)
          table.insert(walkDirs, k, "unlock " .. (exitmap[dir] or dir))
          k = k + 1
        end
        -- if closed, open door
        table.insert(walkPath, k, id)
        table.insert(walkDirs, k, "open " .. (exitmap[dir] or dir))
        k = k + 1
      end
    end
    k = k + 1
  until k > #walkDirs
  if map.configs.use_translation then
    for k, v in ipairs(walkDirs) do
      walkDirs[k] = map.configs.lang_dirs[v] or v
    end
  end
  -- perform walk
  walking = true
  if map.configs.speedwalk_wait or map.configs.speedwalk_delay > 0 then
    map.walkDirs = walkDirs
    continue_walk()
  else
    for _, dir in ipairs(walkDirs) do
      send(dir)
    end
    walking = false
  end
end

function doSpeedWalk()
  if #speedWalkPath ~= 0 then
    map.speedwalk(nil, speedWalkPath, speedWalkDir)
  else
    map.echo("No path to chosen room found.", false, true)
  end
end

local function check_version()
  downloading = false
  local path = profilePath .. "/map downloads/versions.lua"
  local versions = {}
  table.load(path, versions)
  local pos = table.index_of(versions, map.version) or 0
  if pos ~= #versions then
    enableAlias("Map Update Alias")
    map.echo(string.format("The Generic Mapping Script is currently <red>%d<reset> versions behind.", #versions - pos))
    map.echo("To update now, please type: <yellow>map update<reset>")
  end
  map.update_timer = tempTimer(3600, [[map.checkVersion()]])
end

function map.checkVersion()
  if map.update_timer then
    killTimer(map.update_timer)
    map.update_timer = nil
  end
  if not map.update_waiting and map.configs.download_path ~= "" then
    local path, file = profilePath .. "/map downloads", "/versions.lua"
    downloading = true
    downloadFile(path .. file, map.configs.download_path .. file)
    map.update_waiting = true
  end
end

local function update_version()
  downloading = false
  local path = profilePath .. "/map downloads/generic_mapper.xml"
  disableAlias("Map Update Alias")
  map.updatingMapper = true
  uninstallPackage("generic_mapper")
  installPackage(path)
  map.updatingMapper = nil
  map.echo("Generic Mapping Script updated successfully.")
end

function map.updateVersion()
  local path, file = profilePath .. "/map downloads", "/generic_mapper.xml"
  downloading = true
  downloadFile(path .. file, map.configs.download_path .. file)
end

function map.showMap(shown)
  local configs = map.configs.map_window
  shown = shown or not configs.shown
  map.configs.map_window.shown = shown
  local x, y, w, h, origin = configs.x, configs.y, configs.w, configs.h, configs.origin
  if string.find(origin, "bottom") then
    if y == 0 or y == "0%" then
      y = h
    end
    if type(y) == "number" then
      y = -y
    else
      y = "-" .. y
    end
  end
  if string.find(origin, "right") then
    if x == 0 or x == "0%" then
      x = w
    end
    if type(x) == "number" then
      x = -x
    else
      x = "-" .. x
    end
  end
  local mapper = Geyser.Mapper:new({name = "my_mapper", x = x, y = y, w = w, h = h})
  mapper:resize(w, h)
  mapper:move(x, y)
  if shown then
    mapper:show()
  else
    mapper:hide()
  end
end

-- some games embed an ASCII map on the same line, which messes up the room room name
-- extract the longest continuous piece of text from the line to be the room name

function map.sanitizeRoomName(roomtitle)
  assert(type(roomtitle) == "string", "map.sanitizeRoomName: bad argument #1 expected room title, got " .. type(roomtitle) .. "!")
  if not roomtitle:match("  ") then
    return roomtitle
  end
  local parts = roomtitle:split("  ")
  table.sort(
    parts,
    function(a, b)
      return #a < #b
    end
  )
  local longestpart = parts[#parts]
  local trimmed = utf8.match(longestpart, "[%w ]+"):trim()
  return trimmed
end

function map.eventHandler(event, ...)
  if event == "onNewRoom" then
    handle_exits(arg[1])
    --"north、east、west 和 southup"
    if walking and map.configs.speedwalk_wait then
      continue_walk(true)
    end
  elseif event == "onPrompt" then
    if map.prompt.exits and map.prompt.exits ~= "" then
      raiseEvent("onNewRoom")
    end
    print_wait_echoes()
    map.echo("Prompt Captured", true)
  elseif event == "onMoveFail" then
    map.echo("onMoveFail", true)
    table.remove(move_queue, 1)
  elseif event == "onVisionFail" then
    map.echo("onVisionFail", true)
    vision_fail = true
    capture_room_info()
  elseif event == "onRandomMove" then
    map.echo("onRandomMove", true)
    random_move = true
    move_queue = {}
  elseif event == "onForcedMove" then
    map.echo("onForcedMove", true)
    capture_move_cmd(arg[1], arg[2] == "true")
  elseif event == "onNewLine" then
    grab_line()
  elseif event == "sysDataSendRequest" then
    capture_move_cmd(arg[1])
    -- check to prevent multiple version checks in a row without user intervention
    if map.update_waiting and map.update_timer then
      map.update_waiting = nil
      -- check to ensure version check cycle is started
    elseif not map.update_waiting and not map.update_timer then
      map.checkVersion()
    end
  elseif event == "sysDownloadDone" and downloading then
    local file = arg[1]
    if string.ends(file, "/map.dat") then
      loadMap(file)
      downloading = false
      map.echo("Map File Loaded.")
    elseif string.ends(file, "/versions.lua") then
      check_version()
    elseif string.ends(file, "/generic_mapper.xml") then
      update_version()
    end
  elseif event == "sysLoadEvent" or event == "sysInstall" then
    config()
  elseif event == "mapOpenEvent" then
    if not help_shown and not map.save.prompt_pattern[map.character or ""] then
      map.find_prompt()
      send(map.configs.lang_dirs['look'], true)
      tempTimer(3, function() map.show_help("quick_start"); help_shown = true end)
    end
  elseif event == "mapStop" then
    map.set("mapping", false)
    walking = false
    map.echo("Mapping and speedwalking stopped.")
  elseif event == "sysManualLocationSetEvent" then
    set_room(arg[1])
  elseif
    event == "sysUninstallPackage" and not map.updatingMapper and arg[1] == "generic_mapper"
  then
    for _, id in ipairs(map.registeredEvents) do
      killAnonymousEventHandler(id)
    end
  end
end

map.registeredEvents =
  {
    registerAnonymousEventHandler("sysDownloadDone", "map.eventHandler"),
    registerAnonymousEventHandler("sysLoadEvent", "map.eventHandler"),
    registerAnonymousEventHandler("sysConnectionEvent", "map.eventHandler"),
    registerAnonymousEventHandler("sysInstall", "map.eventHandler"),
    registerAnonymousEventHandler("sysDataSendRequest", "map.eventHandler"),
    registerAnonymousEventHandler("onMoveFail", "map.eventHandler"),
    registerAnonymousEventHandler("onVisionFail", "map.eventHandler"),
    registerAnonymousEventHandler("onRandomMove", "map.eventHandler"),
    registerAnonymousEventHandler("onForcedMove", "map.eventHandler"),
    registerAnonymousEventHandler("onNewRoom", "map.eventHandler"),
    registerAnonymousEventHandler("onNewLine", "map.eventHandler"),
    registerAnonymousEventHandler("mapOpenEvent", "map.eventHandler"),
    registerAnonymousEventHandler("mapStop", "map.eventHandler"),
    registerAnonymousEventHandler("onPrompt", "map.eventHandler"),
    registerAnonymousEventHandler("sysManualLocationSetEvent", "map.eventHandler"),
    registerAnonymousEventHandler("sysUninstallPackage", "map.eventHandler"),
  }
