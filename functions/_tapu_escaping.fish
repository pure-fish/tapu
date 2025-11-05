#!/usr/bin/env fish
# TAP escaping handler - processes TAP input through tapu reporter

set --local project_root (dirname (dirname (realpath (status filename))))
source $project_root/functions/tapu.fish
