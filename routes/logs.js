const express = require("express");
const router = express.Router();
const auth = require("../auth/auth");
const playerLogs = require("../db/logs");

router.get("/payments", auth.adminAuth, async (req, res) => {
  try {
    const totalPaypalAmount = await playerLogs.getTotalPaypalPayments();
    const paypalPayments = await playerLogs.getPaypalPayments();
    const stripePayments = await playerLogs.getStripePayments();
    const totalStripePayments = await playerLogs.getTotalStripePayments();
    const result = {
      paypalTotal: totalPaypalAmount,
      stripeTotal: totalStripePayments,
      paypalPayments: paypalPayments,
      stripePayments: stripePayments,
    };
    res.status(201).send(result);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.toString() });
  }
});

router.get("/players/:steamID", auth.adminAuth, async (req, res) => {
  try {
    const steamID = req.params.steamID;
    const logs = await playerLogs.getLogsForPlayer(steamID);
    res.status(201).send(logs);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.toString() });
  }
});

router.post("/:gameID", auth.keyAuth, async (req, res) => {
  try {
    const gameID = req.params.gameID;
    const logs = await playerLogs.addTransactionLog(
      gameID,
      "game_log",
      req.body
    );
    res.status(201).send(logs);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.toString() });
  }
});

module.exports = router;
