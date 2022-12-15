DROP TABLE IF EXISTS games CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS game_players CASCADE;
DROP TABLE IF EXISTS game_player_heroes CASCADE;
DROP TABLE IF EXISTS abilities CASCADE;
DROP TABLE IF EXISTS hero_abilities CASCADE;
DROP TABLE IF EXISTS combat_results CASCADE;
DROP TABLE IF EXISTS combat_players CASCADE;

DROP TABLE IF EXISTS cosmetics CASCADE;
DROP TABLE IF EXISTS player_cosmetics CASCADE;
DROP TABLE IF EXISTS battle_pass CASCADE;
DROP TABLE IF EXISTS player_battle_pass CASCADE;
DROP TABLE IF EXISTS quests CASCADE;
DROP TABLE IF EXISTS player_quests CASCADE;

DROP TABLE IF EXISTS login_quests;
DROP TABLE IF EXISTS player_login_quests;
DROP TABLE IF EXISTS player_login_quest_status;

-- DROP TABLE IF EXISTS "session" CASCADE;
-- CREATE TABLE IF NOT EXISTS "session" (
--   "sid" varchar NOT NULL COLLATE "default",
--   "sess" json NOT NULL,
--   "expire" timestamp(6) NOT NULL
-- )
-- WITH (OIDS=FALSE);

-- ALTER TABLE "session" ADD CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;
-- DROP INDEX IF EXISTS IDX_session_expire;
-- CREATE INDEX "IDX_session_expire" ON "session" ("expire");

CREATE TABLE IF NOT EXISTS players (
  steam_id TEXT PRIMARY KEY,
  username TEXT,
  profile_picture TEXT,
  mmr INTEGER DEFAULT 1000,
  ladder_mmr INTEGER DEFAULT 0,
  coins INTEGER DEFAULT 0 CHECK (coins >= 0),
  user_type TEXT DEFAULT 'USER',
  patreon_level INTEGER DEFAULT 0,
  plus_expiration TIMESTAMPTZ,
  last_login_quest_claimed TIMESTAMPTZ,
  last_ping TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT Now()
);
CREATE INDEX ix_players_mmr ON players (mmr);

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS settings (
  
);

--------------------------------------------------------------------------------
-- Games
--------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS games (
  game_id TEXT PRIMARY KEY,
  rounds INTEGER,
  ranked BOOLEAN,
  duration DOUBLE PRECISION,
  cheats_enabled BOOLEAN,
  environment TEXT,

  created_at TIMESTAMPTZ DEFAULT Now(),
  end_time TIMESTAMPTZ
);
DROP INDEX IF EXISTS idx_games_created_at;
CREATE INDEX idx_games_created_at ON games (created_at);

