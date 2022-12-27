<script>
import { Line as LineChart } from "vue-chartjs";

import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  CategoryScale,
  PointElement,
} from "chart.js";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  CategoryScale,
  PointElement
);

export default {
  components: {
    LineChart,
  },
  props: {
    god: {
      type: Object,
      required: true,
    },
    ranks: {
      type: Array,
      required: true,
    },
    width: {
      type: Number,
      default: 400,
    },
    height: {
      type: Number,
      default: 400,
    },
  },
  methods: {
    loadDailyStats() {
        this.loaded = false;
      fetch(`/api/stats/godDaily?god=${this.god.god}&ranks=${this.ranks.join(',')}`)
        .then(res => res.json())
        .then(stats => {
            console.log(stats);
            this.chartData.labels = stats.map(ds => ds.day);
            this.chartData.datasets = [
                {
                    label: "Pick Rate",
                    backgroundColor: "#FF0000",
                    data: stats.map(ds => ds.pick_rate)
                },
                {
                    label: "Win Rate",
                    backgroundColor: "#00FF00",
                    data: stats.map(ds => ds.win_rate)
                },
                {
                    label: "Top 4 Rate",
                    backgroundColor: "#0000FF",
                    data: stats.map(ds => ds.top_four_rate)
                },
            ]
            this.loaded = true;
        });
    }
  },
  data: () => ({
    loaded: false,
    chartData: {
      labels: ["January", "February", "March", "April", "May", "June", "July"],
      datasets: [
        {
          label: "Data One",
          backgroundColor: "#f87979",
          data: [40, 39, 10, 40, 39, 80, 40],
        },
      ],
    },
    chartOptions: {
      responsive: true,
      maintainAspectRatio: false,
    },
  }),
  created() {
    this.loadDailyStats();
  },
};
</script>

<template>
  <div class="stats-container">
    <LineChart
      v-if="loaded"
      :data="chartData"
      :options="chartOptions"
      :width="width"
      :height="height"
    />
  </div>
</template>

<style scoped>
.stats-container {
  display: flex;
  background: var(--primary-color);
}

.bar-container {
  height: 50px;
  width: 15px;
  margin-left: 6px;
}

.bar {
  height: 100%;
  width: 100%;
  display: flex;
}

.bar-inner {
  background-color: var(--primary-color);
  width: 100%;
  align-self: flex-end;
}

.bar-label {
  text-align: center;
  font-size: 10px;
}
</style>