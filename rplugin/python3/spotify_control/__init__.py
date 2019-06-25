import pynvim
from spotify_control.spotify import Spotify
from spotify_control.ui_handler import UIHandler

@pynvim.plugin
class SpotifyControl(object):
    def __init__(self, vim):
        self.vim = vim
        self.spotify = Spotify(vim)
        self.ui_handler = UIHandler(vim)

    @pynvim.command('SpotifyInit', range='', nargs='*', sync=True)
    def spotify_init(self, args, range):
        playlists = self.spotify.get_playlists()
        self.ui_handler.init_buffers(playlists)
