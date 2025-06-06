<template>
  <footer
    v-if="$nav.currentLayout !== 'cover'"
    class="absolute bottom-0 right-0 p-2 text-sm opacity-50"
  >
    {{ $nav.currentPage }} / {{ $nav.total }}
  </footer>
</template>