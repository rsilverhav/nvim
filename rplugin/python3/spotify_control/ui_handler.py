class UIHandler():
    def __init__(self, vim):
        self.vim = vim
        self.playlist_buffer = None

    def init_buffers(self, playlists):
        self.vim.command('topleft vertical 32 new')
        self.playlist_buffer = self.vim.current.buffer
        self.playlist_buffer.api.set_lines(0, -1, 0, playlists)
        self.vim.command('set nomodifiable')
