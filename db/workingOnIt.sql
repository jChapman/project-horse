-- All ranked games
select count(*) from games where ranked is true;

-- Ranked games that are actually bad
select count(*) from games where ranked is true and rounds < 3 or duration < 5 * 60;

with ranked_games as (select * from games where ranked is true) select count(*) as total_ranked from ranked_games;

-- Selecting games that are part of a certain patch, first date: release of the patch, second date: release of the next patch
select * from games where created_at between '2022-10-01 00:00:00 EDT' and date('2022-10-08') and ranked is true;

-- From mmr.js
--const getRankBadge = (mmr) => {
  --if (mmr < 500) return "Herald";
  --if (mmr < 1000) return "Guardian";
  --if (mmr < 1500) return "Crusader";
  --if (mmr < 2000) return "Archon";
  --if (mmr < 2500) return "Legend";
  --if (mmr < 3500) return "Ancient";
  --if (mmr < 4500) return "Divine";
  --else return "Immortal";
--};


select god, count(*) from games join game_players using(game_id) where ranked is true and mmr > 1000 group by god;
select count(*) from games where ranked is true; -- 69 (I think there's one bad game)

-- God win count, win %
select god, count(*), (count(*) / SUM(count(*)) over()) as percent
from games g join game_players gp on g.game_id = gp.game_id
where g.ranked is true
    and gp.place = 1
group by god;

-- God top 4
select god, count(*), (count(*) / SUM(count(*)) over()) as percent
from games g join game_players gp on g.game_id = gp.game_id
where g.ranked is true
    and gp.place >= 4
group by god;

-- Ability win rate
select ability_name, count(*) as wins,(count(*) / SUM(count(*)) over()) as percent_wins
from hero_abilities join game_player_heroes using(game_player_hero_id)
    join game_players using(game_player_id)
    join games using(game_id)
where ranked is true
    and place = 1
group by ability_name
order by wins desc;

-- Ability top 4 rate
select ability_name, count(*) as top_fours
from hero_abilities join game_player_heroes using(game_player_hero_id)
    join game_players using(game_player_id)
    join games using(game_id)
where ranked is true
    and place >= 4
group by ability_name
order by top_fours desc;

-- Ability pick rate
select ability_name, sum(ability_level) as picks, (count(*) / sum(count(*)) over()) as percent_pick
from hero_abilities join game_player_heroes using(game_player_hero_id)
    join game_players using(game_player_id)
    join games using(game_id)
where ranked is true
group by ability_name
order by picks desc;

-- Most common pairs of abilities (all kinds of games)
select a1.ability_name, a2.ability_name, count(*)
from hero_abilities as a1 join hero_abilities as a2 using(game_player_hero_id)
where a1.ability_name < a2.ability_name
group by a1.ability_name, a2.ability_name;

-- Most common pairs of abilities for immortals
select a1.ability_name, a2.ability_name, count(*)
from hero_abilities as a1 join hero_abilities as a2 using(game_player_hero_id)
    join game_player_heroes gph on a1.game_player_hero_id = gph.game_player_hero_id
    join game_players gp on gph.game_player_id = gp.game_player_id
    join games g on gp.game_id = g.game_id
where a1.ability_name < a2.ability_name
    and ranked is true
    and mmr > 1000
group by a1.ability_name, a2.ability_name;
