import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import App from './App.jsx';

describe('App', () => {
  it('renders learn Jenkins link', () => {
    render(<App />);
    const linkElement = screen.getByText(/learn Jenkins/i);
    expect(linkElement).toBeInTheDocument();
  });
});
