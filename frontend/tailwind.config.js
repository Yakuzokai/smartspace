/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Authoritative Palette Tokens
        forest: {
          DEFAULT: '#173F35',
          hover: '#0F2F28',
          dark: '#0F2F28',
        },
        'dark-green': '#0F2F28',
        'warm-beige': {
          DEFAULT: '#D8B98A',
          hover: '#c9a773',
          light: '#f5ecdf',
        },
        cream: {
          DEFAULT: '#F7F4EE',
          dark: '#ece6da',
        },
        'off-white': '#FCFCFA',
        charcoal: {
          DEFAULT: '#252A27',
          light: '#373e3a',
        },
        'muted-gray': {
          DEFAULT: '#737A76',
          light: '#9da3a0',
        },
        'light-border': '#E5E3DD',

        // Brand Scale mapped to Deep Forest Green and Dark Green
        brand: {
          50: '#F7F4EE',
          100: '#ece6da',
          200: '#D8B98A',
          300: '#b89868',
          400: '#245a4c',
          500: '#173F35', // Deep Forest Green (Primary Brand)
          600: '#173F35',
          700: '#0F2F28', // Dark Green (Hero & Primary Hover)
          800: '#0b231e',
          900: '#071613',
          950: '#030b09',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        display: ['Outfit', 'Inter', 'sans-serif'],
        serif: ['"Playfair Display"', 'Georgia', 'serif'],
      },
      boxShadow: {
        'glow': '0 0 25px -5px rgba(23, 63, 53, 0.25)',
        'glow-lg': '0 0 35px -5px rgba(23, 63, 53, 0.35)',
        'glow-warm': '0 0 25px -5px rgba(216, 185, 138, 0.35)',
        'subtle': '0 1px 3px 0 rgba(37, 42, 39, 0.05)',
        'card': '0 2px 10px -2px rgba(37, 42, 39, 0.06), 0 1px 4px -1px rgba(37, 42, 39, 0.03)',
        'card-hover': '0 12px 28px -6px rgba(37, 42, 39, 0.09), 0 4px 12px -2px rgba(37, 42, 39, 0.04)',
      },
    },
  },
  plugins: [],
}
