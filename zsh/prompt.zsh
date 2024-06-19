#############################################################################
# ZSH prompt
#############################################################################
# When a partial line is preserved, by default you will see an inverse+bold
# character at the end of the partial line: a ‘%’ for a normal user or a ‘#’
# for root. If set, the shell parameter PROMPT_EOL_MARK can be used to
# customize how the end of partial lines are shown.
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Prompting

setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=""