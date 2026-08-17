---
name: Zimam
colors:
  surface: '#f8fafa'
  surface-dim: '#d8dada'
  surface-bright: '#f8fafa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f4'
  surface-container: '#eceeee'
  surface-container-high: '#e6e8e8'
  surface-container-highest: '#e1e3e3'
  on-surface: '#191c1d'
  on-surface-variant: '#3f4849'
  inverse-surface: '#2e3131'
  inverse-on-surface: '#eff1f1'
  outline: '#6f7979'
  outline-variant: '#bfc8c9'
  surface-tint: '#27676c'
  primary: '#00464a'
  on-primary: '#ffffff'
  primary-container: '#1b5e63'
  on-primary-container: '#97d5db'
  inverse-primary: '#93d1d6'
  secondary: '#116c46'
  on-secondary: '#ffffff'
  secondary-container: '#a1f4c3'
  on-secondary-container: '#1b724b'
  tertiary: '#810316'
  on-tertiary: '#ffffff'
  tertiary-container: '#a3222a'
  on-tertiary-container: '#ffb9b5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#afedf3'
  primary-fixed-dim: '#93d1d6'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#a1f4c3'
  secondary-fixed-dim: '#85d7a9'
  on-secondary-fixed: '#002112'
  on-secondary-fixed-variant: '#005233'
  tertiary-fixed: '#ffdad8'
  tertiary-fixed-dim: '#ffb3b0'
  on-tertiary-fixed: '#410006'
  on-tertiary-fixed-variant: '#8e101e'
  background: '#f8fafa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e3'
typography:
  display-hero:
    fontFamily: IBM Plex Sans
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  display-hero-mobile:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  screen-padding: 24px
  gutter: 16px
  touch-target-min: 48px
  section-gap: 32px
---

## Brand & Style

The design system is built on the philosophy of **Quiet Precision**. It is a tool for financial clarity, intended to evoke a sense of calm control for expatriates and freelancers managing complex, cross-border wealth.

The aesthetic follows a **Refined Minimalist** approach. It avoids the frantic energy of retail trading apps in favor of a stable, institutional atmosphere. The interface relies on structural integrity, generous whitespace, and high-quality typography rather than decorative elements. There are no gradients, illustrations, or non-functional icons. Every visual mark serves a purpose: providing information or enabling action.

- **Primary Motif:** Flat surfaces with high-contrast shifts for hierarchy.
- **Tone:** Professional, steady, and utilitarian.
- **Target Platform:** Android (Material 3), optimized for portrait orientation with a focus on tactile density and clear legibility.

## Colors

The palette is anchored by a deep, muted teal, providing a sophisticated alternative to standard financial blues. 

### Semantic Logic
Colors are used strictly for data state.
- **Primary:** Branding, primary actions, and neutral financial data.
- **Gain:** Used for positive growth, inflows, and "up" indicators.
- **Loss:** Used for negative growth, outflows, and "down" indicators.
- **Attention:** Reserved for critical alerts or pending actions.

### Surface Treatment
In Light Mode, the background is a very soft grey-white (`#F2F4F4`) to reduce glare, while cards use a pure white fill (`#FFFFFF`). In Dark Mode, the background is a deep charcoal (`#121414`) with cards using a slightly lighter elevation surface (`#1C1F1F`). Separation is achieved exclusively through fill contrast; no shadows are permitted.

## Typography

The typography system prioritizes the bilingual nature of the user base (Arabic and English) and the precision of financial figures.

- **Main Typeface:** IBM Plex Sans (supports high-quality Arabic/Latin pairing). It is technical yet approachable.
- **Numeric Typeface:** JetBrains Mono is used for all currency amounts, percentages, and dates. This ensures tabular lining where digits align vertically, making it easy to compare multi-currency totals at a glance.

**Constraint Rule:** To maintain the "Quiet" nature of the UI, no single screen should ever display more than three distinct font sizes. Every screen must feature exactly one **Hero Number** (Display-Hero) representing the core metric (e.g., Total Net Worth or Current Exchange Rate).

## Layout & Spacing

The layout is strictly governed by an **8dp grid system**.

- **Margins:** A 24dp side padding is mandatory for all screens to create a "frame" of whitespace that makes the content feel centered and intentional.
- **Rhythm:** Vertical spacing between cards or major sections is set to 32dp. Internal card padding is set to 16dp.
- **Touch Targets:** All interactive elements (tabs, icons, buttons) have a minimum footprint of 48x48dp to ensure accessibility, even if the visual asset is smaller.
- **Grid:** A 4-column fluid grid is used for Android Portrait. Content cards should typically span all 4 columns to maintain the "instrument" feel, avoiding cluttered side-by-side layouts.

## Elevation & Depth

This design system rejects the use of drop shadows. Depth is communicated through **Tonal Layering**.

- **Level 0 (Background):** The base canvas of the application.
- **Level 1 (Cards/Surfaces):** Content containers that sit on the background. In light mode, these are white; in dark mode, these are a lighter shade of the background charcoal.
- **Interactions:** When a user presses a card or button, the surface does not "lift" (no shadow); instead, it changes its fill color to a slightly darker (light mode) or lighter (dark mode) tone to indicate a physical state change.

This creates a flat, architectural feel that resembles a high-end physical calculator or a Swiss watch face.

## Shapes

The shape language balances modern software aesthetics with the sturdiness of a financial tool.

- **Cards & Containers:** Fixed 16px corner radius. This provides a soft enough edge to feel modern without becoming "bubbly" or unprofessional.
- **Buttons:** Follow the card radius (16px) for a cohesive look. Do not use pill-shaped buttons.
- **Inputs:** Use a 12px radius to slightly differentiate them from larger structural containers.
- **Icons:** Use a 24dp bounding box. Icon strokes should be 1.5px or 2px—never hairline—to maintain visual weight against the JetBrains Mono figures.

## Components

### Buttons
Primary buttons are solid fills of the Primary Color with white text. Secondary buttons are subtle grey fills with Primary Color text. No borders are used.

### Cards
Cards are the primary organizational unit. They must have a flat fill and no border. If multiple pieces of information are inside a card, use a 1px subtle divider (`#E0E0E0` in light mode) rather than separate cards to avoid visual noise.

### Input Fields
Inputs are "Filled" style (Material 3) but without the bottom line. Use a subtle background fill. The label should always be visible (never disappearing when typing) to ensure clarity for complex financial entries.

### Chips
Used only for currency selection or time-period filtering. They use a 16px radius. Selected chips use the Primary Color; unselected chips use a light grey fill that matches the background.

### Data Lists
Lists of transactions or assets must align the JetBrains Mono figures to the right-hand margin. Use a "monospaced column" logic for numbers so that decimal points align vertically across rows.