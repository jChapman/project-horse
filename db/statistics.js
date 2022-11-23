const { query } = require("./index");

module.exports = {
  // Fake dates, can be in any format from https://www.postgresql.org/docs/current/datatype-datetime.html#DATATYPE-DATETIME-INPUT
  // I especially like the ability to just put the timezone in the date string
  season1Start: '2022-10-01 12:00:00 EDT', 
  season2Start: '2022-10-08',
  seasons: {
    1: {
      start: '2022-10-01 12:00:00 EDT', 
      end: '2022-10-07 23:00:00 EDT',
    },
    2: {
      start: '2022-10-08 00:00:00 EDT',
      end: '2022-11-30',
    }
  }
}

/*
**Filters**
Time Filters
 - Season/patch (inc sub patches)
 - Last 24h
 - Last 7 days
 - Last 30 days
Rank Filters
 - Herald - Immortal (only select one)
 - Immo only lobbies

**Query Types**
God Query
  - Win Rate
  - Top 4 Rate
Ability Query
  - Win Rate
  - Top 4 Rate
  - Pick rate
*/