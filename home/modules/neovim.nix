{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      syntax on

      "Setting"
      set encoding=UTF-8
      set nobackup
      set noswapfile
      set autoread
      set hidden
      set showcmd
      set scrolloff=10
      set display=lastline

      "Style"
      set number
      set virtualedit=onemore
      set smartindent
      set showmatch
      set matchtime=1
      set laststatus=2

      "Tab"
      set tabstop=4
      set softtabstop=4
      set shiftwidth=4
      set expandtab

      "Search"
      set ignorecase
      set smartcase
      set incsearch
      set wrapscan
      set hlsearch

      let s:local_init = expand('$XDG_CONFIG_HOME') . '/local/nvim/init.vim'
      if empty(expand('$XDG_CONFIG_HOME'))
        let s:local_init = expand('~/.config/local/nvim/init.vim')
      endif
      if filereadable(s:local_init)
        execute 'source' fnameescape(s:local_init)
      endif
    '';
  };
}
