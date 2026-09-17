/**
 * NOT a drop-in replacement for a Laravel-generated tailwind.config.js —
 * merge the `theme.extend.colors` block below into yours (or use this
 * wholesale if you scaffolded the admin panel with `laravel new --livewire`
 * and haven't customized it yet). See the README's admin panel setup.
 */
module.exports = {
  content: [
    './resources/**/*.blade.php',
    './resources/**/*.js',
    './app/Livewire/**/*.php',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#F5F5DC', // beige — canvas
        secondary: '#F4A460', // sandy brown — secondary emphasis
        accent: '#E35336', // terracotta — the one primary action per screen
        deep: '#A0522D', // sienna — headings/high-emphasis text
        surface: '#FFFFFF',
        'surface-alt': '#FAF9F0',
        muted: '#8A7863',
        border: '#E6E0C8',
        success: '#4C8B5A',
        warning: '#D8A73D',
        'severity-low': '#7C9473',
        'severity-moderate': '#D8A73D',
        'severity-high': '#E07B39',
        'severity-critical': '#C0392B',
      },
      borderRadius: {
        card: '12px',
      },
      transitionDuration: {
        DEFAULT: '200ms',
      },
    },
  },
  plugins: [],
};
