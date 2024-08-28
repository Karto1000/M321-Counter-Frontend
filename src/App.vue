<script setup lang="ts">
import {onBeforeUnmount, onMounted, ref} from 'vue'

const hosts = [80]

const timer = ref()
const lastClicked = ref(0)
const counters = [ref(0)]

const onIncrement = async (index: number) => {
  counters.forEach(c => c.value += 1)

  lastClicked.value = Date.now()

  await fetch(
      `http://localhost:${hosts[index]}/increment`,
      {method: 'POST'}
  )
}

const getCounter = async (index: number): Promise<number> => {
  const response: Response = await fetch(
      `http://localhost:${hosts[index]}/count`
  )
  return Number.parseInt(await response.text())
}

onMounted(async () => {
  timer.value = setInterval(() => {
    if (Date.now() - lastClicked.value < 2000) return

    hosts.forEach(async (host, index) => {
      counters[index].value = await getCounter(index)
    })
  }, 2000)

  for (let i = 0; i < hosts.length; i++) {
    counters[i].value = await getCounter(i)
  }
})

onBeforeUnmount(() => {
  clearInterval(timer.value)
})

</script>

<template>
  <header>

  </header>

  <main>
    <div class="increments-container">
      <div class="increment-container" v-for="(counter, index) in counters">
        <button @click="onIncrement(index)">Increment</button>
        <p>Counter {{ counter }}</p>
      </div>
    </div>
  </main>
</template>

<style scoped>
.increments-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.increment-container {
  height: 32px;
  display: flex;
  gap: 16px;
  align-items: center;
}
</style>
