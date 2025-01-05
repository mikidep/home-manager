{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; let
    make-agda-search = agda-lib:
      writeShellApplication {
        name = "agda-search-${agda-lib}";
        runtimeInputs = with pkgs; [fzf firefox sqlite];
        text = let
          docset = inputs.agda-docsets.packages.x86_64-linux."${agda-lib}-docset";
        in ''
          sqlite3 ${docset}/${agda-lib}.docset/Contents/Resources/docSet.dsidx "select * from searchIndex" \
            | fzf \
            | cut -d '|' -f 4 \
            | xargs -I % firefox --new-window file://${docset}/${agda-lib}.docset/Contents/Resources/Documents/%
        '';
      };
  in [
    (agda.withPackages (p: [
      # (p.cubical.overrideAttrs {
      #   version = "a126e3f";
      #   src = inputs.agda-cubical;
      # })
      p.cubical
      p.standard-library
    ]))
    (make-agda-search "standard-library")
    (make-agda-search "cubical")
  ];
}