CREATE TABLE IF NOT EXISTS game_players (
  game_player_id SERIAL PRIMARY KEY,
  game_id TEXT REFERENCES games (game_id) ON UPDATE CASCADE,
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,

  rounds INTEGER,
  wins INTEGER,
  losses INTEGER,
  end_time DOUBLE PRECISION,
  place INTEGER,
  team INTEGER,
  god TEXT,
  total_level INTEGER,

  mmr INTEGER,
  mmr_change INTEGER DEFAULT 0,
  ladder_mmr_change INTEGER DEFAULT 0,
  coins_change INTEGER DEFAULT 0,
  xp_change INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX ON game_players (game_id, steam_id);
CREATE INDEX idx_game_players_steam_id_fkey ON game_players (steam_id);
CREATE INDEX idx_game_players_game_id_fkey ON game_players (game_id);

CREATE TABLE IF NOT EXISTS game_player_heroes (
  game_player_hero_id SERIAL PRIMARY KEY,
  game_player_id INTEGER REFERENCES game_players (game_player_id) ON UPDATE CASCADE,

  hero_name TEXT NOT NULL,
  tier INTEGER NOT NULL,
  total_damage_dealt INTEGER,
  total_physical_damage INTEGER,
  total_magical_damage INTEGER,
  total_damage_taken INTEGER,
  total_healing INTEGER,
  total_healed INTEGER
);
DROP INDEX IF EXISTS idx_game_player_heroes_hero_name;
CREATE INDEX idx_game_player_heroes_hero_name ON game_player_heroes (hero_name);
CREATE INDEX idx_game_player_heroes_game_player_id ON game_player_heroes (game_player_id);

DROP TABLE IF EXISTS gods;
CREATE TABLE IF NOT EXISTS gods (
  god_name TEXT PRIMARY KEY,
  free BOOLEAN DEFAULT FALSE,
  plus_exclusive BOOLEAN DEFAULT FALSE,
  god_enabled BOOLEAN DEFAULT TRUE
);

DROP TABLE IF EXISTS player_gods;
CREATE TABLE IF NOT EXISTS player_gods (
  god_name TEXT REFERENCES gods (god_name) ON UPDATE CASCADE,
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  banned BOOLEAN DEFAULT FALSE,
  progress INTEGER DEFAULT 0,
  amount_required INTEGER DEFAULT 100,

  CONSTRAINT player_gods_pkey PRIMARY KEY (god_name, steam_id)
);
CREATE INDEX idx_player_gods_steam_id_fkey ON player_gods (steam_id);

CREATE TABLE IF NOT EXISTS abilities (
  ability_name TEXT PRIMARY KEY,
  icon TEXT,
  is_ultimate BOOLEAN
);

CREATE TABLE IF NOT EXISTS hero_abilities (
  game_player_hero_id INTEGER REFERENCES game_player_heroes (game_player_hero_id) ON UPDATE CASCADE,
  ability_name TEXT REFERENCES abilities (ability_name) ON UPDATE CASCADE,

  ability_level INTEGER,
  slot_index INTEGER
);
DROP INDEX IF EXISTS idx_hero_abilities_ability_name;
CREATE INDEX idx_hero_abilities_ability_name ON hero_abilities (ability_name);
CREATE UNIQUE INDEX ON hero_abilities (game_player_hero_id, ability_name);

CREATE TABLE IF NOT EXISTS combat_results (
  combat_results_id SERIAL PRIMARY KEY,
  game_id TEXT REFERENCES games (game_id) ON UPDATE CASCADE,

  duration DOUBLE PRECISION NOT NULL,
  round_number INTEGER NOT NULL
);
CREATE INDEX idx_combat_results_game_id ON combat_results (game_id);

CREATE TABLE IF NOT EXISTS combat_players (
  combat_results_id INTEGER REFERENCES combat_results (combat_results_id) ON UPDATE CASCADE,
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,

  damage_taken INTEGER,
  ghost BOOLEAN
);

--------------------------------------------------------------------------------
-- Cosmetics
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cosmetics (
  cosmetic_id SERIAL PRIMARY KEY,
  cosmetic_name TEXT UNIQUE,
  cosmetic_type TEXT,
  equip_group TEXT,
  cost_coins INTEGER,
  cost_usd DOUBLE PRECISION,
  rarity TEXT
);

CREATE TABLE IF NOT EXISTS player_cosmetics (
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id) ON UPDATE CASCADE,
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  created TIMESTAMPTZ DEFAULT NOW(),
  viewed BOOLEAN DEFAULT FALSE,
  equipped BOOLEAN DEFAULT FALSE
);
CREATE INDEX "IDX_player_cosmetics_cosmetic_id_steam_id" ON player_cosmetics(cosmetic_id, steam_id);

--------------------------------------------------------------------------------
-- Battle Pass
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS battle_pass CASCADE;
CREATE TABLE IF NOT EXISTS battle_pass (
  battle_pass_id SERIAL PRIMARY KEY,
  is_active BOOLEAN DEFAULT FALSE,
  created TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS battle_pass_levels CASCADE;
CREATE TABLE IF NOT EXISTS battle_pass_levels (
  battle_pass_id INTEGER REFERENCES battle_pass (battle_pass_id) ON UPDATE CASCADE,
  bp_level INTEGER NOT NULL,
  next_level_xp INTEGER NOT NULL,
  total_xp INTEGER NOT NULL,
  coins_reward INTEGER,

  CONSTRAINT battle_pass_levels_pkey PRIMARY KEY (battle_pass_id, bp_level)
);

DROP TABLE IF EXISTS battle_pass_cosmetic_rewards CASCADE;
CREATE TABLE IF NOT EXISTS battle_pass_cosmetic_rewards (
  battle_pass_id INTEGER REFERENCES battle_pass (battle_pass_id) ON UPDATE CASCADE,
  bp_level INTEGER NOT NULL,
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id) ON UPDATE CASCADE,
  free BOOLEAN DEFAULT TRUE,
  amount INTEGER DEFAULT 1
);

