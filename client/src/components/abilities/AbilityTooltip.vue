
<template>
  <div class="ability-tooltip">
    <div class="ability-header">
      <img
        class="ability-icon"
        :src="`/images/ability_icons/${ability.icon}.png`"
      />
      <div class="ability-name">
        {{ ability.name }}
      </div>
    </div>
    <div style="display: flex" class="mt-2">
      <div class="categories">
        <div v-for="catStr in ability.categories" :key="catStr">
          {{ catStr }}
        </div>
      </div>
    </div>
    <div class="separator"></div>
    <div class="ability-description">
      {{ ability.description }}
    </div>
    <div class="values p-2">
      <div v-for="val in ability.values" :key="val">
        <span class="uppercase ability-value-desc">
          {{ val.split(":")[0] }}:
        </span>
        <span class="ability-value">{{ val.split(":")[1] }}</span>
      </div>
      <div
        style="
          display: flex;
          flex-wrap: wrap;
          align-items: center;
          margin-top: 8px;
        "
      >
        <div v-if="ability.cooldowns.length > 0" class="icon-and-values pr-4">
          <div class="cooldown-icon"></div>
          <span class="ml-2">
            {{
              ability.cooldowns
                .slice(0, Math.min(ability.cooldowns.length, 3))
                .join(" / ")
            }}
          </span>
        </div>
        <div v-if="ability.manaCost.length" class="icon-and-values">
          <div style="display: flex">
            <div class="mana-cost-icon"></div>
            <span class="ml-2">
              {{
                ability.manaCost
                  .slice(0, Math.min(ability.manaCost.length, 3))
                  .join(" / ")
              }}
            </span>
          </div>
        </div>
      </div>
    </div>
    <div class="sink">
      <div class="super">
        <span style="color: rgb(99, 117, 255)">Super: </span>
        <span class="">
          {{ ability.superUpgrade.split("Super: ")[1] }}
        </span>
      </div>
      <div class="gaben">
        <span style="color: rgb(254, 116, 0)">Gaben: </span>
        <span>{{ ability.gabenUpgrade.split("Gaben: ")[1] }}</span>
      </div>
      <div v-if="ability.differences" class="differences">
        <span style="color: #8e8676">Differences from Dota: </span>
        {{ ability.differences }}
      </div>
    </div>
  </div>
</template>

<script>
/*
interface Ability {
  name: string;
  id: string;
  categories: Array<string>;
  description: string;
  values: Array<string>;
  cooldowns: Array<number>;
  manaCost: Array<number>;
  superUpgrade: string;
  gabenUpgrade: string;
  isUlt: boolean;
  tags: Array<string>;
  icon: string;
}
*/

export default {
  props: {
    ability: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style scoped>
.ability-tooltip {
  width: 285px;
  background-color: #1b1331;
  margin: 8px;
  border: 1px solid #2d2954;
  font-size: 14px;
  line-height: 1.35;

  display: flex;
  flex-direction: column;
}
.ability-icon {
  height: 50px;
  width: 50px;
  margin: 4px;
  box-shadow: 0px 0px 8px #000;
}
.ability-header {
  background-color: #231b40;
  width: 100%;
  display: flex;
  align-items: center;
}
.ability-name {
  margin-left: 8px;
  font-size: 20px;
  color: #e1e1e1;
  font-family: Reaver, serif;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 1px;
}
.categories {
  color: #6548a0;
  margin-left: 8px;
}
.separator {
  height: 1px;
  background-color: #383167;
  margin: 8px;
}
.ability-description {
  color: #847f90;
  margin: 0px 8px;
}
.ability-value-desc {
  color: #6548a0;
}
.ability-value {
  color: #e1e1e1;
}
.cooldown-icon {
  background-image: url("https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/icons/cooldown.png");
  width: 16px;
  height: 16px;
  border-radius: 3px;
  background-size: cover;
}
.mana-cost-icon {
  width: 16px;
  height: 16px;
  border-radius: 3px;
  background: linear-gradient(#00a4db, #007196);
}
.icon-and-values {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding-top: 4px;
}
.sink {
  margin-top: auto;
}
.super,
.gaben {
  color: #9a88bd;
  padding: 12px;
  margin-top: 12px;
  font-size: 15px;
}
.super {
  background: linear-gradient(
    rgba(104, 104, 193, 0.1),
    rgba(31, 31, 151, 0.16)
  );
  box-shadow: inset 0px 0px 15px -5px rgba(98, 116, 255, 0.5);
}
.gaben {
  box-shadow: inset 0px 0px 15px -5px rgba(156, 104, 74, 0.5);
  background: linear-gradient(rgba(59, 41, 34, 0.8), rgba(0, 0, 0, 0));
}
.differences {
  background: linear-gradient(rgb(43, 36, 61), rgba(38, 30, 58, 1));
  color: #67696a;
  padding: 8px;
  margin-top: 12px;
}
</style>