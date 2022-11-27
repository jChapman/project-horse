<script>


export default {
  data: () => ({
    loading: true,
    abilityStats: [],
    // TODO copied from db/statistics.js, should be in a common place...
    timeFilters: ["Day", "Week", "Month"],
    activeTimeFilter: '',
    rankFilters: ["Herald", "Guardian", "Crusader", "Archon", "Legend", "Ancient", "Divine", "Immortal"],
    activeRankFilter: '',
    patchFilters: ["1.0", "1.5", "1.5b", "2.0", "2.0b", "2.0c", "2.5", "2.5b"],
    activePatchFilter: '',
    fields: [
      {
        key: "ability_name",
        label: "Ability",
        thClass: "table-head text-left",
        sortable: true,
      },
      {
        key: "win_rate",
        label: "Win Rate",
        thClass: "table-head",
        sortable: true,
      },
      {
        key: "top_four_rate",
        label: "Top Four Rate",
        thClass: "table-head",
        sortable: true,
      },
      {
        key: "pick_count",
        label: "Total Picks",
        thClass: "table-head",
        sortable: true,
      },
      {
        key: "owned_count",
        label: "Total Owned",
        thClass: "table-head",
        sortable: true,
      },
      {
        key: "average_win_level",
        label: "Avg Win Level",
        thClass: "table-head",
        sortable: true,
      },
      {
        key: "average_top_four_level",
        label: "Avg Top 4 Level",
        thClass: "table-head",
        sortable: true,
      },
    ],
  }),

  methods: {
    async loadAbilityStats() {
      this.abilityStats = [];
      this.loading = true;
      const filters = [this.activePatchFilter, this.activeTimeFilter, this.activeRankFilter].filter(f => f).join(',')
      fetch(`/api/stats/more/abilities?filters=${filters}`).then(r => r.json()).then(as => {
        this.abilityStats = as.results;
        this.loading = false;
      }
      )
    },
    setDefaultFilters() {
      this.activePatchFilter = this.patchFilters[this.patchFilters.length - 1]
      //this.activeRankFilter = this.rankFilters[this.rankFilters.length - 1]
    }
  },

  created() {
    this.setDefaultFilters();
  },
  watch: {
    activePatchFilter: function () { this.loadAbilityStats(); },
    activeRankFilter: function () { this.loadAbilityStats(); },
    activeTimeFilter: function () { this.loadAbilityStats(); },
  }
}
</script>

<template>
  <div class="container">
    <h1 class="page-title">Ability Statistics</h1>
    <div class="table-and-filters">
      <b-table :busy="loading" :fields="fields" :items="abilityStats" responsive class="stats-table" show-empty
        empty-text="No games found">
        <template #cell(ability_name)="data">
          <div class="text-left p-2">
            <img :src="`/images/ability_icons/${data.item.icon}.png`" width="60px">
            {{ $t(`abilities.${data.item.ability_name}`) }}
          </div>
        </template>
        <template #cell(win_rate)="data">
          <div class="percent-td">
            <div class="text-left">
              {{ (data.item.win_rate * 100).toFixed(2) }}%
            </div>
          </div>
        </template>
        <template #cell(top_four_rate)="data">
          <div class="percent-td">
            <div class="text-left">
              {{ (data.item.top_four_rate * 100).toFixed(2) }}%
            </div>
          </div>
        </template>
        <template #cell(average_win_level)="data">
          <div>
            {{ (+data.item.average_win_level).toFixed(2) }}
          </div>
        </template>
        <template #cell(average_top_four_level)="data">
          <div>
            {{ (+data.item.average_top_four_level).toFixed(2) }}
          </div>
        </template>
      </b-table>
      <div>
        <!-- TODO: this could totally be a component onto itself-->
        <div class="filter-group">
          <span>Patch Filters</span>
          <button @click="activePatchFilter = ''">Clear</button>
          <div class="filter-options">
            <div v-for="f in patchFilters" :key="f">
              <input type="radio" :id="f" :value="f" v-model="activePatchFilter" />
              <label :for="f">{{ f }}</label>
            </div>
          </div>
        </div>
        <div class="filter-group">
          <span>Skill Filters</span>
          <button @click="activeRankFilter = ''">Clear</button>
          <div class="filter-options">
            <div v-for="f in rankFilters" :key="f">
              <input type="radio" :id="f" :value="f" v-model="activeRankFilter" />
              <label :for="f">{{ f }}</label>
            </div>
          </div>
        </div>
        <div class="filter-group">
          <span>Recency Filters</span>
          <button @click="activeTimeFilter = ''">Clear</button>
          <div class="filter-options">
            <div v-for="f in timeFilters" :key="f">
              <input type="radio" :id="f" :value="f" v-model="activeTimeFilter" />
              <label :for="f">{{ f }}</label>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@media (min-width: 1200px) {
  .container {
    max-width: 1580px;
  }
}

.stats-table {
  margin-left: auto;
  margin-right: auto;
  padding: 4px;
}

.percent-td {
  padding: 0 15px;
}

th {
  text-align: left;
}

.table-and-filters {
  display: flex;
  flex-direction: row;
}

.filter-group {
  display: flex;
  flex-direction: column;
  align-items: left;
}

.filter-group input {
  margin: 4px;
  margin-left: 8px;
}
</style>