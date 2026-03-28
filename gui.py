import tkinter as tk
from tkinter import messagebox
from sudoku import Sudoku

class SudokuGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Sudoku Game")
        self.geometry("450x550")  # Increased height for menu
        self.difficulty = tk.StringVar(value='medium')
        self.sudoku = Sudoku(self.difficulty.get())
        self.entries = [[None for _ in range(9)] for _ in range(9)]
        self.create_widgets()

    def create_widgets(self):
        # Difficulty menu
        difficulty_label = tk.Label(self, text="Difficulty:")
        difficulty_label.grid(row=0, column=9, padx=10, pady=5, sticky='w')
        difficulty_menu = tk.OptionMenu(self, self.difficulty, 'easy', 'medium', 'hard')
        difficulty_menu.grid(row=0, column=10, padx=10, pady=5)

        # Create grid
        for row in range(9):
            for col in range(9):
                entry = tk.Entry(self, width=2, font=('Arial', 18), justify='center')
                entry.grid(row=row+1, column=col, padx=1, pady=1)  # Shift down by 1
                entry.bind('<KeyRelease>', lambda e, r=row, c=col: self.on_entry_change(r, c))
                self.entries[row][col] = entry

        # Buttons
        solve_button = tk.Button(self, text="Solve", command=self.solve)
        solve_button.grid(row=10, column=0, columnspan=3, pady=10)

        new_game_button = tk.Button(self, text="New Game", command=self.new_game)
        new_game_button.grid(row=10, column=3, columnspan=3, pady=10)

        check_button = tk.Button(self, text="Check", command=self.check)
        check_button.grid(row=10, column=6, columnspan=3, pady=10)

        self.load_board()

    def load_board(self):
        board = self.sudoku.get_board()
        original = self.sudoku.original_board
        for row in range(9):
            for col in range(9):
                self.entries[row][col].delete(0, tk.END)
                if original[row][col] != 0:
                    self.entries[row][col].insert(0, str(original[row][col]))
                    self.entries[row][col].config(state='disabled')
                else:
                    self.entries[row][col].config(state='normal')

    def on_entry_change(self, row, col):
        value = self.entries[row][col].get()
        if value.isdigit() and 1 <= int(value) <= 9:
            if not self.sudoku.set_cell(row, col, int(value)):
                messagebox.showerror("Invalid", "Invalid move!")
                self.entries[row][col].delete(0, tk.END)
        elif value:
            self.entries[row][col].delete(0, tk.END)

    def solve(self):
        if self.sudoku.solve():
            self.load_board()
            messagebox.showinfo("Solved", "Sudoku solved!")
        else:
            messagebox.showerror("Error", "No solution found")

    def new_game(self):
        self.sudoku = Sudoku(self.difficulty.get())
        self.load_board()

    def check(self):
        board = self.sudoku.get_board()
        full = True
        for row in range(9):
            for col in range(9):
                if board[row][col] == 0:
                    full = False
                    break
        if full:
            messagebox.showinfo("Congratulations", "You solved the Sudoku!")
        else:
            messagebox.showinfo("Not yet", "Keep trying!")