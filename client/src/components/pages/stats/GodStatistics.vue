<script>
import GodImage from '../games/components/GodImage.vue'


export default {
  components: {
    GodImage
  },
  data: () => ({
    loading: true,
    godStats: [],
    fields:[
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
      fetch('/api/stats/more/gods').then(r => r.json()).then(gs => {
        this.godStats = gs.results;
        this.loading = false;
      }
      )
    }
  },

  created() {
    this.loadGodStats();
  },
}
</script>

<template>
  <div>
  <b-table
    :fields="fields"
    :items="godStats"
    responsive
    class="m-auto"
    style="max-width: 700px"
  >
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
        {{data.item.picks}}
      </div>
    </template>
    </b-table>
  </div>
</template>

<style scoped>
.percent-td {
  padding: 0 15px;
}

th {
  text-align: left;
}
</style>