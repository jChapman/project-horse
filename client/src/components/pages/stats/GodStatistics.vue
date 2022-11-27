<script>
import GodImage from '../games/components/GodImage.vue'


export default {
  components: {
    GodImage
  },
  data: () => ({
    loading: true,
    godStats: [],
    // TODO copied from db/statistics.js, should be in a common place...
    timeFilters: ["Day", "Week", "Month"],
    activeTimeFilter: '',
    rankFilters: ["Herald", "Guardian", "Crusader", "Archon", "Legend", "Ancient", "Divine", "Immortal"],
    activeRankFilter: '',
    patchFilters: ["1.0", "1.5", "1.5b", "2.0", "2.0b", "2.0c", "2.5", "2.5b"],
    activePatchFilter: '',
    fields: [
      {
        key: "god",
        label: "God",
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
        key: "picks",
        label: "Total Picks",
        thClass: "table-head",
        sortable: true,
      },
    ],
  }),

  methods: {
    async loadGodStats() {
      this.godStats = [];
      this.loading = true;
      const filters = [this.activePatchFilter, this.activeTimeFilter, this.activeRankFilter].filter(f => f).join(',')
      fetch(`/api/stats/more/gods?filters=${filters}`).then(r => r.json()).then(gs => {
        this.godStats = gs.results;
        this.loading = false;
      }
      )
    },
    setDefaultFilters() {
      this.activePatchFilter = this.patchFilters[this.patchFilters.length - 1]
      this.activeRankFilter = this.rankFilters[this.rankFilters.length - 1]
    }
  },


  created() {
    this.setDefaultFilters();
  },
  watch: {
    activePatchFilter: function () { this.loadGodStats(); },
    activeRankFilter: function () { this.loadGodStats(); },
    activeTimeFilter: function () { this.loadGodStats(); },
  }
}
</script>

<template>
  <div class="container">
    <h1 class="page-title">God Statistics</h1>
    <div class="table-and-filters">
      <b-table :busy="loading" :fields="fields" :items="godStats" responsive style="max-width: 700px; margin-left: auto; margin-right: auto;" show-empty empty-text="No games found">
        <template #cell(god)="data">
          <div class="text-left p-2">
            <GodImage :god="data.item.god" :height="60" class="mr-2" />
            {{ $t(`gods.${data.item.god}`) }}
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
        <template #cell(picks)="data">
          <div>
            {{ data.item.picks }}
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

.filter-button-container {
  margin-left: 8px;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}

.filter-button {
  user-select: none;
  filter: saturate(0);
  padding: 4px;
  margin: 4px;
  color: #6548a0;
  background-color: var(--primary-color-dark);
  cursor: pointer;
}

.filter-button.selected {
  filter: saturate(1);
  filter: drop-shadow(0px 0px 6px rgba(0, 204, 255, .5));
}
</style>