{ pkgs, lib, ... }:
{
  programs.k9s = {
    enable = true;
    # settings.k9s.ui.headless = true;

    plugins =
      let
        flux-reconcile = scopes: args: extra-args: {
          shortCut = "r";
          scopes = scopes;
          background = false;
          description = "Reconcile flux resource";
          confirm = false;
          command = "flux";
          args = [
            "reconcile"
            "--namespace"
            "$NAMESPACE"
            "--context"
            "$CONTEXT"
          ] ++ args ++ [
            "$NAME"
          ] ++ extra-args;
        };
      in
      {
        flux-reconcile-source-git = flux-reconcile [ "gitrepositories" ] [ "source" "git" ] [ ];
        flux-reconcile-kustomization = flux-reconcile [ "kustomizations" ] [ "kustomization" ] [ "--with-source" ];
        flux-reconcile-helm-release = flux-reconcile [ "helmreleases" ] [ "helmrelease" ] [ "--with-source" "--reset" ];
      };
  };
}
