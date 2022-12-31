<script>
import GodCard from '../../gods/GodCard.vue';

export default {
  components: {
    GodCard,
  },
  data: () => ({
    loading: true,
    gods: [],
    godsToShow: [],
    searchText: "",
    complexityFilter: "",
    unlockFilter: "",
  }),

  created() {
    this.loadAndFilterGods();
  },

  methods: {
    async loadAndFilterGods() {
      const godReq = fetch(`/data/gods.json`).then((res) => res.json())
      const filterReq = fetch('/api/gods').then(r => r.json()).then(gods => this.enabledGods = gods.filter(g => g.god_enabled).map(g => g.god_name));
      const [allKnownGods, godFilter] = await Promise.all([godReq, filterReq])
      this.loading = false;
      this.gods = allKnownGods.filter(g => godFilter.includes(g.id))
      this.updateShownGods();
    },

    setComplexityFilter(compStr) {
      this.complexityFilter = compStr;
    },
    setUnlockFilter(unlockStr) {
      this.unlockFilter = unlockStr;
    },

    updateShownGods() {
      let filtered = this.gods;
      if (this.complexityFilter !== "")
        filtered = filtered.filter(g => g.complexity === this.complexityFilter);
      if (this.searchText !== "")
        filtered = filtered.filter(g => g.name.toLowerCase().includes(this.searchText.toLowerCase()));
      if (this.unlockFilter !== "")
        filtered = filtered.filter(g => g.unlock === this.unlockFilter)
      this.godsToShow = filtered;
    },
  },
  watch: {
    searchText: function () {
      this.updateShownGods();
    },
    complexityFilter: function () {
      this.updateShownGods();
    },
    unlockFilter: function () {
      this.updateShownGods();
    },
  },
};
</script>

<template>
  <div class="container">
    <h1 class="page-title">{{ $t("gods.page_title") }}</h1>
    <div class="search-filter-container">
      <span class="title">Filter Gods</span>
      <div class="search-input">
        <input type="text" name="search" placeholder="Search..." autocomplete="off" v-model="searchText" />
      </div>
      <div>
        Complexity
        <div class="filter-button-container">
          <div v-for="c in ['easy', 'intermediate', 'advanced']" :key="c" class="filter-button"
            :class="{ selected: c === complexityFilter }" @click="setComplexityFilter(c === complexityFilter ? '' : c)">
            <img class="GodComplexity" :src="`/images/gods/god_complexity_${c}.png`" style="cursor: pointer">
          </div>
        </div>
      </div>
      <div>
        Unlock Method
        <div class="filter-button-container">
          <div v-for="unlock in Array.from(new Set(gods.map(g => g.unlock)))" :key="unlock" class="filter-button"
            :class="{ selected: unlock === unlockFilter }"
            @click="setUnlockFilter(unlock === unlockFilter ? '' : unlock)">
            <span>{{ unlock }}</span>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="d-flex justify-content-center mb-3">
      <b-spinner label="Loading..."></b-spinner>
    </div>
    <div class="gods-container">
      <div v-for="god of godsToShow" :key="god.id">
        <GodCard :god="god"/>
      </div>
    </div>
  </div>
</template>

<style>
@media (min-width: 1200px) {
  .container {
    max-width: 1580px;
  }
}

@media (max-width: 950px) {
  .search-filter-container {
    flex-direction: column;
    justify-content: center;
  }

  .search-filter-container .search-input {
    min-width: 300px;
  }
}

.search-filter-container {
  display: flex;

  justify-content: space-between;
  flex-wrap: wrap;
  align-items: center;
  padding: 10px;
  background: linear-gradient(45deg, var(--primary-color-dark), transparent);
  border: 1px solid var(--primary-color-light);

  font-size: 18px;
  font-weight: thin;
  color: #645b77;
}

.search-filter-container .title {
  font-size: 22px;
  text-transform: uppercase;
  font-weight: bold;
  color: #6548a0;
}

.search-filter-container>div {
  display: flex;
  align-items: center;
  margin: 8px;
}

.search-input {
  min-width: 500px;
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
  margin: 4px;
  color: #6548a0;
  cursor: pointer;
}

.filter-button.selected {
  filter: saturate(1);
  filter: drop-shadow(0px 0px 6px rgba(0, 204, 255, .5));
}

.filter-button img {
  width: 35px;
  height: 35px;
}

.filter-button span {
  text-transform: capitalize;
  background-color: var(--primary-color-dark);
  padding: 4px;
}

.gods-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
}

</style>