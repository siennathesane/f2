"use client";
import { vars } from "nativewind";

export const config = {
  light: vars({
    // Primary - Teal (Hex values for light mode)
    "--color-primary-50": "#f0fdfa", // #f0fdfa
    "--color-primary-100": "#ccfbf1", // #ccfbf1
    "--color-primary-200": "#99f6e4", // #99f6e4
    "--color-primary-300": "#5eead4", // #5eead4
    "--color-primary-400": "#2dd4bf", // #2dd4bf
    "--color-primary-500": "#14b8a6", // #14b8a6
    "--color-primary-600": "#0d9488", // #0d9488
    "--color-primary-700": "#0f766e", // #0f766e
    "--color-primary-800": "#115e59", // #115e59
    "--color-primary-900": "#134e4a", // #134e4a
    "--color-primary-950": "#042f2e", // #042f2e

    // Secondary - Amber (Hex values for light mode)
    "--color-secondary-50": "#fffbeb", // #fffbeb
    "--color-secondary-100": "#fef3c7", // #fef3c7
    "--color-secondary-200": "#fde68a", // #fde68a
    "--color-secondary-300": "#fcd34d", // #fcd34d
    "--color-secondary-400": "#fbbf24", // #fbbf24
    "--color-secondary-500": "#f59e0b", // #f59e0b
    "--color-secondary-600": "#d97706", // #d97706
    "--color-secondary-700": "#b45309", // #b45309
    "--color-secondary-800": "#92400e", // #92400e
    "--color-secondary-900": "#78350f", // #78350f
    "--color-secondary-950": "#451a03", // #451a03

    // Neutral - Slate (Hex values for light mode)
    "--color-neutral-50": "#f8fafc", // #f8fafc
    "--color-neutral-100": "#f1f5f9", // #f1f5f9
    "--color-neutral-200": "#e2e8f0", // #e2e8f0
    "--color-neutral-300": "#cbd5e1", // #cbd5e1
    "--color-neutral-400": "#94a3b8", // #94a3b8
    "--color-neutral-500": "#64748b", // #64748b
    "--color-neutral-600": "#475569", // #475569
    "--color-neutral-700": "#334155", // #334155
    "--color-neutral-800": "#1e293b", // #1e293b
    "--color-neutral-900": "#0f172a", // #0f172a
    "--color-neutral-950": "#020617", // #020617

    // Success - Emerald
    "--color-success-50": "#ecfdf5", // #ecfdf5
    "--color-success-100": "#d1fae5", // #d1fae5
    "--color-success-200": "#a7f3d0", // #a7f3d0
    "--color-success-300": "#6ee7b7", // #6ee7b7
    "--color-success-400": "#34d399", // #34d399
    "--color-success-500": "#10b981", // #10b981
    "--color-success-600": "#059669", // #059669
    "--color-success-700": "#047857", // #047857
    "--color-success-800": "#065f46", // #065f46
    "--color-success-900": "#064e3b", // #064e3b
    "--color-success-950": "#022c22", // #022c22

    // Warning - Orange
    "--color-warning-50": "#fff7ed", // #fff7ed
    "--color-warning-100": "#ffedd5", // #ffedd5
    "--color-warning-200": "#fed7aa", // #fed7aa
    "--color-warning-300": "#fdba74", // #fdba74
    "--color-warning-400": "#fb923c", // #fb923c
    "--color-warning-500": "#f97316", // #f97316
    "--color-warning-600": "#ea580c", // #ea580c
    "--color-warning-700": "#c2410c", // #c2410c
    "--color-warning-800": "#9a3412", // #9a3412
    "--color-warning-900": "#7c2d12", // #7c2d12
    "--color-warning-950": "#431407", // #431407

    // Error - Red
    "--color-error-50": "#fef2f2", // #fef2f2
    "--color-error-100": "#fee2e2", // #fee2e2
    "--color-error-200": "#fecaca", // #fecaca
    "--color-error-300": "#fca5a5", // #fca5a5
    "--color-error-400": "#f87171", // #f87171
    "--color-error-500": "#ef4444", // #ef4444
    "--color-error-600": "#dc2626", // #dc2626
    "--color-error-700": "#b91c1c", // #b91c1c
    "--color-error-800": "#991b1b", // #991b1b
    "--color-error-900": "#7f1d1d", // #7f1d1d
    "--color-error-950": "#450a0a", // #450a0a

    // Info - Sky
    "--color-info-50": "#f0f9ff", // #f0f9ff
    "--color-info-100": "#e0f2fe", // #e0f2fe
    "--color-info-200": "#bae6fd", // #bae6fd
    "--color-info-300": "#7dd3fc", // #7dd3fc
    "--color-info-400": "#38bdf8", // #38bdf8
    "--color-info-500": "#0ea5e9", // #0ea5e9
    "--color-info-600": "#0284c7", // #0284c7
    "--color-info-700": "#0369a1", // #0369a1
    "--color-info-800": "#075985", // #075985
    "--color-info-900": "#0c4a6e", // #0c4a6e
    "--color-info-950": "#082f49", // #082f49

    // Semantic tokens for light mode
    "--color-background-primary": "#ffffff", // white
    "--color-background-secondary": "#f8fafc", // neutral-50
    "--color-background-tertiary": "#f1f5f9", // neutral-100
    "--color-background-elevated": "#ffffff", // white
    "--color-background-muted": "#f1f5f9", // neutral-100

    "--color-text-primary": "#0f172a", // neutral-900
    "--color-text-secondary": "#334155", // neutral-700
    "--color-text-tertiary": "#64748b", // neutral-500
    "--color-text-muted": "#94a3b8", // neutral-400
    "--color-text-inverse": "#ffffff", // white
    "--color-text-disabled": "#cbd5e1", // neutral-300

    "--color-border-primary": "#e2e8f0", // neutral-200
    "--color-border-secondary": "#cbd5e1", // neutral-300
    "--color-border-focus": "#0d9488", // primary-600
    "--color-border-muted": "#f1f5f9", // neutral-100

    // Brand semantic tokens (light mode)
    "--color-brand-primary": "#0d9488", // primary-600
    "--color-brand-primary-hover": "#0f766e", // primary-700
    "--color-brand-primary-active": "#115e59", // primary-800
    "--color-brand-primary-muted": "#f0fdfa", // primary-50

    "--color-brand-secondary": "#f59e0b", // secondary-500
    "--color-brand-secondary-hover": "#d97706", // secondary-600
    "--color-brand-secondary-active": "#b45309", // secondary-700
    "--color-brand-secondary-muted": "#fffbeb", // secondary-50
  }),

  dark: vars({
    // Primary - Teal (same hex values, but semantic tokens will change)
    "--color-primary-50": "#f0fdfa",
    "--color-primary-100": "#ccfbf1",
    "--color-primary-200": "#99f6e4",
    "--color-primary-300": "#5eead4",
    "--color-primary-400": "#2dd4bf",
    "--color-primary-500": "#14b8a6",
    "--color-primary-600": "#0d9488",
    "--color-primary-700": "#0f766e",
    "--color-primary-800": "#115e59",
    "--color-primary-900": "#134e4a",
    "--color-primary-950": "#042f2e",

    // Secondary - Amber (same hex values)
    "--color-secondary-50": "#fffbeb",
    "--color-secondary-100": "#fef3c7",
    "--color-secondary-200": "#fde68a",
    "--color-secondary-300": "#fcd34d",
    "--color-secondary-400": "#fbbf24",
    "--color-secondary-500": "#f59e0b",
    "--color-secondary-600": "#d97706",
    "--color-secondary-700": "#b45309",
    "--color-secondary-800": "#92400e",
    "--color-secondary-900": "#78350f",
    "--color-secondary-950": "#451a03",

    // Neutral - Slate (same hex values)
    "--color-neutral-50": "#f8fafc",
    "--color-neutral-100": "#f1f5f9",
    "--color-neutral-200": "#e2e8f0",
    "--color-neutral-300": "#cbd5e1",
    "--color-neutral-400": "#94a3b8",
    "--color-neutral-500": "#64748b",
    "--color-neutral-600": "#475569",
    "--color-neutral-700": "#334155",
    "--color-neutral-800": "#1e293b",
    "--color-neutral-900": "#0f172a",
    "--color-neutral-950": "#020617",

    // Success - Emerald (same hex values)
    "--color-success-50": "#ecfdf5",
    "--color-success-100": "#d1fae5",
    "--color-success-200": "#a7f3d0",
    "--color-success-300": "#6ee7b7",
    "--color-success-400": "#34d399",
    "--color-success-500": "#10b981",
    "--color-success-600": "#059669",
    "--color-success-700": "#047857",
    "--color-success-800": "#065f46",
    "--color-success-900": "#064e3b",
    "--color-success-950": "#022c22",

    // Warning - Orange (same hex values)
    "--color-warning-50": "#fff7ed",
    "--color-warning-100": "#ffedd5",
    "--color-warning-200": "#fed7aa",
    "--color-warning-300": "#fdba74",
    "--color-warning-400": "#fb923c",
    "--color-warning-500": "#f97316",
    "--color-warning-600": "#ea580c",
    "--color-warning-700": "#c2410c",
    "--color-warning-800": "#9a3412",
    "--color-warning-900": "#7c2d12",
    "--color-warning-950": "#431407",

    // Error - Red (same hex values)
    "--color-error-50": "#fef2f2",
    "--color-error-100": "#fee2e2",
    "--color-error-200": "#fecaca",
    "--color-error-300": "#fca5a5",
    "--color-error-400": "#f87171",
    "--color-error-500": "#ef4444",
    "--color-error-600": "#dc2626",
    "--color-error-700": "#b91c1c",
    "--color-error-800": "#991b1b",
    "--color-error-900": "#7f1d1d",
    "--color-error-950": "#450a0a",

    // Info - Sky (same hex values)
    "--color-info-50": "#f0f9ff",
    "--color-info-100": "#e0f2fe",
    "--color-info-200": "#bae6fd",
    "--color-info-300": "#7dd3fc",
    "--color-info-400": "#38bdf8",
    "--color-info-500": "#0ea5e9",
    "--color-info-600": "#0284c7",
    "--color-info-700": "#0369a1",
    "--color-info-800": "#075985",
    "--color-info-900": "#0c4a6e",
    "--color-info-950": "#082f49",

    // Semantic tokens for dark mode
    "--color-background-primary": "#0f172a", // neutral-900
    "--color-background-secondary": "#1e293b", // neutral-800
    "--color-background-tertiary": "#334155", // neutral-700
    "--color-background-elevated": "#1e293b", // neutral-800
    "--color-background-muted": "#334155", // neutral-700

    "--color-text-primary": "#f8fafc", // neutral-50
    "--color-text-secondary": "#e2e8f0", // neutral-200
    "--color-text-tertiary": "#cbd5e1", // neutral-300
    "--color-text-muted": "#94a3b8", // neutral-400
    "--color-text-inverse": "#0f172a", // neutral-900
    "--color-text-disabled": "#475569", // neutral-600

    "--color-border-primary": "#334155", // neutral-700
    "--color-border-secondary": "#475569", // neutral-600
    "--color-border-focus": "#14b8a6", // primary-500
    "--color-border-muted": "#1e293b", // neutral-800

    // Brand semantic tokens (dark mode - using brighter variants)
    "--color-brand-primary": "#14b8a6", // primary-500
    "--color-brand-primary-hover": "#2dd4bf", // primary-400
    "--color-brand-primary-active": "#5eead4", // primary-300
    "--color-brand-primary-muted": "#042f2e", // primary-950

    "--color-brand-secondary": "#fbbf24", // secondary-400
    "--color-brand-secondary-hover": "#fcd34d", // secondary-300
    "--color-brand-secondary-active": "#fde68a", // secondary-200
    "--color-brand-secondary-muted": "#451a03", // secondary-950
  }),
};
