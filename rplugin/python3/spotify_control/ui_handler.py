class UIHandler():
    def __init__(self, vim):
        self.vim = vim
        self.results_buffer = None
        self.playlist_buffer = None

    def _init_buffer_options(self, vim_buffer):
        vim_buffer.api.set_option('modifiable', False)
        vim_buffer.api.set_option('readonly', True)
        vim_buffer.api.set_option('bufhidden', 'hide')
        vim_buffer.api.set_option('buftype', 'nofile')
        vim_buffer.api.set_option('swapfile', False)
        vim_buffer.api.set_option('buflisted', False)
        vim_buffer.api.set_option('undolevels', -1)


    def _set_buffer_content(self, vim_buffer, lines):
        vim_buffer.api.set_option('modifiable', True)
        vim_buffer.api.set_option('readonly', False)

        vim_buffer.api.set_lines(0, -1, 0, lines)

        vim_buffer.api.set_option('modifiable', False)
        vim_buffer.api.set_option('readonly', True)

    def init_buffers(self, playlists):
        # setting up results buffer
        self.results_buffer = self.vim.current.buffer
        self.vim.command('nnoremap <buffer> <Enter> :call SpotifyPlayResult()<CR>')
        self._init_buffer_options(self.results_buffer)

        # setting up playlist buffer
        self.vim.command('topleft vertical 32 new')
        self.playlist_buffer = self.vim.current.buffer
        self.vim.command('nnoremap <buffer> <Enter> :call SpotifyOpenPlaylist()<CR>')

        self._init_buffer_options(self.playlist_buffer)
        self._set_buffer_content(self.playlist_buffer, playlists)

    def set_results(self, results):
        self.vim.command('set switchbuf=useopen')
        self.vim.command('sb {}'.format(self.results_buffer.number))
        self._set_buffer_content(self.results_buffer, results)
