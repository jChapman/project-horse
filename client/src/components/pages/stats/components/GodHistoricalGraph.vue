<script>
import { Line as LineChart } from 'vue-chartjs'

import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  CategoryScale,
  PointElement
} from 'chart.js'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  CategoryScale,
  PointElement
)

export default {
  components: {
    LineChart,
  },
  props: {
    god: {
        type: Object,
        required: true,
    },
    width: {
      type: Number,
      default: 400
    },
    height: {
      type: Number,
      default: 400
    },
  },
  data() {
    return {
      chartData: {
        labels: [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July'
        ],
        datasets: [
          {
            label: 'Data One',
            backgroundColor: '#f87979',
            data: [40, 39, 10, 40, 39, 80, 40]
          }
        ]
      },
      chartOptions: {
        responsive: true,
        maintainAspectRatio: false
      }
    }
  }
}
</script>

<template>
  <div class="stats-container">
  <LineChart
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