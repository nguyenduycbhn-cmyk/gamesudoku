class Sudoku:
    def __init__(self, difficulty='medium'):
        self.board = [[0 for _ in range(9)] for _ in range(9)]
        self.original_board = [[0 for _ in range(9)] for _ in range(9)]
        self.generate_puzzle(difficulty)

    def generate_puzzle(self, difficulty='medium'):
        # Base solved board
        solved = [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
        self.board = [row[:] for row in solved]
        self.original_board = [row[:] for row in solved]

        # Remove cells based on difficulty
        if difficulty == 'easy':
            cells_to_remove = 30
        elif difficulty == 'medium':
            cells_to_remove = 40
        elif difficulty == 'hard':
            cells_to_remove = 50
        else:
            cells_to_remove = 40

        import random
        positions = [(i, j) for i in range(9) for j in range(9)]
        random.shuffle(positions)
        for i, j in positions[:cells_to_remove]:
            self.board[i][j] = 0

    def is_valid(self, row, col, num):
        # Check row
        if num in self.board[row]:
            return False
        # Check column
        for r in range(9):
            if self.board[r][col] == num:
                return False
        # Check 3x3 box
        box_row = (row // 3) * 3
        box_col = (col // 3) * 3
        for r in range(box_row, box_row + 3):
            for c in range(box_col, box_col + 3):
                if self.board[r][c] == num:
                    return False
        return True

    def solve(self):
        for row in range(9):
            for col in range(9):
                if self.board[row][col] == 0:
                    for num in range(1, 10):
                        if self.is_valid(row, col, num):
                            self.board[row][col] = num
                            if self.solve():
                                return True
                            self.board[row][col] = 0
                    return False
        return True

    def get_board(self):
        return self.board

    def set_cell(self, row, col, num):
        if self.is_valid(row, col, num):
            self.board[row][col] = num
            return True
        return False