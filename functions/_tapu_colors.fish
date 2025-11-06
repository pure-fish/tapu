#!/usr/bin/env fish
# Color helper functions for tapu

function _color_green
    set_color green; echo -n $argv; set_color normal
end

function _color_red
    set_color red; echo -n $argv; set_color normal
end

function _color_blue
    set_color blue; echo -n $argv; set_color normal
end

function _color_yellow
    set_color yellow; echo -n $argv; set_color normal
end

function _color_magenta
    set_color magenta; echo -n $argv; set_color normal
end

function _color_dim
    set_color brblack; echo -n $argv; set_color normal
end

function _color_white
    set_color white; echo -n $argv; set_color normal
end

function _highlight_green
    set_color black --background green; echo -n $argv; set_color normal
end

function _highlight_red
    set_color black --background red; echo -n $argv; set_color normal
end
