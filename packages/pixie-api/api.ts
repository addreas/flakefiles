import { serve } from "https://deno.land/std@0.167.0/http/mod.ts";
import { parse } from "https://deno.land/std@0.167.0/flags/mod.ts";

const args = parse(Deno.args)

if (!args.configs) console.error("Missing --configs arg")

const hostConfigs = JSON.parse(await Deno.readTextFile(args.configs))
console.log(hostConfigs)
serve(async (req) => {
  const pathname = new URL(req.url).pathname;

  console.log()
  console.log(req.method, req.url)

  if (req.method === "GET" && pathname.startsWith("/v1/boot")) {
    const mac = pathname.replace("/v1/boot/", "")
    if (mac in hostConfigs) {
      console.log(hostConfigs[mac])
      return Response.json(hostConfigs[mac])
    }
  }

  console.log(await req.text())

  return new Response();
}, {
    port: parseInt(args.port),
    hostname: args.host
});
