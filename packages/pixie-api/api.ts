import { serve } from "https://deno.land/std@0.167.0/http/mod.ts";
import { parse } from "https://deno.land/std@0.167.0/flags/mod.ts";
import { router } from "https://deno.land/x/rutt/mod.ts";

const routeHandler = router<{hostConfigs: Record<string, any>, githubToken: string}>({
    "/v1/boot/:mac": (req, {hostConfigs}, match) => {
      const mac = match.mac;
      if (mac in hostConfigs) {
        console.log(hostConfigs[mac]);
        return Response.json(hostConfigs[mac]);
      } else {
        return new Response(404)
      }
    },
    "/v1/ssh-key/:title": async (req, {githubToken}, match) => {
      const title = match.title;
      const key = await req.text();

      return await fetchGithub("/repos/addreas/flakefiles/keys", {
        githubToken,
        method: "POST",
        body: JSON.stringify({ key: key.trim(), title, read_only: false }),
      });
    },
  })

const args = parse(Deno.args);

if (!args.configs) console.error("Missing --configs arg");

const hostConfigs = JSON.parse(await Deno.readTextFile(args.configs));
const githubToken = await githubDeviceFlow(args["github-client-id"]);

serve(
  async req => {
    new
    const res = await routeHandler(req, { hostConfigs, githubToken })
    console.log(req.method, req.url, res.status)
    return res
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
