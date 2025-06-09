export const createF2Theme = (isDark: boolean = false) => {
    const themeColors = getThemeColors(isDark);
    const themeShadows = getThemeShadows(isDark);

    return {
        ...f2Theme,
        colors: {
            ...f2Theme.colors,
            // Map semantic tokens to current theme
            background: themeColors.background.primary,
            backgroundSecondary: themeColors.background.secondary,
            backgroundTertiary: themeColors.background.tertiary,

            text: themeColors.text.primary,
            textSecondary: themeColors.text.secondary,
            textMuted: themeColors.text.tertiary,

            border: themeColors.border.primary,
            borderSecondary: themeColors.border.secondary,

            // Primary brand colors
            primaryDefault: themeColors.brand.primary,
            primaryHover: themeColors.brand.primaryHover,
            primaryActive: themeColors.brand.primaryActive,
            primaryMuted: themeColors.brand.primaryMuted,

            // Secondary brand colors
            secondaryDefault: themeColors.brand.secondary,
            secondaryHover: themeColors.brand.secondaryHover,
            secondaryActive: themeColors.brand.secondaryActive,
            secondaryMuted: themeColors.brand.secondaryMuted,

            // State colors
            success: themeColors.state.success,
            successMuted: themeColors.state.successMuted,
            warning: themeColors.state.warning,
            warningMuted: themeColors.state.warningMuted,
            error: themeColors.state.error,
            errorMuted: themeColors.state.errorMuted,
            info: themeColors.state.info,
            infoMuted: themeColors.state.infoMuted,
        },
        shadows: themeShadows,
    };
};

// Helper function to get theme colors based on current theme
export const getThemeColors = (isDark: boolean) => {
    return isDark ? f2Theme.dark.colors : f2Theme.light.colors;
};

// Helper function to get shadows based on current theme
export const getThemeShadows = (isDark: boolean) => {
    return isDark ? f2Theme.shadows.dark : f2Theme.shadows.light;
};

