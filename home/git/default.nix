{ config, pkgs, ... }:
  let gitAliases = {
	sync = "!git pull --rebase && git push";
  	ovp = "!git commit --all --allow-empty-message -m '' && git sync";
    	lg = "lg1";
    	lg1 = "lg1-specific --all";
    	lg2 = "lg2-specific --all";
    	lg3 = "lg3-specific --all";

	lg1-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
    	lg2-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
    	lg3-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";
};
in
{
  programs.git = {
	enable = true;
	userName = "LucasFA";
	userEmail = "23667494+LucasFA@users.noreply.github.com";
	diff-so-fancy = {
		enable = true;
		stripLeadingSymbols = false;
	};
	signing = {
		signByDefault = true;
		key = null;
	};
	aliases = gitAliases;
	extraConfig = {
		safe.directory = "/home/lucasfa/.nixos";
		user.signingkey = "/home/lucasfa/.ssh/id_ed25519.pub";
		core = { 
			autocrlf = "input";
			editor = "vim";
		};
		init.defaultBranch = "main";
		gpg.format = "ssh";
		commit = {
  			verbose = true;
			# gpgSign = true;
		};
		color.ui = "true";
 
		diff = {
			algorithm = "histogram";
			colormoved = "default";
			colormovedws = "allow-indentation-change";
		};
 		merge.conflictstyle = "diff3";
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
			username = "lucasfa@correo.ugr.es";
			helper = "store";
		};
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
}
