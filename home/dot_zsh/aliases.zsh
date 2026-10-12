# Zsh
alias zshconfig='nvim ~/.zshrc'
alias ohmyzsh='xdg-open ~/.oh-my-zsh'
alias suroot='sudo -E -s'

# Files
alias ls='eza -a --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first'
alias tree='eza --tree'
alias bat='bat -p'
alias cat='bat -p'
alias open='xdg-open'
alias exegol='sudo -E "$HOME/.local/bin/exegol"'

# Git
alias gs='git status --short --branch'
alias gd='git diff'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset)%C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gcheck='git checkout'
alias gpush='git push'
alias gc='git clone'
alias gpull='git pull'
alias gshove='git push --force-with-lease --force-if-includes'

# Docker
alias up='docker compose up'
alias run='docker compose run'
alias down='docker compose down'
alias build='docker build'
alias buildx='docker buildx'
alias dockerusage='docker system df'
alias lzd='lazydocker'
alias dockerprune='docker system prune -a'

# yt-dlp
alias yta-aac="yt-dlp --extract-audio --audio-format aac"
alias yta-best="yt-dlp --extract-audio --audio-format best"
alias yta-flac="yt-dlp --extract-audio --audio-format flac"
alias yta-mp3="yt-dlp --extract-audio --audio-format mp3"
alias ytv-best="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4"

# Packages and system maintenance
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias pathpkg='yay -Ql'
alias sysfailed='systemctl list-units --failed'
alias uu='yay -Syyu'
alias pacman='pacman --color auto'
alias lpacman='bat /var/log/pacman.log'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# Interactive commands
alias cp='cp -i'
alias mv='mv -i'
alias lzg='lazygit'
alias mkdir='mkdir -v'
alias v='nvim'
alias df='df -h'
alias free='free -mt'
alias psa='ps auxf'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'

# Editors for system configuration
alias epacman='sudo $EDITOR /etc/pacman.conf'
alias egrub='sudo $EDITOR /etc/default/grub'
alias emkinitcpio='sudo $EDITOR /etc/mkinitcpio.conf'
alias nfstab='sudo $EDITOR /etc/fstab'
alias nhostname='sudo $EDITOR /etc/hostname'
alias eb='$EDITOR ~/.bashrc'
alias ez='$EDITOR ~/.zshrc'

# Clipboard and diagnostics
alias audio="pactl info | grep 'Server Name'"
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias userlist='cut -d: -f1 /etc/passwd | sort'
alias jctl='journalctl -p 3 -xb'
alias myip='curl http://ipecho.net/plain; echo'
alias usage='du -h -d1'
alias usage1='du -h -d1 | grep -v "/$" | sort -hr'
alias runport='sudo lsof -i'
alias runport1='sudo lsof -i -P -n | grep'
alias runpid='sudo lsof -p'
alias dirs='dirs -v | head -10'
alias hs='history -i | grep -i'
alias history='history -i'

# Colorized output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Open files by extension
alias -s json=bat
alias -s md=bat
alias -s go='$EDITOR'
alias -s rs='$EDITOR'
alias -s txt=bat
alias -s log=bat
alias -s py='$EDITOR'
alias -s js='$EDITOR'
alias -s ts='$EDITOR'
alias -s html=xdg-open
