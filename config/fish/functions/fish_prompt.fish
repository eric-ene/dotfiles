function color_str -a inp_str col
    printf $(set_color $col)$inp_str$(set_color normal)
end

function git_info --description 'get git inof'
    set -l git_present $(git status 2> /dev/null > /dev/null; and echo 1; or echo 0)

    if test $git_present -eq 0
        return
    end

    set -l branch $(git rev-parse --abbrev-ref HEAD)

    set -l dirty $(git diff-index HEAD | wc -l)

    if test $dirty -eq 0
        set dirty ""
    else
        set dirty " $dirty"
    end

    printf " [$(color_str $branch green)$(color_str $dirty red)]"
end

function fish_prompt --description 'Write out the prompt'
    set -l dir $(dirs)
    printf "$(color_str $dir red)$(git_info)\n"
    printf "\$ "
end

function fish_right_prompt --description 'Right side prompt'
    set -l laststatus $status
    if test $laststatus -ne 0
        printf $$laststatus$()
    end
end
