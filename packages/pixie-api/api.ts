import { serve } from "https://deno.land/std@0.167.0/http/mod.ts";
import { parse } from "https://deno.land/std@0.167.0/flags/mod.ts";

const args = parse(Deno.args);

if (!args.configs) console.error("Missing --configs arg");

const hostConfigs = JSON.parse(await Deno.readTextFile(args.configs));
console.log(hostConfigs);

const githubToken = await githubDeviceFlow(args["github-client-id"]);

serve(
  async (req) => {
    const pathname = new URL(req.url).pathname;

    console.log();
    console.log(req.method, req.url);

    if (req.method === "GET" && pathname.startsWith("/v1/boot")) {
      const mac = pathname.replace("/v1/boot/", "");
      if (mac in hostConfigs) {
        console.log(hostConfigs[mac]);
        return Response.json(hostConfigs[mac]);
      }
    }

    if (req.method === "POST" && pathname.startsWith("/v1/ssh-key")) {
      const key = await (await req.text()).trim();
      const title = pathname.replace("/v1/ssh-key/", "");

      const res = await fetchGithub("/repos/addreas/flakefiles/keys", {
        githubToken,
        method: "POST",
        body: JSON.stringify({ key, title, read_only: false }),
      });

      return res;
    } else {
      console.log(await req.text());
      return new Response();
    }
  },
  {
    port: parseInt(args.port),
    hostname: args.host,
  }
);

async function githubDeviceFlow(client_id: string): Promise<string> {
  const tokenPath = "/tmp/pixie-api-github-token";
  try {
    const tmpToken = await Deno.readTextFile(tokenPath);
    if ((await fetchGithub("/user", { githubToken: tmpToken })).ok) {
      return tmpToken;
    }
  } catch(e) {
    console.log(e)
  }

  while (true) {
    const device_code_req = await fetch(
      "https://github.com/login/device/code",
      {
        method: "POST",
        headers: [
          ["Accept", "application/json"],
          ["Content-Type", "application/json"],
        ],
        body: JSON.stringify({
          client_id,
          scope: "repo",
        }),
      }
    ).then((r) => r.json());

    const expiry = Date.now() + 900 * 1000;

    while (Date.now() < expiry) {
      console.log(
        "You should enter the code",
        device_code_req.user_code,
        "at",
        device_code_req.verification_uri
      );

      const access_token_req = await fetch(
        "https://github.com/login/oauth/access_token",
        {
          method: "POST",
          headers: [
            ["Accept", "application/json"],
            ["Content-Type", "application/json"],
          ],
          body: JSON.stringify({
            client_id,
            grant_type: "urn:ietf:params:oauth:grant-type:device_code",
            device_code: device_code_req.device_code,
          }),
        }
      ).then((r) => r.json());

      if (access_token_req.access_token) {
        const token = access_token_req.access_token;
        await Deno.writeTextFile(tokenPath, token);
        return token;
      }

      await new Promise((resolve) =>
        setTimeout(resolve, device_code_req.interval * 1000)
      );
    }
  }
}

function fetchGithub(
  path: string,
  init: RequestInit & { githubToken: string, headers?: [string, string][] }
) {
  return fetch(`https://api.github.com${path}`, {
    ...init,
    headers: [
      ["Accept", "application/vnd.github+json"],
      ["Authorization", `Bearer ${init.githubToken}`],
      ["X-GitHub-Api-Version", "2022-11-28"],
      ...(init.headers ?? []),
    ],
  });
}