DROP TABLE IF EXISTS player_battle_pass CASCADE;
CREATE TABLE IF NOT EXISTS player_battle_pass (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  battle_pass_id INTEGER REFERENCES battle_pass (battle_pass_id) ON UPDATE CASCADE,
  unlocked BOOLEAN DEFAULT FALSE,
  bp_level INTEGER DEFAULT 1,
  total_xp INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX ON player_battle_pass (steam_id, battle_pass_id);

DROP TABLE IF EXISTS player_claimed_battle_pass_rewards CASCADE;
CREATE TABLE IF NOT EXISTS player_claimed_battle_pass_rewards (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  battle_pass_id INTEGER REFERENCES battle_pass (battle_pass_id) ON UPDATE CASCADE,
  bp_level INTEGER NOT NULL
);
CREATE INDEX "IDX_player_claimed_battle_pass_rewards_steam_id_battle_pass_id"
ON player_claimed_battle_pass_rewards(steam_id, battle_pass_id);

--------------------------------------------------------------------------------
-- Quests / Achievements
--------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS quests (
  quest_id SERIAL PRIMARY KEY,
  quest_name TEXT NOT NULL,
  is_achievement BOOLEAN NOT NULL,
  is_hidden BOOLEAN DEFAULT FALSE,
  is_weekly BOOLEAN DEFAULT FALSE,
  quest_description TEXT,
  coin_reward INTEGER DEFAULT 0,
  xp_reward INTEGER DEFAULT 0,
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id) ON UPDATE CASCADE,
  stat TEXT NOT NULL,
  auto_claim BOOLEAN DEFAULT FALSE,
  required_amount INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS player_quests (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  quest_id INTEGER REFERENCES quests (quest_id) ON UPDATE CASCADE,
  quest_progress INTEGER DEFAULT 0,
  created TIMESTAMPTZ DEFAULT NOW(),
  claimed BOOLEAN DEFAULT FALSE,
  quest_index INTEGER,

  CONSTRAINT player_quests_pkey PRIMARY KEY (steam_id, quest_id)
);

--------------------------------------------------------------------------------
-- Login Quests
--------------------------------------------------------------------------------

-- Quests that you claim every day you login
CREATE TABLE IF NOT EXISTS login_quests (
  login_quest_id SERIAL PRIMARY KEY,
  day INTEGER NOT NULL UNIQUE,
  coin_reward INTEGER DEFAULT 0,
  xp_reward INTEGER DEFAULT 0,
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id)
);

-- Every day, if you play a game, or login to the site, you complete
-- the quest for that 24 hour period
CREATE TABLE IF NOT EXISTS player_login_quests (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  login_quest_id INTEGER REFERENCES login_quests (login_quest_id) ON UPDATE CASCADE,
  claimed BOOLEAN DEFAULT FALSE,
  completed BOOLEAN DEFAULT FALSE
);
CREATE UNIQUE INDEX ON player_login_quests (steam_id, login_quest_id);

--------------------------------------------------------------------------------
-- Welcome Quests
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS welcome_quests CASCADE;
CREATE TABLE IF NOT EXISTS welcome_quests (
  welcome_quest_id SERIAL PRIMARY KEY,
  day INTEGER NOT NULL UNIQUE,
  coin_reward INTEGER DEFAULT 0,
  xp_reward INTEGER DEFAULT 0,
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id)
);
CREATE INDEX "IDX_welcome_quests_day" ON welcome_quests(day);

DROP TABLE IF EXISTS player_welcome_quests CASCADE;
CREATE TABLE IF NOT EXISTS player_welcome_quests (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  welcome_quest_id INTEGER REFERENCES welcome_quests (welcome_quest_id) ON UPDATE CASCADE,
  claim_date TIMESTAMPTZ
);
CREATE UNIQUE INDEX ON player_welcome_quests (steam_id, welcome_quest_id);

--------------------------------------------------------------------------------
-- Chest Drops
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS drop_type_rewards;
CREATE TABLE IF NOT EXISTS drop_type_rewards (
  drop_type TEXT NOT NULL,
  reward_cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id),
  cum_sum_odds DOUBLE PRECISION NOT NULL,

  CONSTRAINT drop_type_rewards_pkey PRIMARY KEY (drop_type, reward_cosmetic_id)
);

