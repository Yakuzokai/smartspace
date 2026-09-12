<template>
  <div class="min-h-[60vh] flex flex-col items-center justify-center text-center px-4 py-16 space-y-4">
    <div class="w-16 h-16 rounded-2xl bg-cream border border-light-border shadow-subtle flex items-center justify-center text-2xl text-forest font-mono font-bold">
      404
    </div>
    <div class="space-y-1">
      <h1 class="font-display font-bold text-2xl text-forest">Page Not Found</h1>
      <p class="text-xs text-muted-gray max-w-sm">The spatial coordinates or page you requested does not exist.</p>
    </div>
    <router-link
      to="/"
      class="px-5 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all"
    >
      Return to Home
    </router-link>
  </div>
</template>
