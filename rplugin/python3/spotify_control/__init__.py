import pynvim
from spotify_control.spotify import Spotify

@pynvim.plugin
class SpotifyControl(object):
    def __init__(self, vim):
        self.vim = vim
        self.calls = 0
        self.first_buffer = None
        self.spotify = Spotify(vim)

    @pynvim.command('SpotifyInit', range='', nargs='*', sync=True)
    def spotify_init(self, args, range):
        self.vim.command('enew')
        self.first_buffer = self.vim.current.buffer

        playlists = self.spotify.get_playlists()
        playlistNames = []
        for playlist in playlists["items"]:
            playlistNames.append(playlist["name"])
        self.first_buffer.api.set_lines(0, -1, 0, playlistNames)
        self.vim.command('set nomodifiable')