DROP TABLE IF EXISTS chest_drop_types;
CREATE TABLE IF NOT EXISTS chest_drop_types (
  chest_cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id),
  drop_type TEXT NOT NULL,
  cum_sum_odds DOUBLE PRECISION NOT NULL,

  CONSTRAINT chest_drop_types_pkey PRIMARY KEY (chest_cosmetic_id, drop_type, cum_sum_odds)
);

--------------------------------------------------------------------------------
-- Unique Chests
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS escalating_odds_tables;
CREATE TABLE IF NOT EXISTS escalating_odds_tables (
  rarity TEXT PRIMARY KEY
);

DROP TABLE IF EXISTS escalating_odds;
CREATE TABLE IF NOT EXISTS escalating_odds (
  rarity TEXT REFERENCES escalating_odds_tables (rarity),
  odds DECIMAL(14, 4) NOT NULL,
  opening_number INTEGER NOT NULL,

  CONSTRAINT escalating_odds_pkey PRIMARY KEY (rarity, opening_number)
);

DROP TABLE IF EXISTS unique_chests;
CREATE TABLE IF NOT EXISTS unique_chests (
  unique_chest_id SERIAL PRIMARY KEY,
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id)
);
CREATE UNIQUE INDEX ON unique_chests (cosmetic_id);

DROP TABLE IF EXISTS unique_chest_drops;
CREATE TABLE IF NOT EXISTS unique_chest_drops (
  unique_chest_id INTEGER REFERENCES unique_chests (unique_chest_id),
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id),
  rarity TEXT REFERENCES escalating_odds_tables (rarity),

  CONSTRAINT unique_chest_drops_pkey PRIMARY KEY (unique_chest_id, cosmetic_id)
);

DROP TABLE IF EXISTS player_unique_chests;
CREATE TABLE IF NOT EXISTS player_unique_chests (
  player_unique_chest_id SERIAL PRIMARY KEY,
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  unique_chest_id INTEGER REFERENCES unique_chests (unique_chest_id),
  active BOOLEAN NOT NULL
);
CREATE INDEX "IDX_player_unique_chests_steam_id" ON player_unique_chests(steam_id);

DROP TABLE IF EXISTS player_unique_chests_drops;
CREATE TABLE IF NOT EXISTS player_unique_chests_drops (
  player_unique_chest_id INTEGER REFERENCES player_unique_chests (player_unique_chest_id),
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id),

  CONSTRAINT player_unique_chests_drops_pkey PRIMARY KEY (player_unique_chest_id, cosmetic_id)
);

DROP TABLE IF EXISTS player_missed_drop_counts;
CREATE TABLE IF NOT EXISTS player_missed_drop_counts (
  unique_chest_id INTEGER REFERENCES unique_chests (unique_chest_id),
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id),
  missed_drop_count INTEGER DEFAULT 0,

  CONSTRAINT player_missed_drop_counts_pkey PRIMARY KEY (unique_chest_id, cosmetic_id)
);

