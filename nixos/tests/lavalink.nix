{ lib, ... }:

let
  password = "s3cRe!p4SsW0rD";
in

{
  name = "lavalink";
  meta.maintainers = with lib.maintainers; [ nanoyaki ];

  nodes = {
    lavalink_passwordfile = {
      services.lavalink = {
        enable = true;

        passwordFile = "/etc/lavalink-password";
        settings.server.port = 1234;
      };

      environment.etc."lavalink-password".text = password;
    };

    lavalink_plugins =
      { pkgs, ... }:

      {
        environment.systemPackages = [ pkgs.jq ];

        services.lavalink = {
          enable = true;

          plugins.youtube = {
            dependency = "dev.lavalink.youtube:youtube-plugin:1.16.0";
            hash = "sha256-wKD+C7Y3nj+MpQDIRWvSIJ678jnRxzxEW0e0JkoszA4=";
            settings.enabled = true;
          };

          settings.server.port = 1235;
        };
      };
  };

  testScript = ''
    start_all()

    lavalink_passwordfile.wait_for_unit('lavalink.service')
    lavalink_passwordfile.wait_for_open_port(1234)
    lavalink_passwordfile.succeed(
      'curl --fail -v '
      + '--header "User-Id: 1204475253028429844" '
      + '--header "Client-Name: shoukaku/4.1.1" '
      + '--header "Authorization: ${password}" '
      + 'http://localhost:1234/v4/info'
    )

    lavalink_plugins.wait_for_unit('lavalink.service')
    lavalink_plugins.wait_for_open_port(1235)
    lavalink_plugins.succeed(
      'curl --fail -v '
      + '--header "User-Id: 1204475253028429844" '
      + '--header "Client-Name: shoukaku/4.1.1" '
      + '--header "Authorization: ${password}" '
      + 'http://localhost:1235/v4/info'
    )
  '';
}
