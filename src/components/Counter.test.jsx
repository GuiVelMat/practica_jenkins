import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Counter from './Counter';

test('renders Counter component with initial value 0', () => {
     render(<Counter />);
     expect(screen.getByText(/Counter: 0/i)).toBeInTheDocument();
});

test('increments the counter when Increment button is clicked', async () => {
     render(<Counter />);
     const incrementButton = screen.getByText(/Increment/i);
     userEvent.click(incrementButton);

     // Usar findByText para esperar el cambio en el DOM
     expect(await screen.findByText(/Counter: 1/i)).toBeInTheDocument();
});

test('resets the counter when Reset button is clicked', () => {
     render(<Counter />);
     userEvent.click(screen.getByText(/Increment/i));
     userEvent.click(screen.getByText(/Reset/i));
     expect(screen.getByText(/Counter: 0/i)).toBeInTheDocument();
});
