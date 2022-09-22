const express = require("express");
const router = express.Router();
const gods = require("../db/gods");
const abilities = require("../db/abilities");
const apicache = require("apicache");
const { statsManAuth } = require("../auth/auth");

const cache = apicache.middleware;

router.get("/gods", statsManAuth, cache("1 hour"), async (req, res) => {
  try {
    const hours = parseInt(req.query.hours) || 720;
    const stats = await gods.getGodsStats(hours);
    res.status(200).json(stats);
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Server Error" });
  }
});

router.get("/abilities", statsManAuth, cache("1 hour"), async (req, res) => {
  try {
    const hours = parseInt(req.query.hours) || 720;
    const stats = await abilities.getAbilityStats(hours);
    res.status(200).json(stats);
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Server Error" });
  }
});

module.exports = router;
