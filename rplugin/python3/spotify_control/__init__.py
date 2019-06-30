import pynvim
from spotify_control.spotify import Spotify
from spotify_control.ui_handler import UIHandler

@pynvim.plugin
class SpotifyControl(object):
    def __init__(self, vim):
        self.vim = vim
        self.playlists_data = []
        self.results_data = []
        self.spotify = Spotify(vim)
        self.ui_handler = UIHandler(vim)

    @pynvim.command('SpotifyInit', range='', nargs='*', sync=True)
    def spotify_init(self, args, range):
        self.playlists_data = self.spotify.get_playlists_data()
        playlist_names = list(map(lambda playlist_data: playlist_data['name'], self.playlists_data))
        self.vim.command('tab new')
        self.ui_handler.init_buffers(playlist_names)

    @pynvim.function('SpotifyOpenPlaylist')
    def function_handler(self, args):
        current_line = self.vim.eval('line(".")')
        current_index = current_line - 1
        if current_index >= 0 and current_index < len(self.playlists_data):
            playlist_id = self.playlists_data[current_index]['id']
            self.results = self.spotify.get_playlists_tracks_data(playlist_id)
            songs = []
            for track_data in self.results:
                song_name = track_data['track']['name']
                artists = ', '.join(map(lambda artist: artist['name'], track_data['track']['artists']))
                songs.append('{} - {}'.format(song_name, artists))
            self.ui_handler.set_results(songs)

    # @pynvim.function('SpotifyPlayResult')
    # def function_handler(self, args):
    #     self.spotify.play
    #     self.ui_handler.open_playlist(self.playlists_data)
