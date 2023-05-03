const tx = require("pg-tx");
const { query, pool } = require("./index");

module.exports = {
  async getAverageCoins() {
    try {
      const { rows } = await query(
        `
        SELECT
          CASE
            WHEN game_count > 100 THEN 'More than 100'
            WHEN game_count > 50 THEN '51-100'
            WHEN game_count > 30 THEN '31-50'
            WHEN game_count > 20 THEN '21-30'
            WHEN game_count > 10 THEN '11-20'
            ELSE '1-10'
          END AS games_played_range,
          AVG(coins) AS average_coins
        FROM (
          SELECT
            p.steam_id,
            p.coins,
            COUNT(gp.game_id) AS game_count
          FROM
            players p
            JOIN game_players gp ON p.steam_id = gp.steam_id
            JOIN games g ON g.game_id = gp.game_id
          WHERE
            g.created_at >= current_date - INTERVAL '30 days'
            AND g.created_at < current_date
          GROUP BY
            p.steam_id,
            p.coins
        ) AS player_game_count
        GROUP BY
          games_played_range
        ORDER BY
          games_played_range;
          `
      );
      return rows;
    } catch (error) {
      throw error;
    }
  },
}