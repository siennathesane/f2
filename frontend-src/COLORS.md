# f2 Color System Documentation

## Overview

The f2 color system is built around **semantic tokens** that automatically adapt to light and dark themes. Our palette reflects our core values: community, solarpunk sustainability, warmth, protection, and skilled craftsmanship.

**Core Philosophy**: Use semantic tokens (`text-primary`, `bg-brand-primary`) instead of raw color values (`primary-600`) to ensure proper theme adaptation and accessibility.

## Color Families

### 🔵 Primary - Teal
**Vibe**: Trust, stability, nature-tech harmony (solarpunk)
- **Light mode**: Deeper teals (600-700) for contrast
- **Dark mode**: Brighter teals (400-500) for visibility
- **Use for**: Main brand elements, primary CTAs, navigation highlights

### 🟡 Secondary - Amber
**Vibe**: Warmth, energy, craftsmanship
- **Light mode**: Rich ambers (500-600)
- **Dark mode**: Bright ambers (300-400)
- **Use for**: Secondary actions, warm accents, highlights, attention-grabbing elements

### ⚫ Neutral - Slate
**Vibe**: Professional, clean, modern
- **Use for**: Text hierarchy, backgrounds, borders, general UI structure

### State Colors
- **🟢 Success - Emerald**: Confirmations, completed actions, positive feedback
- **🟠 Warning - Orange**: Cautions, important notices, attention needed
- **🔴 Error - Red**: Errors, destructive actions, critical alerts
- **🔵 Info - Sky**: Information, tips, neutral notifications

---

## Semantic Token Guide

### Background Colors

| Token | Light Mode | Dark Mode | When to Use |
|-------|------------|-----------|-------------|
| `bg-background-primary` | White | Neutral-900 | Main page background, modal backgrounds |
| `bg-background-secondary` | Neutral-50 | Neutral-800 | Card backgrounds, section dividers |
| `bg-background-tertiary` | Neutral-100 | Neutral-700 | Subtle backgrounds, disabled states |
| `bg-background-elevated` | White | Neutral-800 | Floating elements, dropdowns, tooltips |
| `bg-background-muted` | Neutral-100 | Neutral-700 | Input backgrounds, inactive areas |

### Text Colors

| Token | Light Mode | Dark Mode | When to Use |
|-------|------------|-----------|-------------|
| `text-text-primary` | Neutral-900 | Neutral-50 | Headlines, primary content, important text |
| `text-text-secondary` | Neutral-700 | Neutral-200 | Body text, descriptions, secondary headings |
| `text-text-tertiary` | Neutral-500 | Neutral-300 | Supporting text, metadata, captions |
| `text-text-muted` | Neutral-400 | Neutral-400 | Placeholder text, inactive labels |
| `text-text-inverse` | White | Neutral-900 | Text on colored backgrounds |
| `text-text-disabled` | Neutral-300 | Neutral-600 | Disabled form elements, inactive text |

### Border Colors

| Token | Light Mode | Dark Mode | When to Use |
|-------|------------|-----------|-------------|
| `border-border-primary` | Neutral-200 | Neutral-700 | Default borders, card outlines |
| `border-border-secondary` | Neutral-300 | Neutral-600 | Stronger borders, form inputs |
| `border-border-focus` | Primary-600 | Primary-500 | Focus states, active selections |
| `border-border-muted` | Neutral-100 | Neutral-800 | Subtle dividers, light separators |

### Brand Colors

| Token | Light Mode | Dark Mode | When to Use |
|-------|------------|-----------|-------------|
| `bg-brand-primary` | Primary-600 | Primary-500 | Main CTAs, primary buttons |
| `bg-brand-primary-hover` | Primary-700 | Primary-400 | Button hover states |
| `bg-brand-primary-active` | Primary-800 | Primary-300 | Button active/pressed states |
| `bg-brand-primary-muted` | Primary-50 | Primary-950 | Light brand backgrounds, badges |
| `bg-brand-secondary` | Secondary-500 | Secondary-400 | Secondary CTAs, accent buttons |
| `bg-brand-secondary-hover` | Secondary-600 | Secondary-300 | Secondary button hovers |
| `bg-brand-secondary-active` | Secondary-700 | Secondary-200 | Secondary button active states |
| `bg-brand-secondary-muted` | Secondary-50 | Secondary-950 | Warm accent backgrounds |

---

## Usage Guidelines

### ✅ Do This

**Primary Actions**
```tsx
<Button className="bg-brand-primary hover:bg-brand-primary-hover">
  <ButtonText className="text-text-inverse">Save Changes</ButtonText>
</Button>
```

