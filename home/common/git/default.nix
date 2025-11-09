{
  self,
  config,
  pkgs,
  ...
}:
let
  gitAliases = {
    ul = "!git add flake.lock && git commit -m 'update lockfile' && git push";
    sync = "!git pull --rebase && git push";
    ovp = "!git commit --all --allow-empty-message -m '' && git sync";
    lg = "lg1";
    lg1 = "lg1-specific --all -n 20";
    lg2 = "lg2-specific --all";
    lg3 = "lg3-specific --all";

    lg1-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
    lg2-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
    lg3-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";
  };
in
{
  #home.file."${config.xdg.configHome}/git" = {
  #source = ./ignore;
  #};

  home.shellAliases = {
    g = "git";
    gs = "git status";
    gsw = "git switch";
    gsh = "git show";
    grs = "git restore";
    gd = "git diff";
    gc = "git commit";
    gco = "git checkout";
    gp = "git push";
    gl = "git pull";
    ga = "git add";
    gaa = "git add --all";
    gapa = "git add --patch";
    gb = "git branch";
  };
  programs.diff-so-fancy = {
    enable = true;
    settings.stripLeadingSymbols = false;
    enableGitIntegration = true;
  };
  programs.git = {
    enable = true;
    signing = {
      signByDefault = false;
      key = null;
    };
    settings = {
      user = {
        name = "LucasFA";
        email = "23667494+LucasFA@users.noreply.github.com";
      };
      alias = gitAliases;
      extraConfig = {
        safe.directory = "/home/lucasfa/.nixos";
        core = {
          autocrlf = "input";
          editor = "vim";
        };
        push.autoSetupRemote = "true";
        gpg.format = "ssh";
        commit = {
          verbose = true;
          # gpgSign = true;
        };
        color.ui = "true";
        init.defaultBranch = "main";

        diff = {
          algorithm = "histogram";
          colormoved = "default";
          colormovedws = "allow-indentation-change";
        };
        merge.conflictstyle = "zdiff3";
        rebase.missingCommitsCheck = "error";
        help.autocorrect = "prompt";
        branch.sort = "committerdate";
        "url \"ssh://git@github.com:\"" = {
          insteadOf = "https://github.com";
          # insteadOf = "gh:"; # Can only have one :(
        };
        "url \"git@github.com:\"" = {
          insteadOf = "gh:"; # Hacky AF :)
        };

        # Make an particular exception for cargo to work correctly, see https://github.com/rust-lang/cargo/issues/3381
        # [url "https://github.com/rust-lang/crates.io-index"]
        # insteadOf = https://github.com/rust-lang/crates.io-index
        # [url "https://github.com/RustSec/advisory-db"]
        # insteadOf = https://github.com/RustSec/advisory-db

        "credential \"https://git.overleaf.com\"" = {
          helper = "store";
        };

        fetch.prune = "true";
        fetch.prunetags = "true";

        transfer.fsckobjects = "true";
        fetch.fsckobjects = "true";
        receive.fsckobjects = "true";
        "color \"diff-highlight\"" = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
        "color \"diff\"" = {
          meta = "11";
          frag = "magenta bold";
          func = "146 bold";
          commit = "yellow bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
      };
    };
  };
}
