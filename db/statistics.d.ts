declare type GodStat = {
  god: string;
  picks: number;
  first_places: number;
  top_fours: number;
  win_rate: number;
  top_four_rate: number;
};

declare type GodStatTotals = {
  picks: number;
  first_places: number;
  top_fours: number;
};

declare type GodStats = {
  filters: string[];
  totals: GodStatsTotals;
  results: GodStat[];
};

export declare async function getGodStats(filters: string[]): Promise<GodStats>;

declare type AbilityStat = {
  ability_name: string;
  owned_count: number;
  pick_count: number;
  first_places: number;
  average_win_level: number;
  top_fours: number;
  average_top_four_level: number;
  win_rate: number;
  top_four_rate: number;
};
declare type AbilityStatTotals = {
  owned_count: number;
  pick_count: number;
  first_places: number;
  average_win_level: number;
  top_fours: number;
  average_top_four_level: number;
};

declare type AbilityStats = {
  filters: string[];
  totals: AbilityStatTotals;
  results: AbilityStat[];
}
export declare async function getAbilityStats(
  filters: string[]
): Promise<AbilityStats>;
