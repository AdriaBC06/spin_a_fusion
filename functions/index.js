"use strict";

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const ALLOWED_HOST = "fusioncalc.com";
const ALLOWED_PATH_PREFIX = "/wp-content/themes/twentytwentyone/pokemon/";

exports.fusionImageProxy = onRequest(
  {
    region: "us-central1",
    cors: true,
    timeoutSeconds: 20,
    memory: "256MiB",
  },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const sourceUrl = req.query.url;
    if (!sourceUrl || typeof sourceUrl !== "string") {
      res.status(400).send("Missing query param: url");
      return;
    }

    let parsed;
    try {
      parsed = new URL(sourceUrl);
    } catch (error) {
      res.status(400).send("Invalid url");
      return;
    }

    if (parsed.protocol !== "https:") {
      res.status(400).send("Only https URLs are allowed");
      return;
    }

    if (parsed.hostname !== ALLOWED_HOST) {
      res.status(403).send("Host not allowed");
      return;
    }

    if (!parsed.pathname.startsWith(ALLOWED_PATH_PREFIX)) {
      res.status(403).send("Path not allowed");
      return;
    }

    try {
      const upstream = await fetch(parsed.toString(), {
        redirect: "follow",
        headers: {
          "User-Agent": "spin-a-fusion-image-proxy/1.0",
        },
      });

      if (!upstream.ok) {
        res.status(upstream.status).send("Upstream image not available");
        return;
      }

      const contentType = upstream.headers.get("content-type") || "";
      if (!contentType.startsWith("image/")) {
        res.status(502).send("Upstream did not return an image");
        return;
      }

      const buffer = Buffer.from(await upstream.arrayBuffer());
      res.set("Content-Type", contentType);
      res.set("Cache-Control", "public, max-age=21600, s-maxage=86400");
      res.status(200).send(buffer);
    } catch (error) {
      logger.error("fusionImageProxy failed", error);
      res.status(502).send("Failed to fetch image");
    }
  },
);
