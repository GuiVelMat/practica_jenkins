import react from 'eslint-plugin-react';

export default [
     {
          files: ['**/*.{js,jsx}'],
          plugins: { react },
          languageOptions: {
               ecmaVersion: 'latest',
               sourceType: 'module',
               parserOptions: {
                    ecmaFeatures: { jsx: true },
               },
          },
          rules: {
               'react/jsx-uses-react': 'error',
               'react/jsx-uses-vars': 'error',
          },
     },
];