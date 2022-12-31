<script>
import AbilityTooltip from '../../abilities/AbilityTooltip.vue';

export default {
  components: {
    AbilityTooltip
  },
  data() {
    return {
      searchText: "",
      tagFilter: "",
      loading: true,
      allTags: [],
      abilities: [],
      filteredAbilities: [],
    };
  },
  methods: {
    async fetchAbilities() {
      const data = await fetch("../../data/abilities.json");
      this.abilities = await data.json();
      const res = await fetch(
        "https://double-edge-studios-llc.github.io/enabled_abilities.txt"
      );
      const text = await res.text();
      const enabledAbilities = text
        .split("\n")
        .filter((line) => !line.startsWith("#") || !line.startsWith("#"));
      this.abilities = this.abilities.filter(({ id }) =>
        enabledAbilities.includes(id)
      );
      this.allTags = Array.from(
        new Set(
          this.abilities.reduce((prev, curr) => prev.concat(curr.tags), [])
        )
      ).sort();
      this.loading = false;
      this.updateShownAbilities();
    },
    updateShownAbilities() {
      let filtered = this.abilities;
      if (this.tagFilter !== "") {
        filtered = filtered.filter(
          (a) =>
            a.tags.filter((tag) =>
              tag.toLowerCase().includes(this.tagFilter.toLowerCase())
            ).length > 0
        );
      }
      if (this.searchText !== "")
        filtered = filtered.filter((a) =>
          a.name.toLowerCase().includes(this.searchText.toLowerCase())
        );
      this.filteredAbilities = filtered;
    },
    setTagFilter(tag) {
      this.tagFilter = this.tagFilter === tag ? "" : tag;
    },
  },
  created() {
    this.fetchAbilities();
  },
  watch: {
    searchText: function () {
      this.updateShownAbilities();
    },
    tagFilter: function () {
      this.updateShownAbilities();
    },
  },
};
</script>

<template>
  <div class="container root-card-container">
    <div class="row my-4">
      <div class="col-xl-12">
        <div class="search-bar spell-search">
          <div class="search-input">
            <input
              type="text"
              name="search"
              placeholder="Search..."
              autocomplete="off"
              v-model="searchText"
            />
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="d-flex justify-content-center mb-3">
      <b-spinner label="Loading..."></b-spinner>
    </div>
    <div class="tag-container">
      <div
        v-for="tag in allTags"
        :key="tag"
        class="tag-button px-2 py-1 mx-2 my-1"
        :class="{ 'filter-selected': tagFilter == tag }"
        @click="setTagFilter(tag)"
      >
        {{ tag.split(/(?=[A-Z])/).join(" ") }}
      </div>
    </div>
    <div class="card-container">
      <div
        v-for="ability in filteredAbilities"
        :key="ability.id"
      >
      <AbilityTooltip :ability="ability"/>
    </div>
    </div>
  </div>
</template>

<style>
@media (min-width: 1200px) {
  .root-card-container.container {
    max-width: 1580px;
  }
}

.spell-search {
  display: block;
}
.filter-selected {
  box-shadow: 0 0 10px 0 var(--secondary-color);
}
.tag-container {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
}
.tag-button {
  text-transform: capitalize;
  background: #1b182f;
  user-select: none;
}
.card-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
}
</style>