--------------------------------------------------------------------------------
-- Reward Codes
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS redemption_codes;
CREATE TABLE IF NOT EXISTS redemption_codes (
  code TEXT PRIMARY KEY,
  active BOOLEAN DEFAULT TRUE,
  redemption_limit INTEGER DEFAULT NULL,
  coins INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS redemption_code_rewards;
CREATE TABLE IF NOT EXISTS redemption_code_rewards (
  code TEXT REFERENCES redemption_codes (code) ON UPDATE CASCADE,
  cosmetic_id INTEGER REFERENCES cosmetics (cosmetic_id) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS player_redeemed_codes;
CREATE TABLE IF NOT EXISTS player_redeemed_codes (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  code TEXT REFERENCES redemption_codes (code) ON UPDATE CASCADE,
  date_claimed TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT player_redeemed_codes_pkey PRIMARY KEY (steam_id, code)
);

--------------------------------------------------------------------------------
-- Matchmaking
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS lobbies CASCADE;
CREATE TABLE IF NOT EXISTS lobbies (
  lobby_id SERIAL PRIMARY KEY,
  region TEXT,
  min_rank INTEGER,
  max_rank INTEGER,
  lobby_password TEXT,
  lock_time TIMESTAMPTZ
);

DROP TABLE IF EXISTS lobby_players;
CREATE TABLE IF NOT EXISTS lobby_players (
  lobby_id INTEGER REFERENCES lobbies (lobby_id),
  steam_id TEXT REFERENCES players (steam_id) UNIQUE,
  is_host BOOLEAN DEFAULT FALSE,
  ready BOOLEAN DEFAULT FALSE,
  leaderboard_rank INTEGER,
  avatar TEXT,

  CONSTRAINT lobby_players_pkey PRIMARY KEY (lobby_id, steam_id)
);
CREATE UNIQUE INDEX ON lobby_players (lobby_id, steam_id);

--------------------------------------------------------------------------------
-- Polls
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS votes;
DROP TABLE IF EXISTS poll_options;
DROP TABLE IF EXISTS polls;
CREATE TABLE IF NOT EXISTS polls (
  poll_id SERIAL PRIMARY KEY,
  poll_name TEXT,
  poll_description TEXT
);

CREATE TABLE IF NOT EXISTS poll_options (
  option_id SERIAL UNIQUE NOT NULL,
  poll_id INTEGER REFERENCES polls (poll_id),
  option_text TEXT NOT NULL,
  votes INTEGER default 0,

  CONSTRAINT poll_options_pkey PRIMARY KEY (poll_id, option_id)
);

CREATE TABLE IF NOT EXISTS votes (
  poll_id INTEGER REFERENCES polls (poll_id),
  steam_id TEXT REFERENCES players (steam_id),
  vote INTEGER REFERENCES poll_options (option_id),

  CONSTRAINT vote_pkey PRIMARY KEY (poll_id, steam_id)
);

--------------------------------------------------------------------------------
-- Announcements
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS announcements;
CREATE TABLE IF NOT EXISTS announcements (
  language TEXT PRIMARY KEY,
  text TEXT,
  link TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS player_logs;
CREATE TABLE IF NOT EXISTS player_logs (
  steam_id TEXT REFERENCES players (steam_id) ON UPDATE CASCADE,
  log_event TEXT NOT NULL,
  log_data JSON,
  log_time TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX "IDX_player_logs_event" ON player_logs(log_event);
CREATE INDEX "IDX_player_steam_id" ON player_logs(steam_id);


--------------------------------------------------------------------------------
-- Ranks
--------------------------------------------------------------------------------
DROP table if exists ranks;
CREATE TABLE ranks
(
    name               text,
    mmr_floor          integer,
    mmr_ceiling        integer,
    ladder_mmr_floor   integer,
    ladder_mmr_ceiling integer
);
/* -- Game mmr vs ladder mmr
select case
           when players.ladder_mmr between 0 and 500 then 'Herald'
           when players.ladder_mmr between 500 and 1000 then 'Guardian'
           when players.ladder_mmr between 1000 and 1500 then 'Crusader'
           when players.ladder_mmr between 1500 and 2000 then 'Archon'
           when players.ladder_mmr between 2000 and 2500 then 'Legend'
           when players.ladder_mmr between 2500 and 3500 then 'Ancient'
           when players.ladder_mmr between 3500 and 4500 then 'Divine'
           when players.ladder_mmr > 4500 then 'Immortal'
           end,
       count(distinct steam_id) as players_in_rank,
       count(distinct game_id) as games_played,
       avg(game_players.mmr) as avg_game_mmr,
       stddev(game_players.mmr) as stddev_game_mmr,
       min(game_players.mmr) as min_game_mmr,
       max(game_players.mmr) as max_game_mmr,
       min(players.ladder_mmr) as min_ladder_mmr,
       max(players.ladder_mmr) as max_ladder_mmr
from players join game_players using (steam_id) join games using (game_id)
where games.created_at between '2022-11-15' and '2022-12-01' -- Some short range of dates late in the season
group by 1;
 */

/** TODO: ladder mmr values are just guesses, could see what values in the db are for people in each actual ranks (see query above)*/
insert into ranks
    (name, mmr_floor, mmr_ceiling, ladder_mmr_floor, ladder_mmr_ceiling)
VALUES ('Herald', 0, 500, -1000, 399),
       ('Guardian', 500, 1000, 400, 599),
       ('Crusader', 1000, 1500, 600, 799),
       ('Archon', 1500, 2000, 800, 999),
       ('Legend', 2000, 2500, 1000, 1199),
       ('Ancient', 2500, 3500, 1200, 1399),
       ('Divine', 3500, 4500, 1400, 1599),
       ('Immortal', 4500, 9999, 1600, 3000);


--------------------------------------------------------------------------------
-- Stats Rollup Tables
--------------------------------------------------------------------------------
CREATE TABLE if not exists stats_rollup_lock
(
    rollup_name        text,
    rollup_in_progress boolean
);


CREATE TABLE if not exists stats_gods_rollup
(
    day           date,
    rank          text,
    god_name      text,
    picks         integer,
    wins          integer,
    top_fours     integer,
    average_place real
);
CREATE INDEX "IDX_stats_gods_rollup_day" ON stats_gods_rollup(day)


--------------------------------------------------------------------------------
-- Stats Rollup Functions
--------------------------------------------------------------------------------
/*
 Creates an entry in the stats_rollup_lock to indicate that something is currently updating a specific rollup table

 Returns true if we acquired the lock and can proceed
 Make sure to call unlock_rollup when done or the lock never gets release
 */
create or replace function lock_rollup_if_we_can(name text) returns bool
    language plpgsql AS
$$
BEGIN
    /* Make sure there's not currently an update in progress */
    IF EXISTS(select rollup_in_progress from stats_rollup_lock where rollup_name = name)
    THEN
        IF ((select rollup_in_progress from stats_rollup_lock where rollup_name = name) = true)
        THEN
            RETURN false; /* Update is already in progress */
        END IF;
        UPDATE stats_rollup_lock
        SET rollup_in_progress = true
        WHERE rollup_name = name;
    ELSE
        INSERT INTO stats_rollup_lock VALUES (name, true);
    END IF;
    return true; /* We either made a new entry or true'd an already existing entry */
END;
$$;

/*
 Removes the lock (if it exists) for the given name
 */
create or replace function unlock_rollup(name text) returns void
    language plpgsql AS
$$
BEGIN
    IF EXISTS(select rollup_in_progress from stats_rollup_lock where rollup_name = name)
    THEN
        UPDATE stats_rollup_lock
        SET rollup_in_progress = false
        WHERE rollup_name = name;
    END IF;
END;
$$;

/*
 Creates rollup entries in stats_gods_rollup for the given date
 Fails if something is already trying to do a god rollup or if there is any entry for the provided date
 */
create or replace function rollup_gods(d date) RETURNS bool
    language plpgsql AS
$$
DECLARE
    rank_row record;
BEGIN
    IF EXISTS(select day from stats_gods_rollup where day = d)
    THEN
        return false; /* We already have data for the requested date */
    END IF;
    IF not (lock_rollup_if_we_can('rollup_gods'))
    THEN
        return false; /* Failed to lock */
    END IF;
    for rank_row in select * from ranks
        LOOP
            insert into stats_gods_rollup (day, rank, god_name, picks, wins, top_fours, average_place)
            select d                                           as day,
                   rank_row.name                               as rank,
                   god,
                   count(*)                                    as picks,
                   sum(case when place = 1 then 1 else 0 end)  as first_places,
                   sum(case when place <= 4 then 1 else 0 end) as top_fours,
                   avg(place)                                  as average_place
            from games
                     join game_players using (game_id)
            where ranked = true
              and game_players.mmr between rank_row.ladder_mmr_floor and rank_row.ladder_mmr_ceiling
              and created_at::date = d
            group by god, day, rank;
        END LOOP;
    PERFORM unlock_rollup('rollup_gods');
    return true;
END;
$$;


/*
 Rolls up god stats for every day since 9/21/22 until yesterday (since there will be more games today), if there is already data for that day then it's skipped
*/
create or replace function rollup_gods_all() RETURNS table (day date, rollup_succeeded bool)
    language plpgsql AS
$$
DECLARE
    rollup_day date;
BEGIN
    for rollup_day in select d::date from generate_series('2022-09-21', (now()- interval '1 day')::date, interval '1 day') as d
        LOOP
        day := rollup_day;
        rollup_succeeded := (select rollup_gods(rollup_day));
        return NEXT;
        END LOOP;
END;
$$;
