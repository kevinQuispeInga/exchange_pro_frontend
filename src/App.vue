<template>
  <router-view v-slot="{ Component }">
    <transition name="page" mode="out-in">
      <component :is="Component" />
    </transition>
  </router-view>
  <AIChatBot />
</template>

<script setup>
import AIChatBot from '@/components/AIChatBot.vue'
</script>