export const f2Theme = {
    colors: {
        // Primary - Teal
        primary: {
            50: '#f0fdfa',
            100: '#ccfbf1',
            200: '#99f6e4',
            300: '#5eead4',
            400: '#2dd4bf',
            500: '#14b8a6',
            600: '#0d9488',
            700: '#0f766e',
            800: '#115e59',
            900: '#134e4a',
            950: '#042f2e',
        },

        // Secondary - Amber
        secondary: {
            50: '#fffbeb',
            100: '#fef3c7',
            200: '#fde68a',
            300: '#fcd34d',
            400: '#fbbf24',
            500: '#f59e0b',
            600: '#d97706',
            700: '#b45309',
            800: '#92400e',
            900: '#78350f',
            950: '#451a03',
        },

        // Neutrals - Slate
        neutral: {
            50: '#f8fafc',
            100: '#f1f5f9',
            200: '#e2e8f0',
            300: '#cbd5e1',
            400: '#94a3b8',
            500: '#64748b',
            600: '#475569',
            700: '#334155',
            800: '#1e293b',
            900: '#0f172a',
            950: '#020617',
        },

        // Success - Emerald
        success: {
            50: '#ecfdf5',
            100: '#d1fae5',
            200: '#a7f3d0',
            300: '#6ee7b7',
            400: '#34d399',
            500: '#10b981',
            600: '#059669',
            700: '#047857',
            800: '#065f46',
            900: '#064e3b',
            950: '#022c22',
        },

        // Warning - Orange
        warning: {
            50: '#fff7ed',
            100: '#ffedd5',
            200: '#fed7aa',
            300: '#fdba74',
            400: '#fb923c',
            500: '#f97316',
            600: '#ea580c',
            700: '#c2410c',
            800: '#9a3412',
            900: '#7c2d12',
            950: '#431407',
        },

        // Error - Red
        error: {
            50: '#fef2f2',
            100: '#fee2e2',
            200: '#fecaca',
            300: '#fca5a5',
            400: '#f87171',
            500: '#ef4444',
            600: '#dc2626',
            700: '#b91c1c',
            800: '#991b1b',
            900: '#7f1d1d',
            950: '#450a0a',
        },

        // Info - Sky
        info: {
            50: '#f0f9ff',
            100: '#e0f2fe',
            200: '#bae6fd',
            300: '#7dd3fc',
            400: '#38bdf8',
            500: '#0ea5e9',
            600: '#0284c7',
            700: '#0369a1',
            800: '#075985',
            900: '#0c4a6e',
            950: '#082f49',
        },
    },

    // Light Theme Semantic Tokens
    light: {
        colors: {
            // Backgrounds
            background: {
                primary: '#ffffff',
                secondary: '#f8fafc',
                tertiary: '#f1f5f9',
                elevated: '#ffffff',
                overlay: 'rgba(15, 23, 42, 0.4)',
            },

            // Text
            text: {
                primary: '#0f172a',
                secondary: '#334155',
                tertiary: '#64748b',
                muted: '#94a3b8',
                inverse: '#ffffff',
                disabled: '#cbd5e1',
            },

            // Borders
            border: {
                primary: '#e2e8f0',
                secondary: '#cbd5e1',
                focus: '#0d9488',
                error: '#ef4444',
                success: '#10b981',
                warning: '#f97316',
            },

            // Brand colors
            brand: {
                primary: '#0d9488',
                primaryHover: '#0f766e',
                primaryActive: '#115e59',
                primaryMuted: '#f0fdfa',
                secondary: '#f59e0b',
                secondaryHover: '#d97706',
                secondaryActive: '#b45309',
                secondaryMuted: '#fffbeb',
            },

            // State colors
            state: {
                success: '#10b981',
                successMuted: '#ecfdf5',
                warning: '#f97316',
                warningMuted: '#fff7ed',
                error: '#ef4444',
                errorMuted: '#fef2f2',
                info: '#0ea5e9',
                infoMuted: '#f0f9ff',
            },
        },
    },

    // Dark Theme Semantic Tokens
    dark: {
        colors: {
            // Backgrounds
            background: {
                primary: '#0f172a',
                secondary: '#1e293b',
                tertiary: '#334155',
                elevated: '#1e293b',
                overlay: 'rgba(15, 23, 42, 0.8)',
            },

            // Text
            text: {
                primary: '#f8fafc',
                secondary: '#e2e8f0',
                tertiary: '#cbd5e1',
                muted: '#94a3b8',
                inverse: '#0f172a',
                disabled: '#475569',
            },

            // Borders
            border: {
                primary: '#334155',
                secondary: '#475569',
                focus: '#14b8a6',
                error: '#f87171',
                success: '#34d399',
                warning: '#fb923c',
            },

            // Brand colors (adjusted for dark theme)
            brand: {
                primary: '#14b8a6',
                primaryHover: '#2dd4bf',
                primaryActive: '#5eead4',
                primaryMuted: '#042f2e',
                secondary: '#fbbf24',
                secondaryHover: '#fcd34d',
                secondaryActive: '#fde68a',
                secondaryMuted: '#451a03',
            },

            // State colors (adjusted for dark theme)
            state: {
                success: '#34d399',
                successMuted: '#022c22',
                warning: '#fb923c',
                warningMuted: '#431407',
                error: '#f87171',
                errorMuted: '#450a0a',
                info: '#38bdf8',
                infoMuted: '#082f49',
            },
        },
    },

    // Typography (works for both themes)
    fonts: {
        heading: 'Inter',
        body: 'Inter',
        mono: 'JetBrains Mono',
    },

    fontSizes: {
        xs: 12,
        sm: 14,
        md: 16,
        lg: 18,
        xl: 20,
        '2xl': 24,
        '3xl': 30,
        '4xl': 36,
        '5xl': 48,
        '6xl': 60,
    },

    // Spacing
    space: {
        px: 1,
        0.5: 2,
        1: 4,
        1.5: 6,
        2: 8,
        2.5: 10,
        3: 12,
        3.5: 14,
        4: 16,
        5: 20,
        6: 24,
        7: 28,
        8: 32,
        9: 36,
        10: 40,
        12: 48,
        16: 64,
        20: 80,
        24: 96,
        32: 128,
    },

    // Border radius
    radii: {
        none: 0,
        sm: 4,
        md: 8,
        lg: 12,
        xl: 16,
        '2xl': 24,
        '3xl': 32,
        full: 9999,
    },

    // Shadows (adjusted for theme)
    shadows: {
        light: {
            sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
            md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
            lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
            xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
        },
        dark: {
            sm: '0 1px 2px 0 rgba(0, 0, 0, 0.3)',
            md: '0 4px 6px -1px rgba(0, 0, 0, 0.4), 0 2px 4px -1px rgba(0, 0, 0, 0.3)',
            lg: '0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -2px rgba(0, 0, 0, 0.3)',
            xl: '0 20px 25px -5px rgba(0, 0, 0, 0.4), 0 10px 10px -5px rgba(0, 0, 0, 0.2)',
        },
    },
};