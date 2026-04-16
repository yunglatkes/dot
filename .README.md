# Commands for Setting up Repo
## Initialization
```
git clone --bare https://github.com/yunglatkes/dotfiles.git $HOME/.dotfiles && source ~/.bashrc 
```


## Fresh Installation
```
# Notice the --bare flag; this initializes the repository as a git bare
git init --bare $HOME/.dotfiles

echo 'alias dot="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"' > .bashrc
```
Don't display untracked files in git status
```
dot config --local status.showUntrackedFiles no
```

[Guide](https://web.archive.org/web/20240307132655/https://engineeringwith.kalkayan.com/series/developer-experience/storing-dotfiles-with-git-this-is-the-way/)
