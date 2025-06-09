const gluestackPlugin = require("@gluestack-ui/nativewind-utils/tailwind-plugin");

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: false,
  content: [
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
    "./screens/**/*.{js,jsx,ts,tsx}",
  ],
  presets: [require("nativewind/preset")],
  safelist: ["gap-x-2", "gap-y-6", "pl-4", "flex-wrap", "mb-12", "basis-[10%]"],
  theme: {
    screens: {
      base: "0",
      xs: "400px",
      sm: "480px",
      md: "768px",
      lg: "992px",
      xl: "1280px",
    },
    extend: {
      colors: {
        // Primary - Teal
        primary: {
          50: "var(--color-primary-50)",
          100: "var(--color-primary-100)",
          200: "var(--color-primary-200)",
          300: "var(--color-primary-300)",
          400: "var(--color-primary-400)",
          500: "var(--color-primary-500)",
          600: "var(--color-primary-600)",
          700: "var(--color-primary-700)",
          800: "var(--color-primary-800)",
          900: "var(--color-primary-900)",
          950: "var(--color-primary-950)",
        },

        // Secondary - Amber
        secondary: {
          50: "var(--color-secondary-50)",
          100: "var(--color-secondary-100)",
          200: "var(--color-secondary-200)",
          300: "var(--color-secondary-300)",
          400: "var(--color-secondary-400)",
          500: "var(--color-secondary-500)",
          600: "var(--color-secondary-600)",
          700: "var(--color-secondary-700)",
          800: "var(--color-secondary-800)",
          900: "var(--color-secondary-900)",
          950: "var(--color-secondary-950)",
        },

        // Neutral - Slate
        neutral: {
          50: "var(--color-neutral-50)",
          100: "var(--color-neutral-100)",
          200: "var(--color-neutral-200)",
          300: "var(--color-neutral-300)",
          400: "var(--color-neutral-400)",
          500: "var(--color-neutral-500)",
          600: "var(--color-neutral-600)",
          700: "var(--color-neutral-700)",
          800: "var(--color-neutral-800)",
          900: "var(--color-neutral-900)",
          950: "var(--color-neutral-950)",
        },

        // Success - Emerald
        success: {
          50: "var(--color-success-50)",
          100: "var(--color-success-100)",
          200: "var(--color-success-200)",
          300: "var(--color-success-300)",
          400: "var(--color-success-400)",
          500: "var(--color-success-500)",
          600: "var(--color-success-600)",
          700: "var(--color-success-700)",
          800: "var(--color-success-800)",
          900: "var(--color-success-900)",
          950: "var(--color-success-950)",
        },

        // Warning - Orange
        warning: {
          50: "var(--color-warning-50)",
          100: "var(--color-warning-100)",
          200: "var(--color-warning-200)",
          300: "var(--color-warning-300)",
          400: "var(--color-warning-400)",
          500: "var(--color-warning-500)",
          600: "var(--color-warning-600)",
          700: "var(--color-warning-700)",
          800: "var(--color-warning-800)",
          900: "var(--color-warning-900)",
          950: "var(--color-warning-950)",
        },

        // Error - Red
        error: {
          50: "var(--color-error-50)",
          100: "var(--color-error-100)",
          200: "var(--color-error-200)",
          300: "var(--color-error-300)",
          400: "var(--color-error-400)",
          500: "var(--color-error-500)",
          600: "var(--color-error-600)",
          700: "var(--color-error-700)",
          800: "var(--color-error-800)",
          900: "var(--color-error-900)",
          950: "var(--color-error-950)",
        },

        // Info - Sky
        info: {
          50: "var(--color-info-50)",
          100: "var(--color-info-100)",
          200: "var(--color-info-200)",
          300: "var(--color-info-300)",
          400: "var(--color-info-400)",
          500: "var(--color-info-500)",
          600: "var(--color-info-600)",
          700: "var(--color-info-700)",
          800: "var(--color-info-800)",
          900: "var(--color-info-900)",
          950: "var(--color-info-950)",
        },

        // Semantic background colors
        background: {
          primary: "var(--color-background-primary)",
          secondary: "var(--color-background-secondary)",
          tertiary: "var(--color-background-tertiary)",
          elevated: "var(--color-background-elevated)",
          muted: "var(--color-background-muted)",
        },

        // Semantic text colors
        text: {
          primary: "var(--color-text-primary)",
          secondary: "var(--color-text-secondary)",
          tertiary: "var(--color-text-tertiary)",
          muted: "var(--color-text-muted)",
          inverse: "var(--color-text-inverse)",
          disabled: "var(--color-text-disabled)",
        },

        // Semantic border colors
        border: {
          primary: "var(--color-border-primary)",
          secondary: "var(--color-border-secondary)",
          focus: "var(--color-border-focus)",
          muted: "var(--color-border-muted)",
        },

        // Brand semantic colors
        brand: {
          primary: "var(--color-brand-primary)",
          "primary-hover": "var(--color-brand-primary-hover)",
          "primary-active": "var(--color-brand-primary-active)",
          "primary-muted": "var(--color-brand-primary-muted)",
          secondary: "var(--color-brand-secondary)",
          "secondary-hover": "var(--color-brand-secondary-hover)",
          "secondary-active": "var(--color-brand-secondary-active)",
          "secondary-muted": "var(--color-brand-secondary-muted)",
        },
      },

      fontFamily: {
        heading: ["Inter", "system-ui", "-apple-system", "sans-serif"],
        body: ["Inter", "system-ui", "-apple-system", "sans-serif"],
        mono: ["JetBrains Mono", "Fira Code", "Consolas", "monospace"],
      },

      fontSize: {
        "2xs": ["10px", { lineHeight: "14px" }],
        xs: ["12px", { lineHeight: "16px" }],
        sm: ["14px", { lineHeight: "20px" }],
        base: ["16px", { lineHeight: "24px" }],
        lg: ["18px", { lineHeight: "28px" }],
        xl: ["20px", { lineHeight: "28px" }],
        "2xl": ["24px", { lineHeight: "32px" }],
        "3xl": ["30px", { lineHeight: "36px" }],
        "4xl": ["36px", { lineHeight: "40px" }],
        "5xl": ["48px", { lineHeight: "1" }],
        "6xl": ["60px", { lineHeight: "1" }],
      },

      fontWeight: {
        hairline: "100",
        extrablack: "950",
      },

      spacing: {
        0.5: "2px",
        1.5: "6px",
        2.5: "10px",
        3.5: "14px",
      },

      borderRadius: {
        "2xl": "1rem",
        "3xl": "1.5rem",
      },

      boxShadow: {
        // Hard shadows
        "hard-1":
          "0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)",
        "hard-2":
          "0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23)",
        "hard-3":
          "0 10px 20px rgba(0, 0, 0, 0.19), 0 6px 6px rgba(0, 0, 0, 0.23)",
        "hard-4":
          "0 14px 28px rgba(0, 0, 0, 0.25), 0 10px 10px rgba(0, 0, 0, 0.22)",
        "hard-5":
          "0 19px 38px rgba(0, 0, 0, 0.30), 0 15px 12px rgba(0, 0, 0, 0.22)",

        // Soft shadows
        "soft-1": "0 1px 3px rgba(0, 0, 0, 0.05), 0 1px 2px rgba(0, 0, 0, 0.1)",
        "soft-2": "0 3px 6px rgba(0, 0, 0, 0.05), 0 3px 6px rgba(0, 0, 0, 0.1)",
        "soft-3":
          "0 10px 20px rgba(0, 0, 0, 0.05), 0 6px 6px rgba(0, 0, 0, 0.1)",
        "soft-4":
          "0 14px 28px rgba(0, 0, 0, 0.05), 0 10px 10px rgba(0, 0, 0, 0.1)",
      },
    },
  },
  plugins: [gluestackPlugin],
};
