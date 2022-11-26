const { query } = require("./index");

const ranks = [
  { name: "Herald", floor: 0, ceiling: 500 },
  { name: "Guardian", floor: 500, ceiling: 1000 },
  { name: "Crusader", floor: 1000, ceiling: 1500 },
  { name: "Archon", floor: 1500, ceiling: 2000 },
  { name: "Legend", floor: 2000, ceiling: 2500 },
  { name: "Ancient", floor: 2500, ceiling: 3500 },
  { name: "Divine", floor: 3500, ceiling: 4500 },
  { name: "Immortal", floor: 4500, ceiling: 9999 },
];
const rankNames = ranks.map((r) => r.name);

function getRankFilter(rankName) {
  const rank = ranks.find(
    (r) => r.name.toLowerCase() == rankName.toLowerCase()
  );
  return `mmr between ${rank.floor} and ${rank.celing - 1}`;
}

timeNames = ["day", "week", "month", "year"];

function getTimeFilter(durationName) {
  durationString = "UNKNOWN DURATION NAME";
  durationName = durationName.toLowerCase();
  if (durationName === "day") durationString = "1 day";
  else if (durationName === "week") durationString = "1 week";
  else if (durationName === "month") durationString = "1 month";
  return `created_at > now() - interval '${durationString}'`;
}

const seasons = [
  {
    name: "1.0",
    start: "2022-07-08 15:52:32 UTC",
    end: "2022-11-01 16:26:00 EDT",
  },
  {
    name: "1.5",
    start: "2022-10-05 18:00:00 EDT",
    end: "2022-11-01 16:26:00 EDT",
  },
  {
    name: "1.5b",
    start: "2022-10-06 19:18:00 EDT",
    end: "2022-11-01 16:26:00 EDT",
  }, // It's both the 6th and the 14th?
  {
    name: "2.0",
    start: "2022-11-01 16:26:00 EDT",
    end: "2022-12-01 12:00:00 EST",
  },
  {
    name: "2.0b",
    start: "2022-11-04 18:00:00 EST",
    end: "2022-11-07 00:00:00 EST",
  },
  {
    name: "2.0c",
    start: "2022-11-07 00:00:00 EST",
    end: "2022-11-14 15:00:00 EST",
  },
  {
    name: "2.5",
    start: "2022-11-14 15:00:00 EST",
    end: "2022-12-01 12:00:00 EST",
  },
  {
    name: "2.5b",
    start: "2022-11-17 23:00:00 EST",
    end: "2022-12-01 12:00:00 EST",
  },
];

const seasonNames = seasons.map((s) => s.name);

function getSeasonFilter(seasonName) {
  const season = seasons.find(
    (s) => s.name.toLowerCase() == seasonName.toLowerCase()
  );
  return `created_at between '${season.start}' and ${season.end}`;
}

/**
--- Pick count (summing the level of the ability), win count, top 4 count
select ability_name,
       sum(ability_level) as picks,
       avg(ability_level) as average_level,
       sum(case when place = 1 then 1 else 0 end) as first_places,
       avg(case when place = 1 then ability_level else null end) as average_win_level,
       sum(case when place >= 4 then 1 else 0 end) as top_fours,
       avg(case when place >= 4 then ability_level else null end) as average_top_four_level

from hero_abilities join game_player_heroes using(game_player_hero_id)
                    join game_players using(game_player_id)
                    join games using(game_id)
where ranked is true
group by rollup(ability_name)
order by picks desc;
 */
function getAbilityStatsQuery() {
  return {
    select: [
      "ability_name",
      "sum(ability_level) as picks",
      "avg(ability_level) as average_level",
      "sum(case when place = 1 then 1 else 0 end) as first_places",
      "avg(case when place = 1 then ability_level else null end) as average_win_level",
      "sum(case when place >= 4 then 1 else 0 end) as top_fours",
      "avg(case when place >= 4 then ability_level else null end) as average_top_four_level",
    ],
    from: "hero_abilities join game_player_heroes using(game_player_hero_id) join game_players using(game_player_id) join games using(game_id)",
    where: ["ranked is true"],
    end: "group by rollup(ability_name) order by picks DESC",
  };
}

/**
--- Pick count, win count, top 4 count (to calc pick rate adjusted win rate)
select god, count(*) as picks,
       sum(case when place = 1 then 1 else 0 end) as first_places,
       sum(case when place >= 4 then 1 else 0 end) as top_fours
from games g join game_players gp on g.game_id = gp.game_id
  where ranked is true
group by rollup(god)
order by first_places DESC;
 */
function getGodStatsQuery() {
  return {
    select: [
      "god",
      "count(*) as picks",
      "sum(case when place = 1 then 1 else 0 end) as first_places",
      "sum(case when place >= 4 then 1 else 0 end) as top_fours",
    ],
    from: "games join game_players using(game_id)",
    where: ["ranked is true"],
    end: "group by rollup(god) order by first_places DESC",
  };
}

function queryToString(query) {
  return `SELECT ${query.select.join(",")} 
          FROM ${query.from}
          WHERE ${query.where.join(" and ")}
          ${query.end}`;
}

module.exports = {
  FILTERS: {
    TIME: timeNames.reduce((prev, curr) => {
      prev[curr.toUpperCase()] = curr;
      return prev;
    }, {}),
    SEANSON: seasonNames.reduce((prev, curr) => {
      prev[curr.toUpperCase()] = curr.name;
      return prev;
    }, {}),
    RANK: rankNames.reduce((prev, curr) => {
      prev[curr.toUpperCase()] = curr.name;
      return prev;
    }, {}),
  },

  async getGodStats(filters) {
    let q = getGodStatsQuery();
    let mappedFilters = [];
    for (const f in filters) {
      if (seasonNames.includes(f)) {
        q.where.push(getSeasonFilter(f));
        mappedFilters.push(`Season filter '${f}'`);
      } else if (rankNames.includes(f)) {
        q.where.push(getRankFilter(f));
        mappedFilters.push(`Rank filter '${f}'`);
      } else if (timeNames.includes(f)) {
        q.where.push(getTimeFilter(f));
        mappedFilters.push(`Time filter '${f}'`);
      } else {
        mappedFilters.push(`UNKNOWN FILTER '${f}'`);
      }
    }
    const { rows } = await query(queryToString(q));
    const [rollup, ...godRows] = rows;
    const { god: _, ...totals } = rollup;
    return {
      filters: mappedFilters,
      totals,
      results: godRows.map((gStat) => ({
        ...gStat,
        winRate: gStat.picks > 0 ? gStat.first_places / gStat.picks : 0,
        topFourRate: gStat.picks > 0 ? gStat.top_fours / gStat.picks : 0,
      })),
    };
  },
};