**Secondary Actions**
```tsx
<Button className="bg-brand-secondary hover:bg-brand-secondary-hover">
  <ButtonText className="text-text-inverse">Learn More</ButtonText>
</Button>
```

**Text Hierarchy**
```tsx
<VStack>
  <Text className="text-text-primary text-2xl font-bold">Main Heading</Text>
  <Text className="text-text-secondary text-lg">Subheading</Text>
  <Text className="text-text-tertiary text-sm">Supporting details</Text>
</VStack>
```

**Cards and Sections**
```tsx
<Box className="bg-background-secondary border border-border-primary rounded-lg p-4">
  <Text className="text-text-primary">Card content</Text>
</Box>
```

### ❌ Don't Do This

```tsx
// ❌ Don't use raw color values
<Button className="bg-primary-600">

// ❌ Don't use hardcoded colors that don't adapt
<Text className="text-black">

// ❌ Don't use colors that break in dark mode
<Box className="bg-white text-gray-900">
```

---

## Context-Specific Usage

### Navigation & Headers
- **Background**: `bg-background-primary` or `bg-background-secondary`
- **Active items**: `bg-brand-primary` with `text-text-inverse`
- **Inactive items**: `text-text-secondary`
- **Borders**: `border-border-primary`

### Forms & Inputs
- **Input backgrounds**: `bg-background-muted`
- **Input borders**: `border-border-secondary`
- **Focus states**: `border-border-focus`
- **Labels**: `text-text-secondary`
- **Placeholders**: `text-text-muted`
- **Error states**: `border-error-500` and `text-error-500`

### Buttons & CTAs
- **Primary**: `bg-brand-primary` → `bg-brand-primary-hover` → `bg-brand-primary-active`
- **Secondary**: `bg-brand-secondary` → `bg-brand-secondary-hover` → `bg-brand-secondary-active`
- **Outline**: `border-border-secondary` with `text-text-primary`, hover to `bg-background-tertiary`
- **Destructive**: `bg-error-500` → `bg-error-600` → `bg-error-700`

### Status & Feedback
- **Success**: `bg-success-50` background with `text-success-500` text
- **Warning**: `bg-warning-50` background with `text-warning-500` text
- **Error**: `bg-error-50` background with `text-error-500` text
- **Info**: `bg-info-50` background with `text-info-500` text

### Data Visualization
- **Primary data**: Use `brand-primary` family
- **Secondary data**: Use `brand-secondary` family
- **Categorical data**: Combine `success`, `warning`, `info` colors
- **Neutral data**: Use `neutral` scale

---

## Accessibility Standards

All color combinations meet **WCAG AA** contrast requirements:

- `text-text-primary` on `bg-background-primary`: ✅ 8.87:1 ratio
- `text-text-secondary` on `bg-background-primary`: ✅ 7.1:1 ratio
- `text-text-inverse` on `bg-brand-primary`: ✅ 4.5:1 ratio
- `text-text-inverse` on `bg-brand-secondary`: ✅ 4.51:1 ratio

**Never use:**
- Light text on light backgrounds
- Similar color combinations without sufficient contrast
- Color as the only way to convey information

---

## Theme Implementation

### Setting Up Theme Context
```tsx
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

// Use 'light', 'dark', or 'system'
<GluestackUIProvider mode="system">
  <YourApp />
</GluestackUIProvider>
```

### Theme-Aware Components
```tsx
// Components automatically adapt to theme changes
const Card = () => (
  <Box className="bg-background-elevated border border-border-primary p-4">
    <Text className="text-text-primary">This adapts to light/dark mode</Text>
  </Box>
);
```

---

## Quick Reference

### Most Common Combinations
- **Page background**: `bg-background-primary`
- **Card/section**: `bg-background-secondary` + `border-border-primary`
- **Primary button**: `bg-brand-primary` + `text-text-inverse`
- **Body text**: `text-text-secondary`
- **Headings**: `text-text-primary`
- **Subtle text**: `text-text-tertiary`

### Emergency Override (Rare Cases)
If you absolutely need theme-specific styling:
```tsx
<Box className="bg-background-primary dark:bg-neutral-800">
  // Use sparingly - semantic tokens are preferred
</Box>
```

---

## Community Values in Color

Our color choices reflect our mission:

- **🌊 Teal (Primary)**: Trust, stability, and the harmony between technology and nature (solarpunk)
- **🔆 Amber (Secondary)**: Warmth, community energy, and skilled craftsmanship
- **🌱 Emerald (Success)**: Growth, sustainability, and positive community action
- **⚫ Slate (Neutral)**: Professional accessibility without corporate coldness

Use these colors to reinforce our values of community protection, environmental consciousness, and inclusive technology.