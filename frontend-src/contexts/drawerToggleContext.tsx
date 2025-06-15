// contexts/DrawerToggleContext.tsx
import { createContext, useContext } from 'react';

const DrawerToggleContext = createContext<() => void>(() => {
    console.warn('DrawerToggleContext not provided');
});

export const useDrawerToggle = () => useContext(DrawerToggleContext);
export const DrawerToggleProvider = DrawerToggleContext.Provider;