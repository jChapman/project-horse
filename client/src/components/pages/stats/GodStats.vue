<template>
  <b-table
    :fields="fields"
    :items="gods"
    :busy="loading"
    responsive
    class="m-auto pb-5"
    style="max-width: 700px"
    show-empty
  >
    <template #empty>
      <div class="text-center m-5">
        <h3>No results found, check filters</h3>
      </div>
    </template>
    <template #table-busy>
      <div class="text-center m-5">
        <b-spinner class="align-middle p-4"></b-spinner>
      </div>
    </template>
    <template #cell(god)="data">
      <div class="text-left p-2">
        <GodImage :god="data.item.god" :height="25" class="mr-2" />
        {{ $t(`gods.${data.item.god}`) }}
      </div>
    </template>
    <template #cell(pick_rate)="data">
      <div class="percent-td">
        <div class="text-left">
          {{ percentage(data.item.pick_rate, 1) }}
        </div>
        <div class="percentage-holder">
          <PercentBar
            :max="maxPickRate"
            :value="data.item.pick_rate"
            class="mt-1 progress-bar"
            v-b-tooltip.hover
            :title="data.item.god_freq"
          ></PercentBar>
        </div>
      </div>
    </template>
    <template #cell(win_rate)="data">
      <div class="percent-td">
        <div class="text-left">
          {{ percentage(data.item.win_rate, 1) }}
        </div>
        <div class="percentage-holder">
          <PercentBar
            :max="maxWinRate"
            :value="data.item.win_rate"
            class="mt-1 progress-bar"
            v-b-tooltip.hover
            :title="data.item.god_freq"
          ></PercentBar>
        </div>
      </div>
    </template>
    <template #cell(top_four_rate)="data">
      <div class="percent-td">
        <div class="text-left">
          {{ percentage(data.item.top_four_rate, 1) }}
        </div>
        <div class="percentage-holder">
          <PercentBar
            :max="maxTopFourRate"
            :value="data.item.top_four_rate"
            class="mt-1 progress-bar"
            v-b-tooltip.hover
            :title="data.item.god_freq"
          ></PercentBar>
        </div>
      </div>
    </template>
    <template #cell(avg_place)="data">
      <div class="percent-td">
        <div class="text-left">
          {{ round(data.item.avg_place, 2) }}
        </div>
        <div class="percentage-holder">
          <PercentBar
            :max="maxAvgPlace"
            :value="data.item.avg_place"
            class="mt-1 progress-bar"
          ></PercentBar>
        </div>
      </div>
    </template>
  </b-table>
</template>

<script>
import PercentBar from "../../utility/PercentBar.vue";
import GodImage from "../games/components/GodImage.vue";
import { percentage, round } from "../../../filters/filters";

export default {
  components: {
    PercentBar,
    GodImage,
  },

  props: {
    gods: {
      type: Array,
      required: true,
    },
    loading: {
      type: Boolean,
      required: true
    },
  },

  data: () => ({
    fields: [],
    maxPickRate: 1,
    maxWinRate: 1,
    maxTopFourRate: 1,
    maxAvgPlace: 1,
  }),

  created() {
    this.$emit("created");

    this.fields = [
      {
        key: "god",
        label: this.$i18n.t("gods.god"),
        thClass: "table-head text-left",
        sortable: true,
      },
      {
        key: "pick_rate",
        label: this.$i18n.t("gods.pick_rate"),
        thClass: "table-head",
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
        key: "avg_place",
        label: this.$i18n.t("gods.avg_place"),
        thClass: "table-head",
        sortable: true,
      },
    ];
  },
  watch: {
    gods: function() {
      if (this.gods.length) {
        this.maxPickRate = Math.max(...this.gods.map(g => g.pick_rate))
        this.maxWinRate = Math.max(...this.gods.map(g => g.win_rate))
        this.maxTopFourRate = Math.max(...this.gods.map(g => g.top_four_rate))
        this.maxAvgPlace = Math.max(...this.gods.map(g => g.avg_place))
      }
      console.log(this.gods[0].top_four_rate)
    }
  },

  methods: {
    percentage,
    round,
  },
};
</script>

<style scoped>
.percentage-holder {
  margin: auto;
}

.percent-td {
  padding: 0 15px;
}
</style>