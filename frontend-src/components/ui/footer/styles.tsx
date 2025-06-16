import { tva } from '@gluestack-ui/nativewind-utils/tva';

export const footerStyle = tva({
    base: 'border-t border-border-300 bg-background-100 px-4 py-2',

    variants: {
        size: {
            sm: 'py-1 px-2',
            md: 'py-2 px-4',
            lg: 'py-3 px-6',
        },
        position: {
            fixed: 'absolute bottom-0 left-0 right-0',
            static: '',
        }
    },

    defaultVariants: {
        size: 'md',
        position: 'static',
    }
});